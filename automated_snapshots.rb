#!/usr/bin/env ruby
  require 'yaml'
  
  CONFIG = YAML.load_file('config/config.yml')
  puts CONFIG
  
  # Command to create snapshots for instances
  def run_create_snapshot_for_instances
    if CONFIG['instance_ids'] != nil
      puts "==> about to run #{CONFIG['instance_ids']} #{CONFIG['region']} "
      %x(rake aws:ebs:snapshot:create_snapshots_from_instances[#{CONFIG['region']},#{CONFIG['instance_ids']}]) 
    end
       
  end

  # Command to delete snapshots for instances
  def run_delete_snapshot_for_instances
 	  days = CONFIG['retention_period_days'] 
 	  
    if days == nil
 	    week = CONFIG['retention_period_week']

      if week != nil
	      days = week * 7
      end

    end
    
    #set default 14 days if no inputs from user
    if days == nil
      days = 14
    end

	  if CONFIG['instance_ids'] != nil
      puts "==> about to run delete_snapshots_from_instances #{CONFIG['instance_ids']} #{days} #{CONFIG['region']} "
      %x(rake aws:ebs:snapshot:delete_snapshots_from_instances[#{CONFIG['region']},#{days},#{CONFIG['instance_ids']}])   
    end
  end
 
  # Command to create snapshots for images
  def run_create_snapshot_for_images
    if CONFIG['image_ids'] != nil
      puts "==> about to run create_snapshots_from_images #{CONFIG['image_ids']} #{CONFIG['region']} "
      %x(rake aws:ebs:snapshot:create_snapshots_from_images[#{CONFIG['region']},#{CONFIG['image_ids']}])   
    end
  end

  # Command to delete snapshots for images
  def run_delete_snapshot_for_images
 	  days = CONFIG['retention_period_days'] 
 	  if days == nil
 	    week = CONFIG['retention_period_week']
 	    if week != nil
        days = week * 7
      end
    end
    #set default 14 days if no inputs from user
    if days == nil
      days = 14
    end

    if CONFIG['image_ids'] != nil
      puts "==> about to run delete_snapshots_from_images #{CONFIG['image_ids']} #{days} #{CONFIG['region']} "
      %x(rake aws:ebs:snapshot:delete_snapshots_from_images[#{CONFIG['region']},#{days},#{CONFIG['image_ids']}])   
    end
  end

  run_create_snapshot_for_instances
  run_delete_snapshot_for_instances
  run_create_snapshot_for_images
  run_delete_snapshot_for_images