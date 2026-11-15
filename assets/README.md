# assets/

This directory is reserved for **imported game assets** (models, textures,
materials, vegetation, audio, fonts, environment data).

## Status

Milestone 001 contains **no assets**. No final art is created or downloaded in
this milestone. See `docs/ART_DIRECTION.md` for intent and
`docs/ASSET_LICENSES.md` for the acquisition policy.

## Planned layout

Create a sub-folder only when the first real asset of that type is added:

```
assets/
├── environments/   # skyboxes, sky shaders, fog/weather references
├── textures/       # albedo, normal, roughness, masks (power-of-two)
├── materials/      # .tres material resources
├── vegetation/     # trees, grass, rocks (MultiMesh-ready)
├── models/         # characters, props, buildings
├── audio/          # music, SFX, ambience
└── fonts/          # UI and text fonts
```

## Rules

- Every asset must have a row in `docs/ASSET_LICENSES.md` **before** import.
- Respect the budgets in `docs/PERFORMANCE_BUDGET.md`.
- Do not commit large binaries without a concrete need; prefer importing from
  a documented source.
