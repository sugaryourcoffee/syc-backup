require 'open3'

module Backup

  class MySQLBackup

    def initialize(database, user, password)
      @database = database
      @user = user
      @password = password
    end

    def compress(backup_file)
      tar_file = backup_file + '.tar.gz'
      tar_command = "tar cfz #{tar_file} #{backup_file}"
      stdout_str, stderr_str, status = Open3.capture3(tar_command)
      unless status.exitstatus == 0
        File.delete tar_file if File.exists? tar_file
        STDERR.puts "There was a problem compressing the backup file"
        STDERR.puts "-->#{tar_command}"
        STDERR.puts stderr_str
        exit(2)
      end

      status.exitstatus

    end

    def backup(backup_folder="./")
      Dir.mkdir backup_folder unless File.exists? backup_folder

      timestamp = Time.now.strftime('%Y%m%d-%H%M%S')
      backup_file = backup_folder + @database + '_' + timestamp + '.sql'
      mysqldump = "mysqldump -u#{@user} -p#{@password} #{@database}"

      backup_command = "#{mysqldump} > #{backup_file}"
      stdout_str, stderr_str, status = Open3.capture3(backup_command)
      unless status.exitstatus == 0
        File.delete backup_file if File.exists? backup_file
        STDERR.puts "There was a problem running mysqldump"
        STDERR.puts "--> #{backup_command}"
        STDERR.puts stderr_str
        exit(1)
      end

      backup_file

    end

  end
end
