require 'open3'

module Backup

  # Adds or removes a command to the user's crontab.
  class CronEdit

    CRON_ENTRIES_FILE = ".cron_entries"

    # Adds a command to the user's crontab. If the provided command is empty
    # add_command will exit the application with exit status -1.
    # The method uses the _crontab -l_ and _crontab file_ command. If the
    # crontab call fails the error message and exit status of _crontab_ will
    # be returned and the application exits
    def add_command(command)
      command = command.strip.squeeze(" ")

      if command.empty?
        STDERR.puts "Cannot add empty command to cron"
        exit -1
      end
      
      read_crontab_command = 'crontab -l'

      stdout, stderr, status = Open3.capture3(read_crontab_command)

      entries = stdout.split(/\n/).each {|entry| entry.strip.squeeze(" ")}

      unless entries.include? command
        entries << command

        cron_entries_file = CRON_ENTRIES_FILE #'.cron_entries'
        File.open(cron_entries_file, 'w') do |f|
          entries.each {|entry| f.puts entry}
        end

        write_crontab_command = "crontab #{cron_entries_file}"

        stdout, stderr, status = Open3.capture3(write_crontab_command)

        cleanup

        unless status.exitstatus == 0
          STDERR.puts "There is a problem executing command"
          STDERR.puts write_crontab_command
          STDERR.puts stderr
          exit status.exitstatus
        end
      end

      status.exitstatus

    end

    # Removes a command from the user's crontab. If the provided command is 
    # empty remove_command will exit the application with exit status -1.
    # The method uses the _crontab -l_ and _crontab file_ command. If the
    # crontab call fails the error message and exit status of _crontab_ will
    # be returned and the application exits
    def remove_command(command)
      command = command.strip.squeeze(" ")

      if command.empty?
        STDERR.puts "Cannot delete empty command from crontab"
        exit -1
      end

      read_crontab_command = "crontab -l"

      stdout, stderr, status = Open3.capture3(read_crontab_command)

      unless status.exitstatus == 0
        STDERR.puts "There is a problem executing command"
        STDERR.puts read_crontab_command
        STDERR.puts stderr
        exit status.existatus
      end

      entries = stdout.split(/\n/).each {|entry| entry.strip.squeeze(" ")}

      entries.delete(command)

      cron_entries_file = CRON_ENTRIES_FILE #".cron_entries"

      File.open(cron_entries_file, 'w') do |file|
        entries.each {|entry| file.puts entry}
      end

      write_crontab_command = "crontab #{cron_entries_file}"

      stdout, stderr, status = Open3.capture3(write_crontab_command)

      cleanup

      unless status.exitstatus == 0
        STDERR.puts "There is a problem executing command"
        STDERR.puts write_crontab_command
        STDERR.puts stderr
        exit status.exitstatus
      end

      status.exitstatus

    end

    def cleanup
      File.delete CRON_ENTRIES_FILE if File.exists? CRON_ENTRIES_FILE
    end
  end
end
