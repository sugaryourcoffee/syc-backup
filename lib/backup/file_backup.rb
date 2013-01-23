module Backup

  class FileBackup

    def initialize(files=[])
      @files = files
    end

    def compress(files)

    end

    def backup(backup_folder)

      inexistent_files = []

      @files.each do |file|
        inexistent_files << file unless File.exists? file
      end

      unless inexistent_files.empty?
        STDERR.puts "Following #{inexistent_files.size} file(s) do not exist"
        STDERR.puts "#{inexistent_files.join(', ')}"
        exit 1
      end

      Dir.mkdir backup_folder unless File.exists? backup_folder

      backup_files = []

      @files.with_index do |file, index|
        
      end

      backup_files

    end

  end

end
