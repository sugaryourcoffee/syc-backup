require 'optparse'

module Backup

  class Options
    DEFAULT_BACKUP_FOLDER = "~/backup/drupal"
    attr_accessor :database, :user, :password, :website_folder, 
                  :backup_folder, :cron

    def initialize(argv)
      @exit_code = 0
      parse(argv)
    end

    private

    # Checks the values provided in the array c whether they are valid cron 
    # values representing one of the values minute, hour, day of month, 
    # month or day of week. Allowed values are
    #   minute         0..59, *
    #   hour           0..23, *
    #   day of month   1..31, *
    #   month          1..12, *
    #   day of week    1..7 , *
    # If invalid values are detected bit 3 of exit_code is set and nil is
    # returned. Otherwise a cron time string like "30 3 * * *" is returned.
    def validate_cron_values(c)
      cron_values = [0..59, 0..23, 1..31, 1..12, 1..7]
      c.each.with_index do |v,i|
        unless cron_values[i].cover?(v.to_i) or v == '*'
          @exit_code |= 0b1000 
          return nil
        end
      end
      c.fill('*', c.size..4)
      c.join(' ')
    end

    # Check if all requested arguments are provided. If arguments are missing a
    # exit code not equal to 0 is set. Following exit codes are set
    #   Argument          Exit code
    #   database          0001
    #   user              0010
    #   password          0100
    #   cron              1000
    # If for instance the database and the user is missing the exit code will
    # return 3. And can be caught with
    #   begin
    #     opts = Options.new(ARGV)
    #   rescue ExitStatus => e
    #     puts "database missing" if e.status == 1
    #     puts "user missing"     if e.status == 2
    #     puts "password missing" if e.status == 4
    #     puts "cron invalid"     if e.status == 8
    #   end
    def check_for_missing_arguments
      @exit_code |= 0b0001 unless @database
      @exit_code |= 0b0010 unless @user
      @exit_code |= 0b0100 unless @password
    end

    # Initializes values as the backup folder with a default value if not
    # provided by the user
    def initialize_default_arguments_if_missing
      @backup_folder = DEFAULT_BACKUP_FOLDER unless @backup_folder
    end

    # Parses the user input and initializes the application
    def parse(argv)

      OptionParser.new do |opts|
        app_name = File.basename($PROGRAM_NAME)
        opts.banner = "Backup a Drupal website and its database\n\n"+
                      "Usage: #{app_name} [options] database_name"

        opts.on("-u", "--user USER", "User of the database") do |u|
          @user = u
        end
        
        opts.on("-p", "--password PASSWORD", 
                "User's password to access the database") do |p|
          @password = p
        end

        opts.on("-w", "--website WEBSITE",
                "The folder where the Drupal website lives") do |w|
          @website_folder = w
        end

        opts.on("-b", "--backup FOLDER",
                "Folder where to save the backup to") do |t|
          @backup_folder = t
        end

        opts.on("-c", "--cron min,hou,dom,mon,dow", Array,
                "Create a cron job that automatically ",
                "invokes #{app_name}",
                "min = minute        0..59",
                "hou = hour          0..23",
                "dom = day of month  1..31",
                "mon = month         1..12",
                "dow = day of week   1..7",
                "30,3,*,*,* will run the cron job at 3:30pm") do |c|
          @cron = validate_cron_values c.slice(0..4)
        end

        opts.on("-v", "--version", "Show version") do |v|
          puts OptionParser::Version.join('.')
          exit 0
        end

        opts.on("-h", "--help", "Show this message") do |h|
          puts opts
          exit 0
        end

        begin
          puts argv.empty?
          argv = ["-h"] if argv.empty?
          opts.parse!(argv)
        rescue OptionParser::ParseError => e
          STDERR.puts e.message, "\n", opts
          exit(-1)
        end

        @database = argv.shift

        check_for_missing_arguments
        exit(@exit_code) if @exit_code > 0

        initialize_default_arguments_if_missing 
      end

    end
  end
end
