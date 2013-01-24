require 'test/unit'
require 'shoulda'
require_relative '../lib/backup/file_backup.rb'

class TestFileBackup < Test::Unit::TestCase

  context "Providing erroneous user input" do

    should "return error code 1 due to non existend file" do
      fbu = Backup::FileBackup.new(["f1"])
      begin
        backup_files = fbu.backup "test/backup"
      rescue SystemExit => e
        assert_equal 1, e.status
      end
    end

    should "return error code 1 due to non existend file within list" do
      fbu = Backup::FileBackup.new(["f1","f2","f3"])
      begin
        backup_files = fbu.backup "test/backup"
      rescue SystemExit => e
        assert_equal 1, e.status
      end
    end

    should "return error code 2 due to non existend file to compress" do
      fbu = Backup::FileBackup.new
      begin
        backup_files = fbu.compress ["a","b","c"]
        flunk "expected error code 2"
      rescue SystemExit => e
        assert_equal 2, e.status
      end
    end
  end

  context "Providing valid user input" do

    should "return backup file in default folder" do

    end

    should "return backup file in specified folder" do

    end

    should "return compressed file in default folder" do

    end

    should "return compressed file in specified folder" do

    end

  end

end
