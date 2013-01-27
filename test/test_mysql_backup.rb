require 'test/unit'
require 'shoulda'

require_relative '../lib/backup/mysql_backup.rb'

# Tests for MySQLBackup class.
# 
# Expects a running MySQL database server with following data
# table::    test
# user::     user
# password:: pass
#
class TestMySQLBackup < Test::Unit::TestCase

  context "Providing erroneous user input" do

    should "return error code 1 due to mysqldump error" do
      myb = Backup::MySQLBackup.new("database", "user", "password")
      begin
        myb.backup
        flunk(message="Expected a SystemExit!")
      rescue SystemExit => e
        assert_equal 1, e.status
      end
    end

    should "return error code 2 due to compress error" do
      myb = Backup::MySQLBackup.new("database", "user", "password")
      begin
        myb.compress("unexistent_file")
        flunk(message="Expected a SystemExit!")
      rescue SystemExit => e
        assert_equal 2, e.status
      end
    end

  end
  
  context "Providing valid user input" do

    setup do
      @mbu = Backup::MySQLBackup.new("test", "pierre", "pass")
    end

    teardown do
      Dir["test_*"].each { |file| File.delete file }
      Dir["test/backup/test_*"].each { |file| File.delete file }
      Dir.rmdir "test/backup" if File.exists? "test/backup"
    end

    should "create a database backup file in the default folder" do
      backup_file = @mbu.backup
      assert_match /\.\/test_\d{8}-\d{6}/, backup_file
    end

    should "create a database backup file in the provided backup folder" do
      backup_file = @mbu.backup("test/backup/")
      assert_match /test\/backup\/test_\d{8}-\d{6}/, backup_file
    end

    should "create a compressed file in the default folder" do
      backup_file = @mbu.backup
      assert 0 == @mbu.compress(backup_file)
    end
    
    should "create a compressed file in the provided backup folder" do
      backup_file = @mbu.backup("test/backup/")
      assert 0 == @mbu.compress(backup_file)
    end
  end
end
