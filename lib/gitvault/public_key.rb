module Gitvault
  class PublicKey
    CONTENT_FORMAT = /^ssh\-[a-z]{3}\s\S+==(\s\S+)?$/.freeze
    COMMAND_OPTIONS = [
      'no-port-forwarding',
      'no-X11-forwarding',
      'no-agent-forwarding',
      'no-pty'
    ]
    
    attr_accessor :content, :description, :type
    attr_reader   :uuid, :checksum
    
    def initialize
    end
    
    def to_system_key(command)
      lines = []
      lines << "### START #{self.uuid} ###"
      lines << "command=\"#{command} #{self.type}\",#{COMMAND_OPTIONS.join(",")} #{self.content}".strip
      lines << "### END #{self.uuid} ###"
      lines.join("\n")
    end
    
    def wrapped_content(cols=72)
      self.content.gsub(/(.{1,#{cols}})/, "\\1\n").strip	
    end
    
    private
    
    def clean_content!
      self.content.to_s.gsub!(/(\r|\n)*/m, "")
      self.checksum = Digest::SHA1.hexdigest(self.content)
    end
    
    def really_valid?
      temp_key = Tempfile.new("ssh_key_#{Time.now.to_i}")
      temp_key.write(self.content)
      temp_key.close
      system("ssh-keygen -l -f #{temp_key.path}")
      temp_key.delete
      $?.success?
    end
  end
end
