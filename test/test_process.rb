require 'test/unit'
require 'shoulda'
require 'fileutils'
require_relative '../lib/backup/process.rb'

# Test for the Process class. Tests copy and compress commands
class TestProcess < Test::Unit::TestCase

  context "Process" do

    # Create files to backup
    def setup
      @files = ["file1", "file2", "file3"]
      @files.each {|f| FileUtils.touch f}
    end

    # Remove files that have created with setup and all files and directories
    # created during backup processing
    def teardown
      @files.each {|f| File.delete f}
      Dir["test/backup_p/*"].each {|f| File.delete f if File.file? f}
    end

    should "backup files to provided folder without compressing" do
      pro = Backup::Process.new("test/backup_p/", @files, false, true)
      pro.backup
      Dir["test/backup_p/*"].each do |f|
        assert_equal 1, @files.count(File.basename(f))
      end
    end

    should "compress files to provided folder" do
      pro = Backup::Process.new("test/backup_p/", @files, false, false)
      pro.backup
      assert_equal 1, Dir["test/backup_p/*.tar.gz"].size
    end

  end

end
