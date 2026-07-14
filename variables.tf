variable "project_id" {
  type        = string
  description = "The id of the project whose released blueprints are exposed as a catalog source. Project-scoped sharing policies are also attached to this project."
}

variable "catalog_source_name" {
  type        = string
  description = "The name of the blueprint catalog source as it appears in the Service Broker catalog. Also used as the prefix for generated sharing policy names."
}

variable "description" {
  type        = string
  description = "A human-friendly description applied to the catalog source."
  default     = "Created by vRA terraform provider - Do not Edit!"
}

variable "sharing_policies" {
  description = <<-EOT
    Map of content sharing policies to create against the catalog source, keyed by a short label.
    Each policy shares the catalog source with an audience:
      - scope: "project" (default) attaches the policy to project_id; "organization" creates an org-scoped policy that applies across all projects.
      - share_with_everyone: true shares with all users and groups in the applicable project(s), ignoring roles.
      - roles: project role identifiers (e.g. member, administrator) granted access when share_with_everyone is false.
      - name/description: override the generated policy name ("<catalog_source_name>-<key>") and default description.
    The default creates a single project-scoped policy shared with project members and administrators.
  EOT
  type = map(object({
    name                = optional(string)
    description         = optional(string, "Created by vRA terraform provider - Do not Edit!")
    scope               = optional(string, "project")
    share_with_everyone = optional(bool, false)
    roles               = optional(list(string), ["member", "administrator"])
  }))
  default = {
    project = {}
  }

  validation {
    condition     = alltrue([for p in var.sharing_policies : contains(["project", "organization"], p.scope)])
    error_message = "Each sharing policy scope must be either \"project\" or \"organization\"."
  }

  validation {
    condition     = alltrue([for p in var.sharing_policies : p.share_with_everyone || length(p.roles) > 0])
    error_message = "Each sharing policy must either set share_with_everyone = true or list at least one role."
  }
}
