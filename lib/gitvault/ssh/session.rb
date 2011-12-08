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
      params = [action, File.join(@env['HOME'], 'repositories', repo)]
      exec("git-shell", "-c", params.join(' '))
      
      git_action, git_repo = request.first, request.last
      args = [git_action, "'/home/git/repositories/#{git_repo}'"]
      exec("git-shell", "-c", args.join(' '))
    end
    
    def terminate(reason)
      $stderr.puts("Session terminated. Reason: #{reason}")
      exit(1)
    end
    
    private
    
    def valid_environment?
      @env['USER'] == GIT_USER && @env['HOME'] == GIT_HOME
    end
    
    def git_request?
      if (@env.keys && ['SSH_CLIENT', 'SSH_CONNECTION', 'SSH_ORIGINAL_COMMAND']) == 3
        @env['SSH_ORIGINAL_COMMAND'] =~ GIT_COMMAND ? true : false
      end
      false
    end
    
    def repo_request
      @repo_request ||= @env['SSH_ORIGINAL_COMMAND'].scan(COMMAND).flatten
    end
  end
end
