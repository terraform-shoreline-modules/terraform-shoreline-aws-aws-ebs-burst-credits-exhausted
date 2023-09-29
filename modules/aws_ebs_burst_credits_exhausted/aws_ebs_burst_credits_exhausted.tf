resource "shoreline_notebook" "aws_ebs_burst_credits_exhausted" {
  name       = "aws_ebs_burst_credits_exhausted"
  data       = file("${path.module}/data/aws_ebs_burst_credits_exhausted.json")
  depends_on = [shoreline_action.invoke_aws_ebs_credit_notification,shoreline_action.invoke_resize_volume]
}

resource "shoreline_file" "aws_ebs_credit_notification" {
  name             = "aws_ebs_credit_notification"
  input_file       = "${path.module}/data/aws_ebs_credit_notification.sh"
  md5              = filemd5("${path.module}/data/aws_ebs_credit_notification.sh")
  description      = "The application or system that is using the EBS volume is experiencing a sudden spike in traffic or usage, causing it to perform more I/O operations than usual."
  destination_path = "/agent/scripts/aws_ebs_credit_notification.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "resize_volume" {
  name             = "resize_volume"
  input_file       = "${path.module}/data/resize_volume.sh"
  md5              = filemd5("${path.module}/data/resize_volume.sh")
  description      = "Increase the volume size or switch to a provisioned IOPS volume to prevent burst credit exhaustion."
  destination_path = "/agent/scripts/resize_volume.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_aws_ebs_credit_notification" {
  name        = "invoke_aws_ebs_credit_notification"
  description = "The application or system that is using the EBS volume is experiencing a sudden spike in traffic or usage, causing it to perform more I/O operations than usual."
  command     = "`chmod +x /agent/scripts/aws_ebs_credit_notification.sh && /agent/scripts/aws_ebs_credit_notification.sh`"
  params      = ["EBS_VOLUME_ID","AWS_REGION","REGION"]
  file_deps   = ["aws_ebs_credit_notification"]
  enabled     = true
  depends_on  = [shoreline_file.aws_ebs_credit_notification]
}

resource "shoreline_action" "invoke_resize_volume" {
  name        = "invoke_resize_volume"
  description = "Increase the volume size or switch to a provisioned IOPS volume to prevent burst credit exhaustion."
  command     = "`chmod +x /agent/scripts/resize_volume.sh && /agent/scripts/resize_volume.sh`"
  params      = ["VOLUME_ID","INSTANCE_ID","NEW_SIZE","REGION"]
  file_deps   = ["resize_volume"]
  enabled     = true
  depends_on  = [shoreline_file.resize_volume]
}

