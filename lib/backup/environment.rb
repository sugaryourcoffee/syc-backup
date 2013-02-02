module Backup

  # Reads and filters the user's environment variables to meet Ruby and Gem
  # requirements to run the application as a cron job
  class Environment

    # Contains the environment variable names that are required to run a Ruby
    # application from as a cron job
    VARIABLES = ["RVM_BIN_PATH",
                 "GEM_HOME",
                 "SHELL",
                 "MY_RUBY_HOME",
                 "USER",
                 "RVM_PATH",
                 "RVM_PREFIX",
                 "PATH",
                 "RVM_VERSION",
                 "HOME",
                 "LOGNAME",
                 "GEM_PATH",
                 "RUBY_VERSION"]

    # Retrieves the environment variables that are required running a Ruby
    # application as a cron job. The variable are returned in an Array
    def self.ruby
      file = ".current_environment.tmp"
      system ("env > #{file}")

      lines = []

      File.open(file, 'r') do |f|
        while line = f.gets
          variable = line.chomp.match(/\A\w+(?=\=)/).to_s
          lines << line.chomp if VARIABLES.find_index variable.upcase
        end
      end

      File.delete file

      lines
    end
    
  end
end
