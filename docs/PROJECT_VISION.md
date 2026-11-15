# ELYNDRA — Project Vision

## Concept

**ELYNDRA — Secrets of the Seven Realms** is a 3D open-world fantasy RPG.

The player explores a large, seamless fantasy world, travelling between towns,
wild regions and the seven titular realms. The game combines fantasy
exploration, magic, creatures, quests and weapons in an offline, single-player
adventure.

## Platform and delivery

- **Primary target:** Android.
- **Architecture:** offline, single-player. No online services, no multiplayer
  and no always-on requirement for the initial release.
- **Engine:** Godot 4.x with GDScript.
- **Business/distribution:** premium or free-to-play is undecided. Asset
  licensing is handled conservatively (see `ASSET_LICENSES.md`) so that either
  model remains possible.

## Gameplay pillars

1. **Exploration** — a large continuous world (long-term target
   1500 × 1500 m = 2.25 km²) that rewards moving through it.
2. **Discovery** — seven distinct realms, each with its own identity, creatures
   and secrets.
3. **Character growth** — magic, weapons and equipment that change how the
   player interacts with the world.
4. **Story and quests** — a main path plus optional content in towns and the
   wild.

These pillars are direction only. No gameplay system is implemented in
Milestone 001.

## Art direction

Anime-inspired characters and artistic identity, combined with restrained,
semi-realistic environments. See `ART_DIRECTION.md` for the full intent.

## Long-term world target

- 1500 m (X) × 1500 m (Z) = 2.25 km².
- Ground reference height `Y = 0`.
- Logical partition: 15 × 15 regions of 100 × 100 m (225 regions).

## Milestone philosophy

The project is built in small, verifiable milestones. Each milestone must leave
the project in a runnable, documented state and must not contain fake or
placeholder systems. Milestone 001 is the foundation only; nothing here pretends
to be gameplay.

## Player experience goal

A player should be able to open the game on a mid-range Android device, move
through a coherent, readable world at a stable frame rate, and immediately
understand where they are. The foundation in this milestone exists to make that
possible later.
