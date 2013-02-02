require 'fileutils'
require 'open3'

# Backup contains functions to backup a MySQL database and files and directories
# to a default or specified backup directory. Instead of instant backup the
# invoked command can be added to a crontab and invoked based on the provided
# schedule that is a parameter of the --cron option. The backed up files are
# per default compressed but this can be ommitted
module Backup

  # Backup directories and files to a backup directory
  class FileBackup

    # Initializes the files to be backed up. If no file is provided an error
    # is returned
    def initialize(files=[])
      @files = files
    end

    # Compress the files to the backup directory
    def compress(files, backup_folder)
      inexistent_files = check_for_inexistent files
      unless inexistent_files.empty?
        STDERR.puts "Cannot compress inexistent files"
        STDERR.puts "Following #{inexistent_files.size} file(s) do not exist"
        STDERR.puts inexistent_files.join(" ")
        exit 2
      end

      timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
      backup_folder += '/' unless backup_folder.match(/.*\/\Z/)
      compress_file = backup_folder + timestamp + "_" + "files.tar.gz"

      tar_command = "tar cfz #{compress_file} " + files.join(" ")

      stdout_str, stderr_str, status = Open3.capture3(tar_command)

      unless status.exitstatus == 0
        STDERR.puts "There was a problem running tar command"
        STDERR.puts "--> #{tar_command}"
        STDERR.puts stderr_str
        exit(2)
      end

      status.exitstatus

    end

    # The files to be backed up are initilized when creating an instance of
    # FileBackup. These files are then backed up to the backup directory
    def backup(backup_folder)

      inexistent_files = []

      @files.each do |file|
        inexistent_files << file unless File.exists? file
      end

      unless inexistent_files.empty?
        STDERR.puts "Cannot backup inexistent files"
        STDERR.puts "Following #{inexistent_files.size} file(s) do not exist"
        STDERR.puts "#{inexistent_files.join(', ')}"
        exit 1
      end
      
      backup_folder += '/' unless backup_folder.match(/.*\/\Z/)
      
      Dir.mkdir backup_folder unless File.exists? backup_folder

      backup_files = []

      @files.each.with_index do |file, index|
        backup_files << backup_file = backup_folder+File.basename(file)
        FileUtils.cp file, backup_file
      end

      backup_files

    end

    # Checks if the files all exist. Files that do not exist are returned in
    # an Array
    def check_for_inexistent (files)
      inexistent_files = []
      files.each do |f|
        inexistent_files << f unless File.exists? f
      end

      inexistent_files
    end

  end

end
