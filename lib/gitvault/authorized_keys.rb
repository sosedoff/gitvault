module Gitvault
  module AuthorizedKeys
    REGEX_UUID = /^### (start|end) ([a-z\d]+) ###/i
    
    class << self
      def save_path
        Gitvault.configuration.authorized_keys
      end
      
      def write(command, keys)
        buffer = keys.map { |k| k.to_system_key(command) }.join("\n")
        # FIXME: 'w' truncates the contents before lock
        File.open(save_path, 'w') do |f|
          f.flock(File::LOCK_EX)
          f.write(buffer)
          f.flock(File::LOCK_EX)
        end
      end
      
      def read
        lines = File.readlines(save_path).map { |l| l.strip }.select { |l| !l.empty? }
        parse_keys_data(lines)
      end
      
      private
      
      def parse_keys_data(lines)
        keys = []
        unless lines.empty?
          loop do
            k_start, k_data, k_end = lines.shift, lines.shift, lines.shift
            
            keys << PublicKey.new(
              :uuid => parse_uuid(k_start),
              :content => k_data
            )
  
            break if lines.empty?
          end
        end
        keys
      end
      
      def parse_uuid(line)
        line.scan(REGEX_UUID).flatten.last
      end
    end
  end
end