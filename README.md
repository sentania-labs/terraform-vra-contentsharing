# terraform-vra-contentsharing

Terraform module — publishes a project's released blueprints (cloud templates) to the Service Broker catalog and shares them with an audience, as a single unit.

It creates one `vra_catalog_source_blueprint` for the project, plus one or more `vra_content_sharing_policy` resources against that catalog source. Pairing the two means the half-configured state — blueprints released to the catalog but visible to no one — is not expressible.

## Usage patterns

**Self-publish (default):** a project's released blueprints become catalog items visible to that project's members and administrators. Project users author blueprints in the designer (or push them via pipeline), release a version to the catalog, and they appear — no further Terraform runs needed.

```hcl
module "project_catalog" {
  source  = "sentania-labs/contentsharing/vra"

  project_id          = var.project_id
  catalog_source_name = "My Project Catalog"
}
```

**Content project shared org-wide:** a central content team's released blueprints, offered to all users in every project.

```hcl
module "content_catalog" {
  source  = "sentania-labs/contentsharing/vra"

  project_id          = var.content_project_id
  catalog_source_name = "Standard Offerings"

  sharing_policies = {
    organization = {
      scope               = "organization"
      share_with_everyone = true
    }
  }
}
```

Multiple policies against the same catalog source are supported — `sharing_policies` is a map, with one policy created per entry.

## Notes

- Only blueprint versions **released to the catalog** appear as items. Draft blueprints are ignored by the catalog source; when using the `sentania-labs/blueprint/vra` module or the raw `vra_blueprint` resource, pair it with `vra_blueprint_version` (`release = true`).
- `scope = "organization"` omits `project_id` on the policy, producing an org-scoped policy that applies across all projects. The provider's `project_criteria` filtering is not exposed by this module; compose a raw `vra_content_sharing_policy` against the `catalog_source.id` output for that case.
- `share_with_everyone = true` uses the provider's "all users and groups" principal shape (`USER` entitlement with an empty `PROJECT` principal); otherwise one `ROLE` principal is emitted per entry in `roles`.
- This module replaces the deprecated `vra_catalog_source_entitlement` pattern with `vra_content_sharing_policy`.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
