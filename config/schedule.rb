# Use this file to easily define all of your icron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
 set :output, "#{File.expand_path("../../logs", __FILE__)}/cron_log.log"
#
   every 1.hours do

      command "cd #{File.expand_path("../../", __FILE__)} && ruby  automated_snapshots.rb"

   end
#

#  every 1.day, :at => '1:00 am' do

#     command "cd #{File.expand_path("../../", __FILE__)} && ruby  automated_snapshots.rb"

#  end


#  every :sunday, :at => '12pm' do

#     command "cd #{File.expand_path("../../", __FILE__)} && ruby  automated_snapshots.rb"

#  end

# Learn more: http://github.com/javan/whenever
