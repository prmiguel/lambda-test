provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://quirquincho:4566"
    apigatewayv2   = "http://quirquincho:4566"
    cloudformation = "http://quirquincho:4566"
    cloudwatch     = "http://quirquincho:4566"
    dynamodb       = "http://quirquincho:4566"
    ec2            = "http://quirquincho:4566"
    es             = "http://quirquincho:4566"
    elasticache    = "http://quirquincho:4566"
    firehose       = "http://quirquincho:4566"
    iam            = "http://quirquincho:4566"
    kinesis        = "http://quirquincho:4566"
    lambda         = "http://quirquincho:4566"
    rds            = "http://quirquincho:4566"
    redshift       = "http://quirquincho:4566"
    route53        = "http://quirquincho:4566"
    s3             = "http://s3.quirquincho.localstack.cloud:4566"
    secretsmanager = "http://quirquincho:4566"
    ses            = "http://quirquincho:4566"
    sns            = "http://quirquincho:4566"
    sqs            = "http://quirquincho:4566"
    ssm            = "http://quirquincho:4566"
    stepfunctions  = "http://quirquincho:4566"
    sts            = "http://quirquincho:4566"
  }
}

resource "aws_sqs_queue" "terraform_queue" {
  name = "terraform-example-queue"
  tags = {
    Environment = "testing"
  }
}

# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_file = "../index.js"
#   output_path = "lambda_function.zip"
# }

# resource "aws_lambda_function" "test_lambda" {
#   filename         = "lambda_function.zip"
#   function_name    = "test_lambda"
#   role             = aws_iam_role.iam_for_lambda_tf.arn
#   handler          = "index.handler"
# #   source_code_hash = data.archive_file.lambda_zip.output_base64sha256
#   runtime          = "nodejs14.x"
# }


data "archive_file" "lambda_z" {
  source_dir  = "../node-lambda-typescript"
  type        = "zip"
  output_path = "node-lambda-typescript.zip"
}

resource "aws_lambda_function" "app_lambda" {
  filename         = "node-lambda-typescript.zip"
  function_name    = "app_lambda"
  role             = aws_iam_role.iam_for_lambda_tf.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_z.output_base64sha256
  runtime          = "nodejs14.x"
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = "${aws_sqs_queue.terraform_queue.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.app_lambda.arn}"
}

resource "aws_iam_role" "iam_for_lambda_tf" {
  name = "iam_for_lambda_tf"

  assume_role_policy = <<EOF
                        {
                        "Version": "2012-10-17",
                        "Statement": [
                            {
                            "Action": "sts:AssumeRole",
                            "Principal": {
                                "Service": "lambda.amazonaws.com"
                            },
                            "Effect": "Allow",
                            "Sid": ""
                            }
                        ]
                        }
                        EOF
}