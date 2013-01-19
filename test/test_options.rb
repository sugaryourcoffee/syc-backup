require 'test/unit'
require 'shoulda'
require_relative '../lib/backup/options'

class TestOptions < Test::Unit::TestCase

  context "Erroneous user input" do
    should "return no error (exit code = 0) when no input is given" do
      begin
        opts = Backup::Options.new([])
      rescue SystemExit => e
        assert e.status == 0
      end
    end

    should "return error code 1 due to no database input" do
      begin
        opts = Backup::Options.new(["-u", "user", "-p", "pass"])
      rescue SystemExit => e
        assert e.status == 1
      end
    end

    should "return error code 2 due to missing user" do
      begin
        opts = Backup::Options.new(["database", "-p", "pass"])
      rescue SystemExit => e
        assert e.status == 2
      end
    end

    should "return error code 4 due to missing password" do
      begin
        opts = Backup::Options.new(["database", "-u", "user"])
      rescue SystemExit => e
        assert e.status == 4
      end
    end

    should "return error code 3 due to missing database and user" do
      begin
        opts = Backup::Options.new(["-p", "pass"])
      rescue SystemExit => e
        assert e.status == 3
      end
    end

    should "return error code 6 due to missing user and password" do
      begin
        opts = Backup::Options.new(["database"])
      rescue SystemExit => e
        assert e.status == 6
      end
    end

    should "return error code -1 due to wrong switch and flag" do
      begin
        opts = Backup::Options.new(["-x"])
      rescue SystemExit => e
        assert e.status == -1
      end
    end

    should "return error code -8 due to wrong cron values" do
      begin
        opts = Backup::Options.new(["database", "-u", "user", "-p", "pass",
                                    "-c", "60,24,32,*,d,e"])
      rescue SystemExit => e
        assert e.status == 8
      end
    end

  end

  context "Correct user input" do

    should "return database, user, password and default backup_folder" do
      opts = Backup::Options.new(["database", "-u", "user", "-p", "pass"])
      assert_equal "database", opts.database
      assert_equal "user", opts.user
      assert_equal "pass", opts.password
      assert_equal Backup::Options::DEFAULT_BACKUP_FOLDER, opts.backup_folder
    end

    should "return database and specified backup folder" do
      opts = Backup::Options.new(["database", "-u", "user", "-p", "pass",
                                  "-b", "~/backups/2013/drupal"])
      assert_equal "database", opts.database
      assert_equal "~/backups/2013/drupal", opts.backup_folder
    end

    should "return database and website folder" do
      opts = Backup::Options.new(["database", "-u", "user", "-p", "pass",
                                  "-w", "website"])
      assert_equal "database", opts.database
      assert_equal "website", opts.website_folder
    end

    should "return database, website folder and cron schedule" do
      opts = Backup::Options.new(["database", "-u", "user", "-p", "pass",
                                  "-w", "website", "-c", "15,3,*,*,*"])
      assert_equal "database", opts.database
      assert_equal "website", opts.website_folder
      assert_equal "15 3 * * *", opts.cron
    end

    should "return cron schedule even though to many arguments" do
      opts = Backup::Options.new(["database", "-u", "user", "-p", "pass",
                                  "-c", "15,3,*,1,7,*,*,a"])
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

  end

end
