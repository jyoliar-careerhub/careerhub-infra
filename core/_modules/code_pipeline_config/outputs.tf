output "connection_arn" {
  value = aws_codestarconnections_connection.this.arn
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

output "codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}

output "codebuild_bucket_id" {
  value = aws_s3_bucket.codebuild_bucket.id
}

output "codebuild_bucket" {
  value = aws_s3_bucket.codebuild_bucket.bucket
}

output "codebuild_sg_id" {
  value = aws_security_group.codebuild_sg.id
}
