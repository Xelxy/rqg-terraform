#------------------------------------------------------------------------------
Configure AWS provider
#------------------------------------------------------------------------------
provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

#------------------------------------------------------------------------------
Configure backend https://www.terraform.io/docs/backends/index.html
#------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "rqg-infrastructure"
    key    = "rqg/infrastructure.tfstate"
    region = "us-west-1"
  }
}

#------------------------------------------------------------------------------
Creation of ECS Task Definition
#------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "rqg" {
  family                = "rqg-task"
  container_definitions = "${file("task-definitions/rqg-task.json")}"

#------------------------------------------------------------------------------
Creation of ECS
#------------------------------------------------------------------------------
resource "aws_ecs_service" "rqg" {
  name            = "rqg"
  ####cluster         = "${aws_ecs_cluster.foo.id}"
  task_definition = "${aws_ecs_task_definition.rqg.arn}"
  desired_count   = 2
  ###iam_role        = "${aws_iam_role.foo.arn}"
  ###depends_on      = ["aws_iam_role_policy.foo"]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.foo.arn}"
    container_name   = "rqg-task"
    container_port   = 3000
  }
