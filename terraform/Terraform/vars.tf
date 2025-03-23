provider "aws" {
  region = var.REGION
}

variable "backup_file_base64" {
  description = "Base64-encoded backup file"
  type        = string
}
