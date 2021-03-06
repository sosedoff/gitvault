require 'sinatra/base'
require 'json'
require 'active_model'

require 'gitvault'
require 'gitvault/configuration'
require 'gitvault/version'
require 'gitvault/errors'
require 'gitvault/git'
require 'gitvault/public_key'
require 'gitvault/authorized_keys'

module Gitvault
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))
      
    helpers do
      def json_response(data)
        data.to_json
      end

      def bad_request(error, code=400)
        halt(code, json_response(:error => error))
      end
      
      def git
        Gitvault::Git.new(Gitvault.configuration.repositories)
      end
      
      def require_repository
        @repo = params[:name].to_s.strip
        if @repo.empty?
          bad_request("Repository name required")
        end
        
        unless @repo =~ /^[a-z\d\-\_]{2,64}$/i
          bad_request("Invalid name \"#{@repo}\". Please use only a-z 0-9 dash or underscore.")
        end
      end
    end
    
    before do
      content_type :json, :encoding => :utf8
    end
    
    not_found do
      bad_request("Invalid route", 404)
    end
    
    get '/' do
      json_response("Gitvault server")
    end
    
    get '/version' do
      json_response(:version => Gitvault::VERSION)
    end
    
    get '/git_version' do
      version = `git --version`.strip.split.last
      json_response(:version => version)
    end
    
    get '/repositories' do
      begin
        repos = git.list.map { |r| {'name' => r, 'info' => git.info(r) } }
        json_response(repos)
      rescue GitError => err
        bad_request(err.message)
      end
    end
    
    get '/repositories/:name' do
      require_repository
      begin
        json_response(git.info(@repo))
      rescue GitError => err
        bad_request(err.message)
      end
    end
    
    post '/repositories' do
      require_repository
      begin
        success = git.init(@repo)
        info    = git.info(@repo)
        json_response(:success => success, :repository => info)
      rescue GitError => err
        bad_request(err.message)
      end
    end
    
    delete '/repositories/:name' do
      require_repository
      begin
        json_response(:success => git.destroy(@repo))
      rescue GitError => err
        bad_request(err.message)
      end
    end
    
    get '/public_keys' do
      json_response(AuthorizedKeys.read.map(&:to_hash))
    end
    
    post '/public_keys' do
      key = PublicKey.new(params[:public_key])
      if key.valid?
        existing_keys = AuthorizedKeys.read
        existing_keys << key
        AuthorizedKeys.write('gitvault-ssh', existing_keys)
        json_response(:success => true)
      else
        json_response(:success => false, :errors => key.errors.messages)
      end
    end
  end
end
