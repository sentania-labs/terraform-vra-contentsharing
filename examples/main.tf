provider "vra" {
  url           = var.vcfa_url
  organization  = var.vcfa_organization
  refresh_token = var.vcfa_refresh_token
  insecure      = var.insecure
}

# Self-publish: expose each project's released blueprints to its own
# members and administrators (the module defaults).
module "project_catalog" {
  source   = "../"
  for_each = var.projects

  project_id          = each.value.project_id
  catalog_source_name = "${each.value.project_name} Catalog"
}

# Content project: a central content team's released blueprints,
# shared org-wide with all users and groups in every project.
module "content_catalog" {
  source = "../"

  project_id          = var.content_project_id
  catalog_source_name = "Standard Offerings"

  sharing_policies = {
    organization = {
      scope               = "organization"
      share_with_everyone = true
    }
  }
}
