# Crear el bucket S3
resource "aws_s3_bucket" "backup_bucket" {
  bucket = "backup-bucket-aff"

  tags = {
    Name = "MongoDB_Backups"
  }
}

# Deshabilitar el bloqueo de acceso público
resource "aws_s3_bucket_public_access_block" "disable_public_access_block" {
  bucket = aws_s3_bucket.backup_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Habilitar permisos de lectura pública
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.backup_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.backup_bucket.arn}/*"
      }
    ]
  })
}