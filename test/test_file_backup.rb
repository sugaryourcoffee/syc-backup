require 'test/unit'
require 'shoulda'
require 'fileutils'
require_relative '../lib/backup/file_backup.rb'

# Tests the FileBackup class.
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
        backup_files = fbu.compress(["a","b","c"], "test/backup")
        flunk "expected error code 2"
      rescue SystemExit => e
        assert_equal 2, e.status
      end
    end
  end

  context "Providing valid user input" do

    # Create files to be backed up
    def setup
      ["file1", "file2", "file3"].each {|f| FileUtils.touch f}
    end

    # Remove files previously created with setup and all created files and
    # directories during processing backups
    def teardown
      ["file1", "file2", "file3"].each {|f| FileUtils.rm f}
      Dir["test/backup/file*"].each {|f| FileUtils.rm f}
      Dir["test/backup/*.tar.gz"].each {|f| FileUtils.rm f}
      Dir.rmdir "test/backup" if File.exists? "test/backup"
    end

    should "backup file in specified folder" do
      fbu = Backup::FileBackup.new(["file1"])
      backup_files = fbu.backup("test/backup")
      assert_equal ["test/backup/file1"], backup_files
    end

    should "return compressed file in specified folder" do
      fbu = Backup::FileBackup.new(["file1", "file2", "file3"])
      backup_files = fbu.backup("test/backup/")
      assert_equal 0, fbu.compress(backup_files, "test/backup")
    end

  end

end
