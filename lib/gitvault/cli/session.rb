require 'fileutils'
require 'yaml'
require 'gitvault/cli/terminal'
require 'gitvault/cli/account'
require 'gitvault/cli/commands'

module Gitvault::CLI
  class Session
    include Terminal
    
    attr_reader :accounts
    
    def initialize
      unless File.exists?(accounts_file)
        STDERR.puts "Accounts file '#{accounts_file}' does not exist. Creating one right now."
        FileUtils.touch(accounts_file)
      end
      
      @accounts = []
      records = (YAML.load_file(accounts_file) || {}).each_pair do |name, url|
        @accounts << Account.new(name, url)
      end
    end
    
    def run!(account, args)
      cmd = args.kind_of?(String) ? args : (args.shift.to_s.strip || 'help')
      
      client = account.nil? ? nil : Gitvault::CLI::Client.new(account.url)
      case cmd
        when 'accounts'
          Gitvault::CLI::Command::Accounts.new(self, args, client).index  
        when 'accounts:create'
          Gitvault::CLI::Command::Accounts.new(self, args, client).create
        when 'list'
          Gitvault::CLI::Command::Repositories.new(self, args, client).list
        when 'show'
          Gitvault::CLI::Command::Repositories.new(self, args, client).show
        when 'create'
          Gitvault::CLI::Command::Repositories.new(self, args, client).create
        when 'delete'
          Gitvault::CLI::Command::Repositories.new(self, args, client).delete
        else
          Gitvault::CLI::Command::General.new(self, args, client).help
      end
    end
    
    def add_account(name, url)
      acc = Account.new(name, url)
      if acc.valid?
        @accounts << acc
        true
      else
        false
      end
    end
    
    def save_accounts!
      hash = {}
      @accounts.each { |acc| hash[acc.name] = acc.url }
      File.open(accounts_file, 'w') do |f|
        f.write YAML.dump(hash)
      end
    end
    
    def account_exists?(name)
      @accounts.map { |a| a.name == name }.any?
    end
    
    private
    
    def accounts_file
      @accounts_file ||= File.join(ENV['HOME'], '.gitvault')
    end
  end
end
