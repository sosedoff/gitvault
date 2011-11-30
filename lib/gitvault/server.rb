require 'sinatra/base'
require 'json'

require 'gitvault/version'
require 'gitvault/errors'
require 'gitvault/git'
require 'gitvault/public_key'
require 'gitvault/authorized_keys'

module Gitvault
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))
    
    configure do
      set :git_root, '/tmp/gitvault'
      
      Gitvault::Git.configure(settings.git_root)
    end
    
    helpers do
      def json_response(data)
        data.to_json
      end

      def bad_request(error, code=400)
        halt(code, json_response(:error => error))
      end
      
      def git
        Gitvault::Git.new(settings.git_root)
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
      json_response(:time => Time.now)
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
        json_response(git.list)
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
  end
end
