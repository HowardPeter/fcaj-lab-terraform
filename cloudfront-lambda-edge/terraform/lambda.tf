# Trust policy: Lambda@Edge cần cả lambda và edgelambda assume role
data "aws_iam_policy_document" "lambda_edge_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "lambda_edge" {
  name               = "lambda_edge_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_edge_logs" {
  role       = aws_iam_role.lambda_edge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Zip code handler, để trong .terraform
data "archive_file" "lambda_edge" {
  type        = "zip"
  source_file = "${path.module}/../lambda/index.js"
  output_path = "${path.module}/.terraform/lambda-edge.zip"
}

resource "aws_lambda_function" "edge" {
  # Lambda@Edge bắt buộc ở us-east-1
  provider = aws.us_east_1

  function_name = "LambdaEdgeImmersionDayLabFunction"
  role          = aws_iam_role.lambda_edge.arn
  handler       = "index.handler"

  # Lab dùng nodejs18.x (đã deprecated); nodejs24.x bỏ hỗ trợ callback handler
  runtime = "nodejs22.x"

  filename         = data.archive_file.lambda_edge.output_path
  source_code_hash = data.archive_file.lambda_edge.output_base64sha256

  # CloudFront chỉ gắn được version cụ thể, không gắn $LATEST
  publish = true
}
