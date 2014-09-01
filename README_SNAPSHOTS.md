# Automate ebs volume snapshots  

# Installation
    1. Clone repository   
    2. Execute bundle install 

# Configure
In config folder you will find some sample configuration files with the naming pattern **.sample**, copy all of those files removing .sample from the name.
    1. Update config/config.yml with the configuration required to find out the volumes for snapshot. 
    2. Update config/schedule.rb for schedule to call create/delete snapshots.
    3. Configure aws credentials in config/aws_credentials.sh and copy it to home directory
        cp config/aws_credentials.sh.sample ~/aws_credentials.sh
        echo "source ~/aws_credentials.sh" >> ~/.bash_profile
    4. run command "whenever --update-crontab" in project directory
    5. run command "crontab -l" to verify newly added cron job

## Usage
Create and delete snapshots on weekely, daily or hourly basis.  

# Rake Task User Guide
See `rake -T aws:cf` for available rake tasks. Below are some details of snapshot related task.  
    1. create snapshots by instance id.
        - rake aws:ebs:snapshot:create_from_instances[Region,instance-id,instance-id......] --
        - instance-id - AWS EC2 instance id
        Example : rake aws:ebs:snapshot:create_from_instances[us-west-2,i-3e045135,i-4e04513]
  
    2. create snapshots by image id
        - rake aws:ebs:snapshot:create_from_images[Region,AMI-ID,AMI-ID...]
        - AMI-ID - AWS image id
        Example : rake aws:ebs:snapshot:create_from_images[us-west-2,ami-9b6125ab,ami-4brw45wb]


    3. delete snapshots by instance id and retention period.
        - rake aws:ebs:snapshot:delete_from_instances[us-west-2,retention_period_in_days,instance-id,instance-id..]
        - retention_period_in_days = 0 means delete all available snapshots
        Example : rake aws:ebs:snapshot:delete_from_instances[us-west-2,14,i-3e045135]
  
    4. delete snapshots by image id and retention period
        - rake aws:ebs:snapshot:delete_from_images[us-west-2,retention_period_in_days,instance-id,instance-id..]
        - retention_period_in_days = 0 means delete all available snapshots
        Example : rake aws:ebs:snapshot:delete_from_images[us-west-2,14,i-3e045135]
