resource "vra_catalog_source_blueprint" "this" {
  name        = var.catalog_source_name
  description = var.description
  project_id  = var.project_id
}

resource "vra_content_sharing_policy" "policies" {
  for_each = var.sharing_policies

  name        = coalesce(each.value.name, "${var.catalog_source_name}-${each.key}")
  description = each.value.description

  # Omitting project_id creates an org-scoped policy that applies to all projects.
  project_id = each.value.scope == "project" ? var.project_id : null

  entitlement_type = each.value.share_with_everyone ? "USER" : "ROLE"

  # USER + a PROJECT principal with an empty reference_id is the provider's
  # "all users and groups" shape; otherwise emit one ROLE principal per role.
  dynamic "principals" {
    for_each = each.value.share_with_everyone ? [""] : each.value.roles
    content {
      reference_id = principals.value
      type         = each.value.share_with_everyone ? "PROJECT" : "ROLE"
    }
  }

  catalog_source_ids = [vra_catalog_source_blueprint.this.id]
}
