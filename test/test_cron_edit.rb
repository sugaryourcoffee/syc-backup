require 'test/unit'
require 'shoulda'
require_relative '../lib/backup/cron_edit.rb'

# Test for CronEdit will add commands to the users crontab. After each test
# the test entries are removed. So the crontab should not be changed after a
# test.
# In case of changes to CronEdit that will lead to a system exit it might leave
# the crontab with test data. In that case you have to remove the test data 
# manually. But subsequent successfull runs should remove all test entries.
class TestCronEdit < Test::Unit::TestCase

  context "Crontab operation" do

    # Determines the count of the provided _command_ in the crontab.
    def crontab_count(command)
      content = `crontab -l`
      count = 0
      content.split(/\n/).each do |c|
        count += 1 if c == command
      end
      count
    end

    # Adds a command to crontab and checks that it is entered. Removes command
    # after test.
    should "add command to crontab" do
      ce = Backup::CronEdit.new
      command = "1 2 * * * ls -l"
      ce.add_command command
      assert_equal 1, crontab_count(command)
      ce.remove_command command
      assert_equal 0, crontab_count(command)
    end
    
    # Adds a command twice to crontab and expects that it is contained only
    # once. Removes added command at end of test
    should "not add duplicate command to crontab" do
      ce = Backup::CronEdit.new
      command = "2 2 2 * * syc-backup -d test -upierre -ppass"
      ce.add_command command
      assert_equal 1, crontab_count(command)
      ce.add_command command
      assert_equal 1, crontab_count(command)
      ce.remove_command command
      assert_equal 0, crontab_count(command)
    end
  end
end
