require 'aws-sdk-core'

# to run $rake aws:snapshot:create_snapshots[in-use,false,1024,mongo,us-west-2]
# It creates snapshot for multiple volumes with matching criteria for below arguments
# status - The status of the volume (creating | available | in-use | deleting | deleted | error)
# encrypted - The encryption status of the volume true | false 
# size - The size of the volume, in GiB     
# name - name to append for newly creates snapshots
# region - region to create snapshot

namespace :aws do

  namespace :snapshot do
         
    # return list of volume from AWS
    # status - The status of the volume (creating | available | in-use | deleting | deleted | error)
    # encrypted - The encryption status of the volume true | false 
    # size - The size of the volume, in GiB      
    # region - region to create snapshot
    def describe_volumes(status, encrypted, size, region)
      ec2 = Aws::EC2.new(region: region)
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
      volumeList =[]
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
    
    # create_snapshots - creates snaspshots for the multiple volumes in given region 
    # status - The status of the volume (creating | available | in-use | deleting | deleted | error)
    # encrypted - The encryption status of the volume true | false 
    # size - The size of the volume, in GiB      
    # name - name to append for newly creates snapshots
    # region - region to create snapshot

    desc "create_snapshots"
    task :create_snapshots, [:status, :encrypted, :size, :name,:region] => [:region] do |t, args|
      
      volumeList = describe_volumes(args.status,args.encrypted,args.size,args.region)
      
      volumeList.each { |element|

        create_snapshot(element,args.name,args.region)
      
      }

    end

    #creates snapshot for for given volume id and region
    def create_snapshot(volume_id, description, region)
      ec2 = Aws::EC2.new(region: region)
      resp = ec2.create_snapshot(
        volume_id: volume_id,
        description: "#{description}-#{Time.now.utc.strftime("%Y-%m-%d.%H%M%S")}",
      )
      puts "Created snapshot #{resp[:snapshot_id]} of volume #{volume_id}"
    end

  end

end
