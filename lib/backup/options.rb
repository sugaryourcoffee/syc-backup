require 'optparse'

module Backup

  # Parses the command line options the user has provided on the command line
  class Options
    # If the user doesn't provide a backup folder a default folder is used
    DEFAULT_BACKUP_FOLDER = File.expand_path("~/backup/")
    attr_accessor :database, :user, :password, :files, 
                  :backup_folder, :override, :cron, :no_compress

    # Takes the arguments from the command line and parses them
    def initialize(argv)
      @exit_code = 0
      init_exit_messages
      parse(argv)
    end

    private

    # Initializes the error messages belonging to the error codes
    def init_exit_messages
      @exit_message = {"1"  => "Database missing", 
                       "2"  => "User missing", 
                       "4"  => "Password missing",
                       "8"  => "Invalid cron data",
                       "16" => "Missing database or files"}
    end

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
    #   database           00001
    #   user               00010
    #   password           00100
    #   cron               01000
    #   files and database 10000
    # If for instance the database and the user is missing the exit code will
    # return 3. And can be caught with
    #   begin
    #     opts = Options.new(ARGV)
    #   rescue ExitStatus => e
    #     puts "database missing"                 if e.status == 1
    #     puts "user missing"                     if e.status == 2
    #     puts "password missing"                 if e.status == 4
    #     puts "cron invalid"                     if e.status == 8
    #     puts "ether database or files required" if e.status == 16
    #   end
    def check_for_missing_arguments
      if not @database and not @files
        @exit_code |= 0b10000
      elsif @database or @user or @password
        @exit_code |= 0b00001 unless @database
        @exit_code |= 0b00010 unless @user
        @exit_code |= 0b00100 unless @password
      end
    end

    # Initializes values as the backup folder with a default value if not
    # provided by the user
    def initialize_default_arguments_if_missing
      unless @override
        timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
        if @backup_folder and File.exists?(@backup_folder)
          @backup_folder = File.dirname(@backup_folder) + '/' +
                           File.basename(@backup_folder) + '_' + timestamp
        end
      end
      @backup_folder = DEFAULT_BACKUP_FOLDER unless @backup_folder
      @backup_folder = File.expand_path(@backup_folder)
      @backup_folder += '/' unless @backup_folder.match(/.*\/\Z/)
    end

    # Parses the user input and initializes the application
    def parse(argv)

      OptionParser.new do |opts|
        app_name = File.basename($PROGRAM_NAME)
        opts.banner = "Backup files and a database to a backup folder\n\n"+
                      "Usage: #{app_name} [options] [backup_folder]"

        opts.on("-d", "--database DATABASE", "Database to backup") do |d|
          #puts "database = #{d}"
          @database = d
        end

        opts.on("-u", "--user USER", "User of the database") do |u|
          #puts "user = #{u}"
          @user = u
        end
        
        opts.on("-p", "--password PASSWORD", 
                "User's password to access the database") do |p|
          #puts "password = #{p}"
          @password = p
        end

        opts.on("-f", "--file f1,f2,f3", Array,
                "A list of files to backup") do |f|
          @files = f.map {|f| f.strip}
        end

        opts.on("--no-compress",
                "Do not compress the backed up files",
                "and database") do |n|
          @no_compress = true
        end

        opts.on("--override", "Override the backup folder if it exists") do |o|
          @override = true
        end

        opts.on("--cron min,hou,dom,mon,dow", Array,
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
          opts.parse!(argv)
        rescue OptionParser::ParseError => e
          STDERR.puts e.message, "\n", opts
          exit(-1)
        end

        @backup_folder = argv.shift

        check_for_missing_arguments

        @exit_code.size.times do |i|
          result = @exit_code & 0b00001 << i
          STDERR.puts @exit_message[result.to_s] if result > 0
        end
        
        if @exit_code > 0
          puts opts
          exit(@exit_code) 
        end
        
        initialize_default_arguments_if_missing 
      end

    end
  end
end
