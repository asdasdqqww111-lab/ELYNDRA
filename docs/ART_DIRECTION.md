# ELYNDRA — Art Direction

> **Status:** intent only. Milestone 001 contains **no final art assets**.
> Nothing in this document implies that finished models, textures or
> animations exist. The only visuals in M001 are a flat untextured ground plane
> and a neutral sky colour.

## 1. Overall identity

ELYNDRA combines **anime-inspired characters** with **restrained,
semi-realistic environments**.

- Characters: expressive, readable silhouettes, slightly stylised proportions,
  clean faces, strong colour separation. Think modern anime/fantasy illustration
  rather than photorealism.
- Environments: believable scale, real materials and natural lighting, without
  the noise and geometric density of full photorealism.
- Result: characters "pop" against grounded, calm environments.

## 2. Character direction

- Anime-influenced facial structure and eyes; proportions slightly stylised
  (not realistic).
- Silhouette-first design: each major character must be readable at a distance.
- Costumes and equipment communicate role (mage, warrior, ranger, etc.) at a
  glance.
- Restrained palette with one or two accent colours per character.
- Future characters must be rigged for real-time animation on mobile.

## 3. Environment direction

- Semi-realistic: real-world scale, plausible rock/vegetation/materials.
- Restraint over density: clear composition, readable landmarks, calm negative
  space.
- Each of the seven realms has a distinct environmental identity (colour,
  vegetation, architecture, mood) while sharing one lighting language.
- Towns are warm and human-scaled; wild regions are expansive.

## 4. Colour and atmosphere

- Global lighting: natural, soft, slightly warm daylight as the reference.
- Colour script: cool distant atmosphere, warmer mid-ground, saturated accents
  at points of interest.
- Time-of-day and weather are future systems, but the art must be authored to
  tolerate them (avoid baked-in time-of-day where possible).

## 5. Consistency requirements for future asset selection

When assets are acquired or created, they will be checked against:

1. **Scale** — 1 unit = 1 meter; characters and props must match.
2. **Polygon budget** — fits the mobile budget in `PERFORMANCE_BUDGET.md`.
3. **Texture budget** — power-of-two sizes, atlasing-friendly, compressed.
4. **Lighting model** — PBR materials consistent with the Mobile renderer.
5. **Style** — passes the "anime character in a semi-realistic world" test.
6. **License** — recorded and permitted; see `ASSET_LICENSES.md`.

A small "reference scene" should be assembled before mass asset production.

## 6. What is deliberately not decided here

- Final character roster and designs.
- Final realm colour scripts.
- Final architecture styles.
- UI/UX visual design.

These are future milestones and will be documented when they become real.
