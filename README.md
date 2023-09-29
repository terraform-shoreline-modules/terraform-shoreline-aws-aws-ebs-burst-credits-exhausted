
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# AWS EBS Burst Credits Exhausted
---
​
AWS EBS (Elastic Block Store) Burst Credits Exhausted is an incident that occurs when an Amazon EBS volume has exhausted its burst credit balance. This happens when the volume has been used continuously at its maximum IOPS (input/output operations per second) rate for an extended period of time, causing the volume to consume its burst credits faster than it can earn them. As a result, the volume's performance is significantly degraded until the burst credits are replenished.
​
### Parameters
```shell
export VOLUME_ID="PLACEHOLDER"
​
export METRIC_ID="PLACEHOLDER"
​
export REGION="PLACEHOLDER"
​
export NEW_SIZE="PLACEHOLDER"
​
export INSTANCE_ID="PLACEHOLDER"
​
export EBS_VOLUME_ID="PLACEHOLDER"
​
export AWS_REGION="PLACEHOLDER"
```
​
## Debug
​
### List all EBS volumes in the current region
```shell
aws ec2 describe-volumes
```
​
### Get details about a specific EBS volume using its <volume-id>
```shell
aws ec2 describe-volumes --volume-ids ${VOLUME_ID}
```
​
### Check the burst credit balance for an EBS volume
```shell
aws cloudwatch get-metric-data --metric-data-queries '[{"Id":"${METRIC_ID}","MetricStat":{"Metric":{"Namespace":"AWS/EBS","MetricName":"BurstBalance","Dimensions":[{"Name":"VolumeId","Value":"${VOLUME_ID}"}]},"Period":300,"Stat":"Average"}}]' --start-time $(date -u +%Y-%m-%dT%TZ --date '-10 minutes') --end-time $(date -u +%Y-%m-%dT%TZ)
```
​
### Check the IOPS usage for an EBS volume
```shell
aws cloudwatch get-metric-data --metric-data-queries '[{"Id":"${METRIC_ID}","MetricStat":{"Metric":{"Namespace":"AWS/EBS","MetricName":"VolumeReadOps","Dimensions":[{"Name":"VolumeId","Value":"${VOLUME_ID}"}]},"Period":300,"Stat":"Sum"}},{"Id":"${METRIC_ID}","MetricStat":{"Metric":{"Namespace":"AWS/EBS","MetricName":"VolumeWriteOps","Dimensions":[{"Name":"VolumeId","Value":"${VOLUME_ID}"}]},"Period":300,"Stat":"Sum"}}]' --start-time $(date -u +%Y-%m-%dT%TZ --date '-10 minutes') --end-time $(date -u +%Y-%m-%dT%TZ)
```
​
### Check the burst credit balance usage for an EC2 instance
```shell
aws cloudwatch get-metric-data --metric-data-queries '[{"Id":"${METRIC_ID}","MetricStat":{"Metric":{"Namespace":"AWS/EBS","MetricName":"BurstBalance","Dimensions":[{"Name":"InstanceId","Value":"${INSTANCE_ID}"}]},"Period":300,"Stat":"Average"}}]' --start-time $(date -u +%Y-%m-%dT%TZ --date '-10 minutes') --end-time $(date -u +%Y-%m-%dT%TZ)
```
​
### The application or system that is using the EBS volume is experiencing a sudden spike in traffic or usage, causing it to perform more I/O operations than usual.
```shell
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
```
​
## Repair
​
### Increase the volume size or switch to a provisioned IOPS volume to prevent burst credit exhaustion.
```shell
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
```