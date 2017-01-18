# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

env :PATH, '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

case environment
when 'stage'
  set :output, "/var/www/stage.nyccollegeline.org/shared/log/cron.log"
when 'production'
  set :output, {
    error: '/var/www/nyccollegeline.org/shared/log/cron_error.log',
    standard: '/var/www/nyccollegeline.org/shared/log/cron.log'
  }
else
  set :output, "log/cron_log.log"
end



every 1.day, :at => '12:30 am' do
  command "cd /var/www/nyccollegeline.org/current && backup perform -t nyc_collegeline_production_backup --config-file config/production/backup/backup.rb >> ../../shared/log/backup.log"
end

every 1.day, :at => '12:10 am'  do 
  rake "survey:survey_template"
end	


