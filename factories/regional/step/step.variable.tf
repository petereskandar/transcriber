variable "tags" {
  type        = map(string)
  default     = {}
  description = ""
}

variable "sender_email" {
  type        = string
  description = "Sender Email Address, used by SES to deliver transcription results"
}