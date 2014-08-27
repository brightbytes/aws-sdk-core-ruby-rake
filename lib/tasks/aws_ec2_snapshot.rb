require 'aws-sdk-core'

namespace :aws do

  namespace :ec2 do
  
    namespace :snapshot do

      desc "create_snapshot"
      task :create_snapshot, [:volume_id, :description, :region] => [:region] do |t, args|
        ec2 = Aws::EC2::Client.new
        resp = ec2.create_snapshot(
          volume_id: args.volume_id,
          description: "#{args.description}-#{Time.now.utc.strftime("%Y-%m-%d.%H%M%S")}",
        )
        puts "Created snapshot #{resp[:snapshot_id]} of volume #{args.volume_id}"
      end
    
      desc "delete_snapshot"
      task :delete_snapshot, [:snapshot_id, :region] => [:region] do |t, args|
        ec2 = Aws::EC2::Client.new
        resp = ec2.delete_snapshot(
          snapshot_id: args.snapshot_id,
        )
        puts "Deleted snapshot #{args.snapshot_id}"
      end

    end 
   
  end

end
