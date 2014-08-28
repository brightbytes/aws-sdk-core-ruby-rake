# Automated ec2 volume snapshots  

## Installation

1. clone this repo to any location   
2. run bundle install 
3. update filter values in file config/config.yml to pick up volumes and create snapshots
4. update file config/schedule.rb to set the frequency of volume snapshots
5. update aws_credentials.sh with valid AWS Credentials 
6. source aws_credentials.sh using command $source aws_credentials.sh
7. Add source command in ~/.bashrc for cron job to use this credentials
   ------.bashrc------------
   .
   .
   source /full-path-to-project/aws_credentials.sh
   ------------------------- 
8. run command "whenever --update-crontab" in project directory
9. run command "crontab -l" to verify newly added cron job


## Usage

Creates automated snapshot on weekely ,daily or hourly basis for volumes with mentioned criteria's  



# Rake Task User Guide

1] To create snapshots for volumes attached to specific instances
 
# rake aws:ebs:snapshot:create_snapshots_from_instances[Region,instance-id,instance-id......] --

# instance-id - AWS EC2 instance Id

 e.g rake aws:ebs:snapshot:create_snapshots_from_instances[us-west-2,i-3e045135,i-4e04513]
  
2] To create snapshots for volumes attached to instances created using specific AMI

#rake aws:ebs:snapshot:create_snapshots_from_images[Region,AMI-ID,AMI-ID...]

# AMI-ID - AWS image id

 e,g rake aws:ebs:snapshot:create_snapshots_from_images[us-west-2,ami-9b6125ab,ami-4brw45wb]


3]  To delete snapshots of volumes attached to instances and specific retention period in days

    #rake aws:ebs:snapshot:delete_snapshots_from_instances[us-west-2,retention_period_in_days,instance-id,instance-id..]
    # retention_period_in_days = 0 means delete all available snapshots
    e.g rake aws:ebs:snapshot:delete_snapshots_from_instances[us-west-2,14,i-3e045135]


-- To delete snapshots for volumes attached to  instances created using specific AMI and specific retention period in days
    #rake aws:ebs:snapshot:delete_snapshots_from_instances[us-west-2,retention_period_in_days,AMI-ID,AMI-ID..]
    # retention_period_in_days = 0 means delete all available snapshots
  e.g rake aws:ebs:snapshot:delete_snapshots_from_images[us-west-2,0,ami-9b6125ab]


-- To create  snapshots for specific volume criteria such as Status ,Size, and Encrypted Flag
     
      # rake aws:ebs:snapshot:create_snapshots[Status,Encrypted,Size,Region]
      # status - The status of the volume (creating | available | in-use | deleting | deleted | error)
      # encrypted - The encryption status of the volume true | false
      # size - The size of the volume, in GiB     
      e.g rake aws:ebs:snapshot:create_snapshots[in-use,false,100,us-west-2]
