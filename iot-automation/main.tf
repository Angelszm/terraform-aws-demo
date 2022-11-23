resource "aws_iot_thing" "angel_test" {
  name = var.thing_name
  thing_type_name=aws_iot_thing_type.angel_test.name
}

resource "aws_iot_thing_type" "angel_test" {
  name = var.thing_type
}

provider "aws" {
  region = "ap-southeast-1"
}