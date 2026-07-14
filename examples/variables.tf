variable "vcfa_url" {
  type        = string
  description = "The VCFA URL: https://<FQDN>"
}

variable "vcfa_organization" {
  type        = string
  description = "The VCFA Organization"
}

/**
 * vcfa_refresh_token
 * Refresh token used for authentication to the VCF-A API.
 * Marked sensitive to avoid logging/output exposure.
 */
variable "vcfa_refresh_token" {
  type        = string
  description = "Refresh token used for authentication to the VCF-A API"
  sensitive   = true
}

/**
 * insecure
 * Whether to skip SSL certificate verification when connecting
 * to the VCF-A API (typically true for lab environments).
 */
variable "insecure" {
  type        = bool
  description = "Whether to skip SSL certificate verification"
  default     = true
}

variable "projects" {
  type = map(object({
    project_id   = string
    project_name = string
  }))
  description = "Map of projects that self-publish their released blueprints to their own members"
}

variable "content_project_id" {
  type        = string
  description = "The id of the content project whose blueprints are shared org-wide"
}
