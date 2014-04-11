require 'aws-sdk-core'

namespace :aws do

  namespace :iam do
    
    desc "add_user_to_group"
    task :add_user_to_group, [:group_name, :user_name] do |t, args|
      iam = Aws::IAM.new(region: 'us-east-1')
      resp = iam.add_user_to_group(
        group_name: args.group_name,
        user_name: args.user_name,
      )
    end

    desc "create_group"
    task :create_group, [:group_name] do |t, args|
      iam = Aws::IAM.new(region: 'us-east-1')
      resp = iam.create_group(
        group_name: args.group_name
      )
    end

    desc "create_user"
    task :create_user, [:user_name] do |t, args|
      iam = Aws::IAM.new(region: 'us-east-1')
      resp = iam.create_user(
        user_name: "userNameType",
      )
    end

    desc "delete_group"
    task :delete_group, [:group_name] do |t, args|
      iam = Aws::IAM.new(region: 'us-east-1')
      resp = iam.delete_group(
        group_name: args.group_name
      )
    end

    desc "put_group_policy"
    task :put_group_policy, [:group_name, :policy_name, :policy_document] do |t, args|
      iam = Aws::IAM.new(region: 'us-east-1')
      resp = iam.put_group_policy(
        group_name: args.group_name,
        policy_name: args.policy_name,
        policy_document: args.policy_document,
      )
    end
    
    desc "remove_user_from_group"
    task :remove_user_from_group, [:group_name, :user_name] do |t, args|
      iam = Aws::IAM.new(region: 'us-east-1')
      resp = iam.remove_user_from_group(
        group_name: args.group_name,
        user_name: args.user_name,
      )
    end

  end

end
