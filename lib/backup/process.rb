require 'open3'
require 'fileutils'

# The module Backup provides functions to backup MySQL databases and files and
# folders. The backup will be compressed to a default or a specified backup
# folder. Rather than backing up the files a cron job can be scheduled 
# invoking the provided command.
module Backup

  # Conducts the backups of a MySQL database and files.
  class Process

    # Takes the backup_folder where the files are backed up to. If override is
    # provided the files in the backup folder are overridden. no_compress will
    # prevent compressing the backed up files and will just copy them to the
    # provided backup folder
    def initialize(backup_folder, files, override, no_compress, max_backups = 9)
      @backup_folder = backup_folder
      @files = files
      @override = override
      @no_compress = no_compress
      @max_backups = max_backups
    end

    # Creates the backup of the database and the files. If at least one of the
    # provided files doesn't exist the application will print an error message
    # with the inexistent files and terminates
    def backup
      inexistent_files = check_for_inexistent_files
      unless inexistent_files.empty?
        STDERR.puts "Cannot backup inexistent files"
        STDERR.puts inexistent_files.join(" ")
        exit 1
      end

      FileUtils.mkdir_p @backup_folder unless File.exists? @backup_folder

      if @no_compress 
        copy_files 
        delete_uncompressed_backups
      else
        compress_files_and_copy
        delete_compressed_backups
      end

    end

    private

    # Checks if the compressed backups exceed the max backups denoted by 
    # @max_backups and respectively deletes the oldest files to meet the 
    # @max_backups count. @max_backups less than 1 is equivalent to infinite 
    # backup count, so no files will be deleted and 0 is returned otherwise 
    # the count of files deleted is returned.
    def delete_compressed_backups
      return 0 if @max_backups < 1

      pattern = "#{@backup_folder}*-*_syc-backup.tar.gz"
      files = Dir.glob(pattern).sort_by {|f| File.mtime(f)}
      
      file_count_to_delete = [0, files.count-@max_backups].max
      return 0 if file_count_to_delete == 0

      files.first(file_count_to_delete).each {|f| File.delete f}

      file_count_to_delete
    end

    # Checks if the uncompressed backups exceed the max backups denoted by 
    # @max_backups and respectively deletes the oldest files to meet the 
    # @max_backups count. @max_backups less than 1 is equivalent to infinite 
    # backup count, so no files will be deleted and 0 is returned otherwise 
    # the count of files deleted is returned.
    def delete_uncompressed_backups
    end

    # Checks if files to backup have been provided that don't exist. Returns the
    # inexistent files
    def check_for_inexistent_files
      inexistent_files = []
      @files.each do |file|
        inexistent_files << file unless File.exists? file
      end

      inexistent_files
    end

    # Copies the files to the backup folder. Is only invoked if --no-compress
    # is provided
    def copy_files
      @files.each do |file|
        basename = File.basename file
        FileUtils.cp file, @backup_folder + basename if File.file? file
        FileUtils.cp_r file, @backup_folder + basename if File.directory? file
      end
    end

    # Compresses the files and copies the compressed file to the backup folder.
    # The compression is done with
    #
    #     tar cfz backup_folder/YYYYmmdd-HHMMSS_syc-backup.tar.gz
    #
    # If an error occurs while compressing the error message of tar is
    # displayed and the application exits. If the method runs without errors
    # the tar file is returned
    def compress_files_and_copy
      timestamp = Time.now.strftime("%Y%m%d-%H%M%S") + '_'
      tar_file = @backup_folder + timestamp + "syc-backup.tar.gz" 
      tar_command = "tar cfz #{tar_file} #{@files.join(" ")}"

      stdout, stderr, status = Open3.capture3(tar_command)

      unless status.exitstatus == 0
        STDERR.puts "There was a problem executing command"
        STDERR.puts tar_command
        STDERR.puts stderr
        exit status.exitstatus
      end

      tar_file
    end

  end

end

