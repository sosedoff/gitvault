module Gitvault::CLI
  module Terminal
    # Prompt for input
    #
    # title - Prompt title
    # opts  - Prompt options
    #
    # opts[:default] - Provide the default value if input was empty
    # opts[:required] - Make input required
    #
    def ask(title, opts={})
      print("#{title}#{opts.key?(:default) ? " [#{opts[:default]}]" : ''}: ")
      result = gets.strip
      result = opts[:default] if result.empty? && opts.key?(:default)
      result = result.scan(/[a-z\d\_\-]{1,}/i) if opts.key?(:array)
      result.empty? && opts[:required] == true ? ask(title, opts) : result
    end
    
    # Prompt for password
    #
    def ask_password
      echo_off
      password = ask('Password', :required => true)
      puts
      echo_on
      return password
    end
    
    # Prompt for Y/N question
    #
    def ask_yesno(title, required='y', opts={})
      answer = ask("#{title} (y/n)", opts).downcase
      answer == required
    end
    
    # Prints an empty line N times
    #
    def empty_line(num=1)
      num.times { info("") }
    end
    
    # Regular prompt with prefix
    #
    def prompt(prefix='> ')
      print("#{prefix}")
      gets.strip
    end
    
    # Print an information message
    #
    # message - Information text
    # color - Specify message color (default: none)
    #
    def info(message, color=nil)
      message = message.send(color) unless color.nil?
      STDOUT.puts(message)
      STDOUT.flush
    end
    
    # Show success message
    #
    def success(message)
      info(message, :green)
    end
    
    # Show warning message
    #
    def warning(message)
      info(message, :yellow)
    end
    
    # Show error message
    #
    def error(title, exit_after=false)
      STDERR.puts(title.red)
      exit(1) if exit_after
    end
    
    # Print message
    #
    def display(message, newline=true)
      if newline
        STDOUT.puts(message)
      else
        STDOUT.print(message)
        STDOUT.flush
      end
    end
    
    # Execure shell command
    #
    def shell(cmd)
      FileUtils.cd(Dir.pwd) {|d| return `#{cmd}`}
    end
    
    # Disable terminal prompt
    #
    def echo_off
      system "stty -echo"
    end

    # Enable terminal prompt
    #
    def echo_on
      system "stty echo"
    end
  end
end