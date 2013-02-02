require 'open3'

module Backup

  # Adds or removes a command to the user's crontab. To make sure that the
  # Ruby application is invoked as a cron job it needs the environment
  # variables that are available when run from command line. To meet these
  # requirements the environment variables are read and added to the crontab. If
  # variables already exist in the crontab they are overridden.
  class CronEdit

    # Temporary file that holds the entries to be written to the crontab
    CRON_ENTRIES_FILE = ".cron_entries"

    # Adds a command to the user's crontab. If the provided command is empty
    # add_command will exit the application with exit status -1.
    # The method uses the <tt>crontab -l</tt> and <tt>crontab file</tt> command.
    # If the crontab call fails the error message and exit status of 
    # <tt>crontab</tt> will be returned and the application exits
    def add_command(command, environment=[])
      command = command.strip.squeeze(" ")

      if command.empty?
        STDERR.puts "Cannot add empty command to cron"
        exit -1
      end
      
      read_crontab_command = 'crontab -l'

      stdout, stderr, status = Open3.capture3(read_crontab_command)

      entries = [] + environment

      stdout.split(/\n/).each do |entry| 
        entry = entry.strip.squeeze(" ")
        variable = entry.match(/\A\w+(?=\=)/).to_s
        unless variable.empty?
          entries << entry unless environment.grep(/\A#{variable}/)
        else
          entries << entry
        end
      end

      unless entries.include? command
        entries << command

        cron_entries_file = CRON_ENTRIES_FILE 
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

      command 

    end

    # Removes a command from the user's crontab. If the provided command is 
    # empty remove_command will exit the application with exit status -1.
    # The method uses the <tt>crontab -l</tt> and <tt>crontab file</tt> command.
    # If the crontab call fails the error message and exit status of 
    # <tt>crontab</tt> will be returned and the application exits
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

      command 

    end

    # Removes the CRON_ENTRIES_FILE after the values have been written to
    # crontab
    def cleanup
      File.delete CRON_ENTRIES_FILE if File.exists? CRON_ENTRIES_FILE
    end
  end
end
