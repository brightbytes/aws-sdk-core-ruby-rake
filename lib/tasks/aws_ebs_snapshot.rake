require 'aws-sdk-core'

namespace :aws do

  namespace :ebs do
  
    namespace :snapshot do

      #captures snapshot for given volume id
      desc "create_snapshot"
      task :create_snapshot, [:volume_id, :description, :region] => [:region] do |t, args|
        create_snapshot(args.volume_id, args.description, args.region)
      end
    
      #deletes  snapshot 
      desc "delete_snapshot"
      task :delete_snapshot, [:snapshot_id, :region] => [:region] do |t, args|
        delete_snapshot(args.snapshot_id, args.region)
      end
    
      # create_snapshots - creates snaspshots for the multiple volumes in given region with some filters
      # status - The status of the volume (creating | available | in-use | deleting | deleted | error)
      # encrypted - The encryption status of the volume true | false 
      # size - The size of the volume, in GiB      
      # region - region to create snapshot
      # this task filters out volumes with above parameters and captures snapshots of all
      desc "create_snapshots"
      task :create_snapshots, [:status, :encrypted, :size, :region] => [:region] do |t, args|
          volumeList = describe_volumes(args.status, args.encrypted, args.size, args.region)
          capture_snapshots(volumeList,  args.region)
      end

      # create_snapshots - creates snaspshots for the volumes attached to instances  
      # instanceId - List of instances to create snapshot
      desc "create_snapshots_from_instances"
      task :create_snapshots_from_instances, [:region, :instanceId] => [:region] do |t, args|
        instanceList = args.extras
        instanceList.push(args.instanceId)

        instanceList.each { |instance|
          volumeList = describe_instance_volumes(instance, args.region)
          capture_snapshots(volumeList, args.region)
        }
      end

      # create_snapshots - creates snaspshots for the volumes attached to instances created using image id 
      # imageId-  imageId to create snapshot
      desc "create_snapshots_from_images"
      task :create_snapshots_from_images, [:region, :imageId] => [:region] do |t, args|
        imageList = args.extras
        imageList.push(args.imageId)

        imageList.each { |imageId|
          instanceList = describe_instances(imageId, args.region)
          #capture snapshot for each instance volumes
          instanceList.each { |instance|
            volumeList = describe_instance_volumes(instance, args.region)
            capture_snapshots(volumeList,  args.region)
          }
        }
      end
      
      # delete_snapshots_from_images - deletes snaspshots for the volumes attached to instances created using image id 
      # imageId-  imageId to create snapshot
      desc "delete_snapshots_from_images"
      task :delete_snapshots_from_images, [:region, :retention_days, :imageId] => [:region] do |t, args|
        imageList = args.extras
        imageList.push(args.imageId)

        imageList.each { |image|
          instanceList = describe_instances(image, args.region)
          #capture snapshot for each instance volumes
          instanceList.each { |instance|
            volumeList = describe_instance_volumes(instance, args.region)
            #delete old snapshot or snapshot greater than restention days for each volumes
            delete_snapshots_for_volumes(volumeList, args.retention_days,  args.region)
          }
        }
      end
      
      # delete_snapshots_from_instances - deletes snaspshots for instances  
      # instanceId - instanceid to delete snapshot
      desc "delete_snapshots_from_instances"
      task :delete_snapshots_from_instances, [:region, :retention_days, :instanceId] => [:region] do |t, args|
            volumeList = describe_instance_volumes(args.instanceId, args.region)
            #delete old snapshot or snapshot greater than restention days for each volumes
            delete_snapshots_for_volumes(volumeList, args.retention_days,  args.region)
      end
      
      # return list of volume from AWS
      # status - The status of the volume (creating | available | in-use | deleting | deleted | error)
      # encrypted - The encryption status of the volume true | false 
      # size - The size of the volume, in GiB      
      # region - region to create snapshot
      def describe_volumes(status, encrypted, size, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.describe_volumes(
          filters:
          [
            {
              name: 'status',
              values: [status],
            },
            {
              name: 'size',
              values: [size],
            },
            {
              name: 'encrypted',
              values: [encrypted],
            },
          ],
        )
      
        volumeList = []
        col = "%-18s"
        printf(col * 4 + "\n", :VOLUME_ID, :STATE, :SIZE, :ENCRYPTED)
        resp[:volumes].each { |i|
          volumeList.compact!
          volumeList.push(i[:volume_id])
          printf(col * 4 + "\n", i[:volume_id], i[:state], i[:size], i[:encrypted])
          puts "\n"
        }
        volumeList
      end

      # return list of volume from AWS
      # instanceid - The status of the volume (creating | available | in-use | deleting | deleted | error)
      # region - AWS region for listing volumes
      def describe_instance_volumes(instanceId, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.describe_volumes(
          filters:
          [
            {
              name: 'attachment.instance-id',
              values: [instanceId],
            },
          ],
        )

        volumeList = []
        resp[:volumes].each { |i|
          #we do not captures snapshot for root volumes which is generally less than 10 GB
          next if i[:size] < 10
          volumeList.compact!
          volumeList.push(i[:volume_id])
          puts "Volume Id: #{i[:volume_id]}\n"
        }
        volumeList
      end

      # return list of instances from AWS created using given image id
      # imageId - image id for listing instances
      # region - AWS region for listing instances
      def describe_instances(imageId, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.describe_instances(
          filters:
          [
            {
              name: 'image-id',
              values: [imageId],
            },
          ],
        )
        
        instanceList = []
        resp[:reservations].each { |r|
          r[:instances].each { |i|
            next if i[:state][:name] == 'terminated'
            instanceList.push(i[:instance_id])
            puts "Instance Id :#{i[:instance_id]}\n"
          }
        }
        instanceList
      end
       
      #captures snapshots for given volume list
      def capture_snapshots(volumeList, region)

        volumeList.each { |volume|
          name = "Automated_Snapshot_#{volume}"
          create_snapshot(volume, name, region)
        }
      end
      
      #captures snapshots for given volume list
      def delete_snapshots_for_volumes(volumeList, retention_days, region)

        volumeList.each { |volume|
          snapshotList = describe_snapshots(volume, retention_days, region)

          snapshotList.each { |snapshot|
            delete_snapshot(snapshot, region)
          }

        }
      end
       
      def describe_snapshots(volumeId, retention_days, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.describe_snapshots(
          filters:
          [
            {
              name: 'volume-id',
              values: [volumeId],
            },
          ],
        )

        snapshotList = []
        resp[:snapshots].each { |i|
          #we do not captures snapshot for root volumes which is generally less than 10 GB
           currentTime = Time.now
           startTime = Time.at(i[:start_time])
           days = (currentTime - startTime).to_i / (24 * 60 * 60)
           puts "snapshot created Days :#{days} and Ret Days #{retention_days.to_i} \n"
           next if retention_days.to_i != 0 && days <= retention_days.to_i
           snapshotList.compact!
           snapshotList.push(i[:snapshot_id])
           puts "snapshot Id: #{i[:snapshot_id]}\n"
        }
        snapshotList
      end 

      #creates snapshot for  given volume id and region
      def create_snapshot(volume_id, description, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.create_snapshot(
          volume_id: volume_id,
          description: "#{description}-#{Time.now.utc.strftime("%Y-%m-%d.%H%M%S")}",
        )
        puts "Created snapshot #{resp[:snapshot_id]} of volume #{volume_id}"
      end

      #deletes snapshot for given snapshot_id
      def delete_snapshot(snapshot_id, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.delete_snapshot(
          snapshot_id: snapshot_id,
        )
        puts "Deleted snapshot #{snapshot_id}"
      end

    end 
   
  end

end
