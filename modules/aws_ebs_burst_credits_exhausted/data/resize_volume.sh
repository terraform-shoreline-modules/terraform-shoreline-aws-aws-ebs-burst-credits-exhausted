​
​
#!/bin/bash
​
​
​
# Define variables
​
REGION="${REGION}"
​
VOLUME_ID="${VOLUME_ID}"
​
NEW_SIZE=${NEW_SIZE}
​
​
​
# Stop the instance using the volume
​
INSTANCE_ID=$(aws ec2 describe-volumes --region $REGION --volume-ids $VOLUME_ID --query "Volumes[0].Attachments[0].InstanceId" --output text)
​
aws ec2 stop-instances --region $REGION --instance-ids $INSTANCE_ID
​
aws ec2 wait instance-stopped --region $REGION --instance-ids $INSTANCE_ID
​
​
​
# Modify the volume size
​
aws ec2 modify-volume --region $REGION --volume-id $VOLUME_ID --size $NEW_SIZE
​
​
​
# Start the instance
​
aws ec2 start-instances --region $REGION --instance-ids $INSTANCE_ID
​
aws ec2 wait instance-running --region $REGION --instance-ids $INSTANCE_ID
​
​