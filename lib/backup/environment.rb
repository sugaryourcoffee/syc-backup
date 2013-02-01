module Backup

  class Environment

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

    def self.extract_from(file)
      lines = []

      File.open(file, 'r') do |f|
        while line = f.gets
          variable = line.chomp.match(/\A\w+(?=\=)/)
          lines << line.chomp if environment.find_index variable.upcase
        end
      end

      lines
    end
    
  end
end
