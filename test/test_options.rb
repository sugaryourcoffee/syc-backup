require 'test/unit'
require 'shoulda'
require_relative '../lib/backup/options'

# Test that user input is correctly interpreted and provided to other classes
# over methods.
class TestOptions < Test::Unit::TestCase

  context "Erroneous user input" do
    should "return error code 16 due to missing database and files" do
      begin
        opts = Backup::Options.new(["--no-compress", "--override",
                                    "~/backup/old"])
      rescue SystemExit => e
        assert_equal 16, e.status
      end
    end

    should "return error code 16 due to no database input" do
      begin
        opts = Backup::Options.new(["-u", "user", "-p", "pass"])
      rescue SystemExit => e
        assert_equal 16, e.status
      end
    end

    should "return error code 2 due to missing user" do
      begin
        opts = Backup::Options.new(["-d", "database", "-p", "pass"])
      rescue SystemExit => e
        assert_equal 2, e.status
      end
    end

    should "return error code 4 due to missing password" do
      begin
        opts = Backup::Options.new(["-d", "database", "-u", "user"])
      rescue SystemExit => e
        assert_equal 4, e.status
      end
    end

    should "return error code 16 due to missing database and user" do
      begin
        opts = Backup::Options.new(["-p", "pass"])
      rescue SystemExit => e
        assert_equal 16, e.status
      end
    end

    should "return error code 6 due to missing user and password" do
      begin
        opts = Backup::Options.new(["-d", "database"])
      rescue SystemExit => e
        assert_equal 6, e.status
      end
    end

    should "return error code 1 due to missing database" do
      begin
        opts = Backup::Options.new(["-f", "a,b,c", "-u", "user", "-p", "pass"])
      rescue SystemExit => e
        assert_equal 1, e.status
      end
    end

    should "return error code 3 due to missing database and user" do
      begin
        opts = Backup::Options.new(["-f", "a", "-p", "pass"])
      rescue SystemExit => e
        assert_equal 3, e.status
      end
    end

    should "return error code -1 due to wrong switch and flag" do
      begin
        opts = Backup::Options.new(["-x"])
      rescue SystemExit => e
        assert_equal -1, e.status
      end
    end

    should "return error code -1 due to missing argument for -f" do
      begin
        opts = Backup::Options.new(["-f"])
      rescue SystemExit => e
        assert_equal -1, e.status
      end
    end

    should "return error code 8 due to wrong cron values" do
      begin
        opts = Backup::Options.new(["-d", "database", "-u", "user", "-p", 
                                    "pass", "--cron", "60,24,32,*,d,e"])
      rescue SystemExit => e
        assert_equal 8, e.status
      end
    end

  end

  context "Correct user input" do

    should "return database, user, password and default backup_folder" do
      default_backup_folder_exists = 
        File.exists? Backup::Options::DEFAULT_BACKUP_FOLDER
      opts = Backup::Options.new(["-d", "database", "-u", "user", "-p", "pass"])
      assert_equal "database", opts.database
      assert_equal "user", opts.user
      assert_equal "pass", opts.password
      unless default_backup_folder_exists
        assert_match Backup::Options::DEFAULT_BACKUP_FOLDER, opts.backup_folder
      else
        assert_match /#{Backup::Options::DEFAULT_BACKUP_FOLDER}\d{8}-\d{6}\//, 
                     opts.backup_folder
      end
    end

    should "return database and specified backup folder" do
      opts = Backup::Options.new(["-d", "database", "-u", "user", "-p", "pass",
                                  "~/backups/2013/drupal"])
      assert_equal "database", opts.database
      assert_equal File.expand_path("~/backups/2013/drupal/"),
                   File.expand_path(opts.backup_folder)
    end

    should "return database and file" do
      opts = Backup::Options.new(["-d", "database", "-u", "user", "-p", "pass",
                                  "-f", "file_a"])
      assert_equal "database", opts.database
      assert_equal "file_a", opts.files[0]
    end

    should "return database, files and cron schedule" do
      opts = Backup::Options.new(["-d", "database", "-u", "user", "-p", "pass",
                                  "-f", "file_a,file_b", 
                                  "--cron", "15,3,*,*,*"])
      assert_equal "database", opts.database
      assert_equal 2, opts.files.size
      assert_equal "15 3 * * *", opts.cron
    end

    should "return cron schedule even though too many arguments" do
      opts = Backup::Options.new(["-d", "database", "-u", "user", "-p", "pass",
                                  "--cron", "15,3,*,1,7,*,*,a"])
      assert_equal "15 3 * 1 7", opts.cron
    end

    should "return without error (error code = 0) and print version" do
      begin
        opts = Backup::Options.new(["-v"])
      rescue SystemExit => e
        assert e.status == 0
      end
    end

    should "return without error (error code = 0) and print help" do
      begin
        opts = Backup::Options.new(["-h"])
      rescue SystemExit => e
        assert e.status == 0
      end
    end

    should "return files provided by user" do
      opts = Backup::Options.new(["-f", "a,b,c"])
      assert_equal ["a","b","c"], opts.files
    end

    should "return files stripped off trailing and leading blanks" do
      opts = Backup::Options.new(["-f", "a, b, c "])
      assert_equal ["a","b","c"], opts.files
    end

    should "return override" do
      opts = Backup::Options.new(["-f", "a,b,c", "~/backup/new", 
                                  "--override"])
      assert_equal ["a","b","c"], opts.files
      assert_equal true, opts.override
    end

    should "return no-compress" do
      opts = Backup::Options.new(["-f", "a,b,c", "--no-compress"])
      assert_equal true, opts.no_compress
    end

  end

end
