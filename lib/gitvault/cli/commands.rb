module Gitvault::CLI::Command
  class Base
    include Gitvault::CLI::Terminal
    
    attr_reader :session, :client, :args
    
    def initialize(session, args, client=nil)
      @session = session
      @client  = client
      @args    = args
    end
  end
  
  class General < Base
    def help
      rows = [
        ['help', 'Show this help message'],
        ['list', 'List all available repositories'],
        ['create NAME', 'Create a new repository with a given name'],
        ['delete NAME', 'Delete an existing repository'],
        ['clone NAME', 'Clone an existing repository into current path']
      ]
      
      puts rows.map { |r| r.first.ljust(30) + r.last }.join("\n")
    end
  end
  
  class Accounts < Base
    def index
      session.accounts.each do |acc|
        puts "#{acc.name} -> #{acc.url}"
      end
    end
    
    def create
      name = ask('Account name')
      url = ask('Base URL')
      
      if session.add_account(name, url)
        puts "New account \"#{name}\" has been added."
        session.save_accounts!
      else
        puts "The URL you provided is not valid."
      end
    end
  end
  
  class Repositories < Base
    def list
      @client.get_repositories.each do |repo|
        puts "#{repo['name'].ljust(30)}#{repo['info']['remote']}"
      end
    end
    
    def show
      name = args.shift.to_s.strip
      if name.empty?
        puts "Please provide a name."
        exit(1)
      end
      
      info = client.get_repository(name)
      
      rows = [
        "Clone URL: #{info['remote']}",
        "Empty: #{info['empty'] == true ? 'Yes' : 'No'}",
        "Filesize: #{info['filesize']}",
        "Description: #{info['description']}"
      ]
      
      puts rows.join("\n")
    end
    
    def create
      name = args.shift.to_s.strip
      if name.empty?
        name = ask('Repository name')
        if name.empty?
          puts "Name required!"
          exit 1
        end
      end
      
      result = client.create_repository(name)
      if result['error']
        puts "Error: #{result['error']}"
      else
        puts "Created! Remote url: #{result['repository']['remote']}"
      end
    end
    
    def delete
      name = args.shift.to_s.strip
      if name.empty?
        name = ask('Repository name')
        if name.empty?
          puts "Name required!"
          exit 1
        end
      end
      
      result = client.delete_repository(name)
      if result['success']
        puts "Deleted!"
      else
        puts "Error: #{result['error']}"
      end
    end
  end
end
