require 'aws-sdk-core'

namespace :aws do

  namespace :ec2 do

    desc "create_security_group"
    task :create_security_group, [:group_name, :region] => [:region] do |t, args|
      ec2 = Aws::EC2::Client.new
      resp = ec2.create_security_group(
        group_name: args.group_name,
        description: args.group_name,
        )
    end

    desc "describe_security_groups"
    task :describe_security_groups, [:region] => [:region] do |t, args|
      ec2 = Aws::EC2::Client.new
      resp = ec2.describe_security_groups()
      col = "%-18s"
      printf(col * 3 + "\n", :NAME, :ID, :DESCRIPTION)
      resp[:security_groups].each { |i|
        printf(col * 3 + "\n", i[:group_name], i[:group_id], i[:description] )
        i[:ip_permissions].each_with_index { |perm, ix|
          ranges = perm[:ip_ranges].map { |e| e[:cidr_ip] }.join(', ')
          printf(col * 5 + "\n", "rule #{ix})", perm[:ip_protocol], ranges, perm[:from_port], perm[:to_port] )
        }
        puts "\n"
      }
    end

    desc "describe_addresses"
    task :describe_addresses, [:region] => [:region] do |t, args|
      ec2 = Aws::EC2.new
      resp = ec2.describe_addresses()
      col = "%-18s"
      printf(col * 3 + "\n", :INSTANCE, :IP, :ALLOCATION, :ASSOCIATION, :DOMAIN)
      resp[:addresses].each { |i|
        printf(col * 3 + "\n", i[:instance_id], i[:public_ip], i[:allocation_id], i[:association_id], i[:domain] )
        puts "\n"
      }
    end

    desc "authorize_security_group_ingress"
    task :authorize_security_group_ingress, [:group_name, :port, :cidr_ip, :region] => [:region] do |t, args|
      ec2 = Aws::EC2::Client.new
      args.with_defaults(
        group_name: 'default',
        port: 80,
        cidr_ip: '0.0.0.0/0'
      )

      resp = ec2.authorize_security_group_ingress(
        group_name: args.group_name,
#        group_id: read_data_file('security_group')[0],
#        source_security_group_name: args.group_name,
#        source_security_group_owner_id: "String",
        ip_protocol: "tcp",
        from_port: args.port,
        to_port: args.port,
        cidr_ip: args.cidr_ip,
      )
    end

    desc "create_image"
    task :create_image, [:name, :instance_id, :region] => [:region] do |t, args|
      ec2 = Aws::EC2::Client.new
      resp = ec2.create_image(
        instance_id: args.instance_id,
        name: "#{args.name}-#{Time.now.utc.strftime("%Y-%m-%d.%H%M%S")}",
        description: args.name,
      )
      puts "Created new image #{resp[:image_id]}"
    end

    desc "copy_image"
    task :copy_image, [:name, :source_image_id, :source_region, :region] => [:region] do |t, args|
      ec2 = Aws::EC2::Client.new
      resp = ec2.copy_image(
        source_image_id: args.source_image_id,
        source_region: args.source_region,
        name: "#{args.name}-#{Time.now.utc.strftime("%Y-%m-%d.%H%M%S")}",
        description: args.name,
      )
      puts "Copied image #{resp[:image_id]} in region #{args.region}"
    end

    desc "describe_images"
    task :describe_images, [:region] => [:region] do |t, args|
      ec2 = Aws::EC2::Client.new
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

    desc "describe_volumes"
    task :describe_volumes, [:status, :encrypted, :size, :region] => [:region] do |t, args|
      ec2 = Aws::EC2::Client.new
      resp = ec2.describe_volumes(
        filters:[
          {
            name: 'status',
            values: [args.status],
          },
          {
            name: 'size',
            values: [args.size],
          },
          {
            name: 'encrypted',
            values: [args.encrypted],
          },
        ],
      )
      col = "%-18s"
      printf(col * 4 + "\n", :VOLUME_ID, :STATE, :SIZE, :ENCRYPTED)
      resp[:volumes].each { |i|
        printf(col * 4 + "\n", i[:volume_id], i[:state], i[:size], i[:encrypted])
        puts "\n"
      }
    end

    desc "run_instances"
    task :run_instances, [:image_id, :instance_type, :security_groups, :how_many, :region, :zone] => [:region] do |t, args|
      args.with_defaults(
        # instance_type: t1.micro|m1.small|m1.medium|m1.large|m1.xlarge
        # | m3.medium|m3.large|m3.xlarge|m3.2xlarge
        # | m2.xlarge|m2.2xlarge|m2.4xlarge
        # | cr1.8xlarge|i2.xlarge|i2.2xlarge|i2.4xlarge|i2.8xlarge|
        # | hi1.4xlarge|hs1.8xlarge
        # | c1.medium|c1.xlarge
        # | c3.large|c3.xlarge|c3.2xlarge|c3.4xlarge|c3.8xlarge|
        # | cc1.4xlarge|cc2.8xlarge|g2.2xlarge|cg1.4xlarge
        # | r3.large|r3.xlarge|r3.2xlarge|r3.4xlarge|r3.8xlarge

        instance_type: 'm1.small',
        security_groups: 'default',
        how_many: '1', # '2,5'
      )
      security_groups = args.security_groups.split('&')
      how_many = args.how_many.split('*')
      ec2 = Aws::EC2::Client.new
      resp = ec2.run_instances(
        image_id: args.image_id,
        instance_type: args.instance_type,
        security_groups: security_groups,
        min_count: how_many.first.to_i,
        max_count: how_many.last.to_i,
        placement: {
          availability_zone: "#{Aws.config[:region]}#{ENV['AWS_ZONE']}", # args are not propagated from the :region pre-task
        },
      )
      resp[:instances].each { |i|
        puts "Instance is starting: #{i[:instance_id]}"
      }
    end

    desc "describe_instances"
    task :describe_instances, [:region] => [:region] do |t, args|
      instance_ids = args.extras
      ec2 = Aws::EC2::Client.new

      resp = ec2.describe_instances(
        instance_ids: instance_ids,
      )
      col = "%-16s"
      headers = [:INSTANCE_TYPE, :INSTANCE_ID, :GROUPS, :IMAGE_ID, :STATE, :PUBLIC_IP, :LAUNCHED, :NAME]
      printf(col * headers.size + "\n", *headers)
      resp[:reservations].each { |r|
        groups = r[:groups].map { |e| e[:group_name] }.join(',')
        r[:instances].each { |i|
          next if i[:state][:name] == 'terminated'
          begin
            name = i[:tags].select { |e| e[0] == 'Name' }[0].value
          rescue
            name = nil
          end
          # FIXME use printf_describe(rec, column_width, *keys)
          data = [i[:instance_type], i[:instance_id], groups, i[:image_id], i[:state][:name], i[:public_ip_address], i[:launch_time], name].map { |e| "#{e}  " }
          printf(col * headers.size + "\n", *data)
          ip = i[:public_ip_address]
#          puts "ssh -i #{ENV['AWS_SSH_KEY_PATH']} -l ubuntu #{ip}\n"
          puts "\n"
        }
      }
    end

    desc "terminate_instances"
    task :terminate_instances, [:instance_id, :region] => [:region] do |t, args|
      instance_ids = [args.instance_id] + args.extras
      ec2 = Aws::EC2::Client.new
      resp = ec2.terminate_instances(
        instance_ids: instance_ids,
      )
      resp[:terminating_instances].each { |i|
        puts "#{i[:instance_id]} #{i[:current_state][:name]}"
      }
    end

  end

end
