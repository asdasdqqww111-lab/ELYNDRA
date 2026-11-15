# ELYNDRA — Asset Licenses & Acquisition Policy

> Milestone 001 contains **no third-party assets**. The register below is
> intentionally empty and is the template that must be filled in before any
> asset is added to the project.

## 1. Policy

1. **Prefer** CC0, MIT, or other clearly permissive licenses compatible with
   the intended game distribution.
2. **Verify** the license of every individual asset or pack. Do not assume that
   all files in a repository share the repository's main license.
3. **Record** every asset in the register below before it is used.
4. **Do not use** unclear, non-commercial-only (unless the project is
   non-commercial), share-alike-incompatible or "no redistribution" assets.
5. **Do not redistribute** standalone assets when the license prohibits it.
   If an asset may only be embedded in a larger work, note that restriction.
6. **Keep originals** of license texts in `docs/asset_licenses/` when required
   for attribution.
7. **No large downloads** are performed as part of a milestone without a
   concrete need.

## 2. Asset register

One row per asset or pack. Fill every column. If a value is unknown, write
`UNKNOWN` — never leave it blank.

| ID | Asset / pack | Creator | Source URL | License | Attribution required | Restrictions | Local path | Intended use | Verified by | Date |
|---|---|---|---|---|---|---|---|---|---|---|
| —  | *(empty — no assets yet)* | — | — | — | — | — | — | — | — | — |

### Notes on the columns

- **License:** the exact license identifier (e.g. `CC0-1.0`, `MIT`, `CC-BY-4.0`,
  `Apache-2.0`). Link to the license text.
- **Attribution required:** yes/no and the exact attribution text if yes.
- **Restrictions:** e.g. "no redistribution of raw files", "non-commercial
  only", "must be embedded in a larger work", "ND (no derivatives)".
- **Verified by / Date:** who checked the license and when. Do not use an asset
  without a verification entry.

## 3. Engine and tooling licenses

Godot Engine is used under its own license (MIT). Godot is a tool, not a
distributed asset; games built with it do not need to include Godot source.
Confirm the current Godot license text when upgrading the engine version.

## 4. Prohibited

- Assets whose license cannot be determined.
- Assets from packs with a repository-level license but per-file exceptions.
- "Free for personal use only" assets in a distributable game.
- Any asset that requires sharing the project's source under a copyleft license
  (unless that is explicitly accepted).

## 5. Acquisition workflow (for future milestones)

1. Find a candidate asset and its source page.
2. Read the actual license file, not the README summary.
3. Add a row to the register with all columns.
4. Save the license text under `docs/asset_licenses/<id>-<name>.txt`.
5. Only then import the asset into `assets/`.
6. Add attribution to the in-game credits if required.
