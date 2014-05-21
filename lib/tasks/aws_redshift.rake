require 'aws-sdk-core'

namespace :aws do
  
  namespace :redshift do
    
    desc "create_cluster"
    task :create_cluster, [:db_user, :db_pass, :db_name, :cluster_identifier, :number_of_nodes, :node_type, :region] => [:region] do |t, args|
      args.with_defaults(
        db_name: 'development',
        node_type: 'dw.hs1.xlarge',
        cluster_type: 'single-node',
        number_of_nodes: 2, # only used with multi-node # FIXME is this being used & overriding single-node?
      )
      args.with_defaults(
        cluster_identifier: "#{args.db_name}#{timestamp_for_name}"
      )

      redshift = Aws::Redshift.new
      resp = redshift.create_cluster(
        db_name: args.db_name,
        # required
        cluster_identifier: args.cluster_identifier,
        cluster_type: 'multi-node',
        # required
        node_type: args.node_type, # dw.hs1.xlarge | dw.hs1.8xlarge
        # required
        master_username: args.db_user,
        # required
        master_user_password: args.db_pass,
        # cluster_security_groups: [],
        # vpc_security_group_ids: [],
        # cluster_subnet_group_name: args.cluster_subnet_group_name,
        # availability_zone: args.availability_zone,
        # preferred_maintenance_window: args.preferred_maintenance_window,
        # cluster_parameter_group_name: args.cluster_parameter_group_name,
        # automated_snapshot_retention_period: args.automated_snapshot_retention_period,
        # port: args.port, # Default: 5439
        # cluster_version: args.cluster_version,
        # allow_version_upgrade: true,
        number_of_nodes: args.number_of_nodes,
        # publicly_accessible: true,
        # encrypted: false,
        # hsm_client_certificate_identifier: args.hsm_client_certificate_identifier,
        # hsm_configuration_identifier: args.hsm_configuration_identifier,
        # elastic_ip: args.elastic_ip,
      )
      printf_describe(resp[:cluster], 30, :cluster_identifier, :db_name)
    end
    
    desc "delete_cluster"
    task :delete_cluster, [:cluster_identifier, :final_cluster_snapshot_identifier, :region] => [:region] do |t, args|
      redshift = Aws::Redshift.new
      resp = redshift.delete_cluster(
        # required
        cluster_identifier: args.cluster_identifier,
        skip_final_cluster_snapshot: args.final_cluster_snapshot_identifier.nil?, # FIXME indeterminate behavior here
        final_cluster_snapshot_identifier: args.final_cluster_snapshot_identifier,
      )
     puts "#{resp[:cluster][:cluster_identifier]} : #{resp[:cluster][:cluster_status]}"
    end
    
    # desc "describe_cluster_versions"
    # task :describe_cluster_versions, [:region] => [:region] do |t, args|
    #   redshift = Aws::Redshift.new
    #   resp = redshift.describe_cluster_versions(
    #     cluster_version: args.cluster_version,
    #     cluster_parameter_group_family: args.cluster_parameter_group_family,
    #     max_records: args.max_records,
    #     marker: args.marker,
    #   )
    # end
    
    desc "describe_clusters" # cluster_identifier="development2014-04-12-01-16-33
    task :describe_clusters, [:cluster_identifier, :region] => [:region] do |t, args|
      redshift = Aws::Redshift.new
      resp = redshift.describe_clusters(
#        cluster_identifier: args.cluster_identifier,
        # max_records: args.max_records,
        # marker: args.marker,
      )
      resp[:clusters].each { |cluster|
        printf_describe(cluster, 30, :cluster_status, :master_username, :db_name)
        puts "#{cluster[:endpoint][:address]}:#{cluster[:endpoint][:port]}\n"
        puts "\n"
      }
    end
    
    # desc "describe_orderable_cluster_options"
    # task :describe_orderable_cluster_options, [:region] => [:region] do |t, args|
    #   redshift = Aws::Redshift.new
    #   resp = redshift.describe_orderable_cluster_options(
    #     cluster_version: args.cluster_version,
    #     node_type: args.node_type,
    #     max_records: args.max_records,
    #     marker: args.marker,
    #   )
    # end
    
    # desc "modify_cluster"
    # task :modify_cluster, [:region] => [:region] do |t, args|
    #   redshift = Aws::Redshift.new
    #   resp = redshift.modify_cluster(
    #     # required
    #     cluster_identifier: args.cluster_identifier,
    #     cluster_type: args.cluster_type,
    #     node_type: args.node_type,
    #     number_of_nodes: args.number_of_nodes,
    #     cluster_security_groups: ["String", '...'],
    #     vpc_security_group_ids: ["String", '...'],
    #     master_user_password: args.master_user_password,
    #     cluster_parameter_group_name: args.cluster_parameter_group_name,
    #     automated_snapshot_retention_period: args.automated_snapshot_retention_period,
    #     preferred_maintenance_window: args.preferred_maintenance_window,
    #     cluster_version: args.cluster_version,
    #     allow_version_upgrade: true || false,
    #     hsm_client_certificate_identifier: args.hsm_client_certificate_identifier,
    #     hsm_configuration_identifier: args.hsm_configuration_identifier,
    #   )
    # end
    
    desc "reboot_cluster"
    task :reboot_cluster, [:cluster_identifier, :region] => [:region] do |t, args|
      redshift = Aws::Redshift.new
      resp = redshift.reboot_cluster(
        # required
        cluster_identifier: args.cluster_identifier,
      )
    end

  end

end
