provider "aws" {
  region = "us-east-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "terraform-tutorial-bucket-jabt"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"
  instance_type = "t2.micro" #in prod one would use a bigger server but this one is free
  min_size = 5
  max_size = 10
}

resource "aws_autoscaling_schedule" "scale_out_in_morning" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}