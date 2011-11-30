require 'fileutils'

module Gitvault
  class Git
    attr_reader :root_path
    
    class << self
      def configure(root_path)
        FileUtils.mkdir_p(root_path)
      end
    end
    
    # Initialize a new git driver
    #
    # root_path - Absolute path to directory with repositories
    #
    def initialize(root_path)
      unless File.exists?(root_path)
        raise GitError, "Root path '#{root_path}' does not exist!"
      end
      
      unless File.directory?(root_path)
        raise GitError, "Root path '#{root_path}' is not a directory!"
      end
      
      @root_path = root_path
    end
    
    # List all repositories
    #
    def list
      Dir[File.join(root_path, "*.git")].map do |f|
        File.basename(f, '.git')
      end
    end
    
    # Initialize a new bare git repository
    #
    def init(name)      
      path = File.join(root_path, "#{name}.git")
      
      if File.exists?(path)
        raise GitError, "Already exists!"
      end
      
      `git init --bare #{path}`
      if $?.exitstatus == 0
        `rm -f #{path}/hooks/*.sample`
        true
      else
        false
      end
    end
    
    # Get repository information
    #
    def info(name)
      path = File.join(root_path, "#{name}.git")
      
      unless File.exists?(path)
        raise GitError, "Repository #{name} does not exist"
      end
      
      sz          = `du -sk #{path}`.strip.split(' ').first || 0
      description = File.read("#{path}/description")
      url         = "git@#{`hostname`.strip}:#{name}.git"
      
      {
        :empty       => sz == 0,
        :filesize    => Integer(sz),
        :description => description,
        :url         => url
      }
    end
    
    # Destroy an existing git repository
    #
    def destroy(name)
      path = File.join(root_path, "#{name}.git")
      
      unless File.exists?(path)
        raise GitError, "Repository #{name} does not exist"
      end
      
      FileUtils.rm_rf(path)
      File.exists?(path) == false
    end
  end
end
