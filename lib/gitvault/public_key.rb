require 'uuidtools'

module Gitvault
  class PublicKey
    include ActiveModel::Validations
    
    USAGE_TYPES = %w(user deploy)
    
    CONTENT_FORMAT = /^ssh\-[a-z]{3}\s\S+==(\s\S+)?$/.freeze
    COMMAND_OPTIONS = [
      'no-port-forwarding',
      'no-X11-forwarding',
      'no-agent-forwarding',
      'no-pty'
    ]
    
    attr_accessor :content, :description, :usage_type
    attr_accessor :uuid, :checksum
    
    validates :uuid,       :presence => true
    validates :content,    :presence => true, :format => {:with => CONTENT_FORMAT}
    validates :usage_type, :presence => true, :inclusion => {:in => USAGE_TYPES}
    
    def initialize(fields={})
      @content    = fields[:content].to_s.strip
      @uuid       = fields[:uuid] || UUIDTools::UUID.random_create.to_s.gsub('-', '')
      @usage_type = fields[:usage_type] || 'user'
      @checksum   = nil
      
      clean_content!
    end
    
    def to_hash
      {
        'uuid'       => self.uuid,
        'usage_type' => self.usage_type,
        'content'    => self.content,
        'checksum'   => self.checksum,
        'comment'    => self.content.split(' ').last
      }
    end
    
    def to_system_key(command)
      lines = []
      lines << "### START #{self.uuid} ###"
      lines << "command=\"#{command} #{self.usage_type}\",#{COMMAND_OPTIONS.join(",")} #{self.content}".strip
      lines << "### END #{self.uuid} ###"
      lines.join("\n")
    end
    
    def wrapped_content(cols=72)
      self.content.gsub(/(.{1,#{cols}})/, "\\1\n").strip	
    end
    
    private
    
    def clean_content!
      self.content.to_s.gsub!(/(\r|\n)*/m, "")
      unless self.content.empty?
        self.checksum = Digest::SHA1.hexdigest(self.content)
      end
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
