require 'aws-sdk-core'

namespace :aws do

  BasePath = Dir.pwd # the Rakefile
  
  def read_data_file(name)
    begin
      File.readlines(data_path(name))
    rescue Errno::ENOENT
      []
    end
  end
  
  def data_path(name)
    File.join(BasePath, "data/#{name}.txt")
  end

  def truncate_file(path)
    f = File.new(path, "w+")
    f.close
  end
  
  namespace :ec2 do
    
    desc "create_security_group"
    task :create_security_group, [:region] => [:env] do |t, args|
      ec2 = Aws::EC2.new
      resp = ec2.create_security_group(
        group_name: "rstudio",
        description: "rstudio",
        )
    end
    
    desc "authorize_security_group_ingress"
    task :authorize_security_group_ingress, [:port, :cidr_ip, :region] => [:env] do |t, args|
      ec2 = Aws::EC2.new
      args.with_defaults(
        port: 8787,
        cidr_ip: '0.0.0.0/0'
      )
      
      resp = ec2.authorize_security_group_ingress(
        group_name: "rstudio",
        group_id: read_data_file('security_group')[0],
        source_security_group_name: "rstudio",
#        source_security_group_owner_id: "String",
        ip_protocol: "tcp",
        from_port: args.port,
        to_port: args.port,
        cidr_ip: args.cidr_ip,
        )
        
    end
      
    desc "create_image"
    task :create_image, [:instance_id, :region] => [:env] do |t, args|
      ec2 = Aws::EC2.new
      resp = ec2.create_image(
        dry_run: false,
        instance_id: args.instance_id,
        name: "RStudio#{Time.now.utc.strftime("%Y-%m-%d.%H%M%S")}",
        description: "Rstudio",
        )
      File.open(data_path('amis'), "w") { |f|
        resp[:instances].each { |i|
          f.write("#{resp}\n")
          puts "Created #{resp}"
          puts "Note: the output may not be valid. See the EC2 console to find the Rstudio AMI if it appears empty."
        }
      }
    end
      
    desc "describe_images"
    task :describe_images, [:region] => [:env] do |t, args|
      ec2 = Aws::EC2.new
      resp = ec2.describe_images(
        owners: [ENV['AWS_ACCOUNT_ID']],
      )
      col = "%-18s"
      printf(col * 4 + "\n", :IMAGE_ID, :STATE, :PUBLIC, :NAME)
      resp[:images].each { |i|
        printf(col * 4 + "\n", i[:image_id], i[:state], i[:public], i[:name])
        puts "\n"
      }
    end
  
    desc "run_instance"
    task :run_instance, [:image_id, :instance_type, :how_many, :region] => [:env] do |t, args|
      args.with_defaults(
        instance_type: 'm1.small',
        how_many: 1,
      )

      ec2 = Aws::EC2.new
      resp = ec2.run_instances(
        image_id: args.image_id,
        instance_type: args.instance_type,
        min_count: args.how_many,
        max_count: args.how_many,
        security_groups: ['rstudio'], # FIXME this is ignored in the run process ...
          # see http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/V20131015.html#run_instances-instance_method
      )
      File.open(data_path('instances'), "w") { |f|
        resp[:instances].each { |i|
          f.write("#{i[:instance_id]}\n")
          puts "Instance is starting: #{i[:instance_id]}"
        }
      }
    end
    
    desc "describe_instances"
    task :describe_instances, [:region] => [:env] do |t, args|
      instance_ids = args.extras
      ec2 = Aws::EC2.new
      
      resp = ec2.describe_instances(
        instance_ids: instance_ids,
      )
      col = "%-18s"
      printf(col * 5 + "\n", :INSTANCE_TYPE, :INSTANCE_ID, :IMAGE_ID, :STATE_NAME, :PUBLIC_IP_ADDRESS)
      resp[:reservations].each { |r|
        r[:instances].each { |i|
          next if i[:state][:name] == 'terminated'
          printf(col * 5 + "\n", i[:instance_type], i[:instance_id], i[:image_id], i[:state][:name], i[:public_ip_address])
          ip = i[:public_ip_address]
          puts "ssh -i #{ENV['AWS_SSH_KEY_PATH']} -l ubuntu #{ip}\n"
          puts "\n"
        }
      }
    end
    
    desc "terminate_instance"
    task :terminate_instance, [:instance_id, :region] => [:env] do |t, args|
      instance_ids = [args.instance_id] + args.extras
      ec2 = Aws::EC2.new
      
      resp = ec2.terminate_instances(
        instance_ids: instance_ids,
      )
      resp[:terminating_instances].each { |i|
        puts "#{i[:instance_id]} #{i[:current_state][:name]}"
      }
    end

  end

end
