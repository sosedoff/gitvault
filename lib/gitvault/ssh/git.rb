module Gitvault
  module SSH
    module Git
      COMMANDS_READONLY = [
        'git-upload-pack',
        'git upload-pack',
        'git-upload-archive',
        'git upload-archive'
      ]
    
      COMMANDS_WRITE = [
        'git-receive-pack',
        'git receive-pack'
      ]
    
      GIT_COMMAND = /^(git-upload-pack|git upload-pack|git-upload-archive|git upload-archive|git-receive-pack|git receive-pack) '(.*)'$/
      GIT_USER = 'git'
      GIT_HOME = "/home/#{GIT_USER}"
      
      def read_command?(cmd)
        COMMANDS_READONLY.include?(cmd)
      end
      
      def write_command?(cmd)
        COMMANDS_WRITE.include?(cmd)
      end
    end
  end
end
