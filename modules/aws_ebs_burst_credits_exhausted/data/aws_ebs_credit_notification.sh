​
​
#!/bin/bash
​
​
​
# Set AWS region and EBS volume ID
​
REGION=${AWS_REGION}
​
VOL_ID=${EBS_VOLUME_ID}
​
​
​
# Get the current burst credit balance and maximum burst credit balance for the EBS volume
​
CURRENT_CREDIT=$(aws ec2 describe-volumes --region $REGION --volume-ids $VOL_ID --query 'Volumes[0].BurstBalance')
​
MAX_CREDIT=$(aws ec2 describe-volumes --region $REGION --volume-ids $VOL_ID --query 'Volumes[0].VolumeType' | grep -q "gp2" && echo "6144" || echo "0")
​
​
​
# Calculate the percentage of burst credits remaining
​
CREDIT_PERCENT=$(echo "scale=2; $CURRENT_CREDIT/$MAX_CREDIT*100" | bc)
​
​
​
# Check if the burst credit balance is below a certain threshold (e.g. 20%)
​
if [ $(echo "$CREDIT_PERCENT < 20" | bc) -eq 1 ]; then
​
    # Send a notification via email, Slack, or other means to alert the team
​
    echo "EBS volume $VOL_ID has only $CREDIT_PERCENT% burst credits remaining. Please investigate the cause of the sudden spike in I/O operations."
​
else
​
    # The burst credit balance is normal, so exit without errors
​
    exit 0
​
fi
​
​