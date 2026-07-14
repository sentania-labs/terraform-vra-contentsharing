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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0 |
| <a name="requirement_vra"></a> [vra](#requirement\_vra) | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vra"></a> [vra](#provider\_vra) | >= 0.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vra_catalog_source_blueprint.this](https://registry.terraform.io/providers/vmware/vra/latest/docs/resources/catalog_source_blueprint) | resource |
| [vra_content_sharing_policy.policies](https://registry.terraform.io/providers/vmware/vra/latest/docs/resources/content_sharing_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_source_name"></a> [catalog\_source\_name](#input\_catalog\_source\_name) | The name of the blueprint catalog source as it appears in the Service Broker catalog. Also used as the prefix for generated sharing policy names. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | A human-friendly description applied to the catalog source. | `string` | `"Created by vRA terraform provider - Do not Edit!"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The id of the project whose released blueprints are exposed as a catalog source. Project-scoped sharing policies are also attached to this project. | `string` | n/a | yes |
| <a name="input_sharing_policies"></a> [sharing\_policies](#input\_sharing\_policies) | Map of content sharing policies to create against the catalog source, keyed by a short label.<br/>Each policy shares the catalog source with an audience:<br/>  - scope: "project" (default) attaches the policy to project\_id; "organization" creates an org-scoped policy that applies across all projects.<br/>  - share\_with\_everyone: true shares with all users and groups in the applicable project(s), ignoring roles.<br/>  - roles: project role identifiers (e.g. member, administrator) granted access when share\_with\_everyone is false.<br/>  - name/description: override the generated policy name ("<catalog\_source\_name>-<key>") and default description.<br/>The default creates a single project-scoped policy shared with project members and administrators. | <pre>map(object({<br/>    name                = optional(string)<br/>    description         = optional(string, "Created by vRA terraform provider - Do not Edit!")<br/>    scope               = optional(string, "project")<br/>    share_with_everyone = optional(bool, false)<br/>    roles               = optional(list(string), ["member", "administrator"])<br/>  }))</pre> | <pre>{<br/>  "project": {}<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_catalog_source"></a> [catalog\_source](#output\_catalog\_source) | The resulting blueprint catalog source, including name and id. Reference the id from externally-managed sharing policies. |
| <a name="output_sharing_policies"></a> [sharing\_policies](#output\_sharing\_policies) | Map of the resulting content sharing policies keyed by policy label, each including name and id. |
<!-- END_TF_DOCS -->
