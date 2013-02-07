require_relative 'options'
require_relative 'mysql_backup'
require_relative 'cron_edit'
require_relative 'process'
require_relative 'environment'

module Backup

  # Is invoked from the command line application and invokes the application's
  # optons as provided by the user on the command line
  class Runner

    # Takes the command line options and parses them
    def initialize(argv)
      @options = Options.new(argv)
    end

    # Operates on the options and invokes the respective functions
    def run
      if @options.cron
        create_cron
      elsif @options.database or @options.file
        create_backup
      end
    end

    private

    # Creates a cron job based on the provided options and the schedule
    # provided with the --cron flag
    def create_cron
      cron_edit = CronEdit.new
      command = cron_edit.add_command create_cron_command, Environment.ruby
      puts "--> added command to cron"
      puts "    #{command}"
    end

    # Creates the cron command based on the options provided by the user.
    def create_cron_command
      command = @options.cron + " sycbackup #{@options.backup_folder}"
      command += ' -d ' + @options.database + 
                 ' -u'  + @options.user + 
                 ' -p'  + @options.password if @options.database
      command += ' -f ' + @options.files.join(',') if @options.files
      command += ' -m ' + @options.max_backups if @options.max_backups
      command += ' --no-compress' if @options.no_compress
      command += ' --override' if @options.override

      command
    end

    # Backs up the files provided by the user on the command line. Provides a
    # summary of the backed up files
    def create_backup
      files = []
      if @options.database
        db_backup = MySQLBackup.new(@options.database, 
                                    @options.user,
                                    @options.password)
        files << db_backup.backup
      end
      
      files << @options.files if @options.files

      files.flatten!

      process = Process.new(@options.backup_folder,
                            files, 
                            @options.override, 
                            @options.no_compress,
                            @options.max_backups)
      process.backup
      puts "--> backed up files"
      puts "    #{files.join("\n    ")}"
      puts "--> to #{@options.backup_folder}"

      File.delete files[0] if @options.database
    end

  end
end
