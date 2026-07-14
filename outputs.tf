output "catalog_source" {
  description = "The resulting blueprint catalog source, including name and id. Reference the id from externally-managed sharing policies."
  value = {
    "name" = vra_catalog_source_blueprint.this.name,
    "id"   = vra_catalog_source_blueprint.this.id
  }
}

output "sharing_policies" {
  description = "Map of the resulting content sharing policies keyed by policy label, each including name and id."
  value = {
    for k, p in vra_content_sharing_policy.policies : k => {
      "name" = p.name,
      "id"   = p.id
    }
  }
}
