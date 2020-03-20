variable "aws_priv_key" {
  default = "~/.ssh/proxycannon.pem"
}

# launch nodes in this reagion.
variable "aws_region" {
  default = "eu-central-1"
}

# Given that that AMI source data resides in one particular region,
# AWS allows you to use it in only that same region.
# If you adjusted the region above, you'll have to adjust this as well
# The following is a list of regions and working AMI IDs
# 
# us-east-2 : ami-0f65671a86f061fcd
# eu-central-1 : ami-0b418580298265d5c
variable "aws_ami"
{
  default = "ami-0b418580298265d5c"
}

variable "aws_instance_type" {
  default = "t2.nano"
}



# number of exit-node instances to launch
variable "count" {
  default = 2
}

# launch all exit nodes in the same subnet id
# this should be the same subnet id that your control server is in
# you can get this value from the AWS console when viewing the details of the control-server instance
variable "subnet_id" {
  default = "subnet-XXXXXXXX"
}

