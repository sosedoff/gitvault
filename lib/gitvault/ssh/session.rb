module Gitvault::SSH
  class Session
    include Git
    
    attr_reader :args, :env
    
    def initialize(args, env)
      @args = args || {}
      @env = env || {}
    end
    
    def execute!
      terminate("Invalid environment.") unless valid_environment?      
      terminate("Only git requests are allowed.") unless git_request?

      action, repo = repo_request.first, repo_request.last
      
      repo = File.basename(repo)
      repo << ".git" unless File.extname(repo) == '.git'
      repo_path = File.join(@env['HOME'], repo)
      
      unless File.exists?(repo_path)
        terminate("Repository does not exist")
      end
      
      params = [action, "'#{repo_path}'"]
      exec("git-shell", "-c", params.join(' '))
    end
    
    def terminate(reason)
      $stderr.puts("Session terminated. Reason: #{reason}")
      exit(1)
    end
    
    private
    
    def valid_environment?
      env['USER'] == GIT_USER && env['HOME'] == GIT_HOME
    end
    
    def git_request?
      if env.key?('SSH_CLIENT') && env.key?('SSH_CONNECTION') && env.key?('SSH_ORIGINAL_COMMAND')
        env['SSH_ORIGINAL_COMMAND'] =~ GIT_COMMAND ? true : false
      else
        false
      end
    end
    
    def repo_request
      @repo_request ||= @env['SSH_ORIGINAL_COMMAND'].scan(GIT_COMMAND).flatten
    end
  end
end
