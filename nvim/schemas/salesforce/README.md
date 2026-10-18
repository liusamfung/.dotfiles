# Salesforce metadata schemas (for lemminx)

Used by `nvim/after/lsp/lemminx.lua` to give completion and hover docs in
`*-meta.xml`, `*.js-meta.xml` and `package.xml`. Vendored here so a fresh
machine works without VS Code or network access.

| File | Origin |
|---|---|
| `metadata-catalog.xml`, `salesforce_metadata_api_namespace{1,2}.xsd`, `salesforce_metadata_api_common.xsd` | `salesforcedx-vscode-core` 67.20.0, `resources/` (XSD generated 2026-09-13) |
| `js-meta.xsd` | `salesforcedx-vscode-lwc` 67.20.0, `resources/static/` |

Source repo: <https://github.com/forcedotcom/salesforcedx-vscode>
(`packages/salesforcedx-vscode-core/resources`). License: see `LICENSE.txt`
(BSD-3-Clause, Salesforce.com, inc.).

## Local patches to `salesforce_metadata_api_common.xsd`

The upstream file is not a valid XSD (`xmllint --schema` refuses to compile it)
and its wildcards drown completion in thousands of unrelated suggestions.

1. `base="MetadataForSettings"` -> `base="Metadata"` (1 occurrence): the type
   `MetadataForSettings` is not defined anywhere in the file.
2. Removed the duplicated `value` element inside `ServiceChannelFieldPriority`
   (same name twice in one `xsd:choice`).
3. Removed every `<xsd:any ... processContents="lax"/>` wildcard (1603 lines),
   so completion is limited to the children of the element under the cursor.

Because (3) makes the schema stricter than real-world metadata (about 7% of real
files fail strict validation, e.g. `groupingString` in `standardValueSet`),
`lemminx.lua` sets `validation.schema.enabled = "never"`: the schema is used for
completion/hover only.

## Check after updating

```bash
xmllint --noout --schema salesforce_metadata_api_namespace1.xsd path/to/Some.cls-meta.xml
```
