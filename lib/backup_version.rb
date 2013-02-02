# Backup contains functions to backup a MySQL database and files and directories
# to a default or specified backup directory. Instead of instant backup the
# invoked command can be added to a crontab and invoked based on the provided
# schedule that is a parameter of the --cron option. The backed up files are
# per default compressed but this can be ommitted
module Backup
  # Version of the application
  VERSION = '0.0.4'
end
