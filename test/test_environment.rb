require 'test/unit'
require 'shoulda'
require_relative '../lib/backup/environment'

# Tests Environment class to return the variables neccessary for running a
# Ruby application as a cron job
class TestEnvironment < Test::Unit::TestCase

  context "Environment" do

    should "return specified environment variables" do
      vars = Backup::Environment::VARIABLES

      extract = Backup::Environment.ruby
      extract.each do |line|
        assert_includes vars, line.match(/\A\w+(?=\=)/).to_s.upcase
      end

    end

  end
end
