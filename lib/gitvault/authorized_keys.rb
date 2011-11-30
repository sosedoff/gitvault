module Gitvault
  module AuthorizedKeys
    @@keys_path = nil
    
    class << self
      # Set a new save path
      #
      def save_path=(path)
        @@keys_path = path
      end
      
      # Get current save path
      #
      def save_path
        @@keys_path
      end
      
      # Generate authorized keys file content
      #
      # command - Command to prepend for key
      # keys    - Array of public keys
      #
      def write(command, keys)
        buffer = keys.map { |k| k.to_system_key(command) }.join("\n")
        # FIXME: 'w' truncates the contents before lock
        File.open(save_path, 'w') do |f|
          f.flock(File::LOCK_EX)
          f.write(buffer)
          f.flock(File::LOCK_EX)
        end
      end
    end
  end
end