# 🎮 Tuubaamon — Development Roadmap

> A Pokémon-inspired Godot RPG with player-monster merging and Quick Time Events

---

## 📊 Current Progress

| System | Status | Notes |
|---|---|---|
| Type Chart (18 types) | ✅ Done | Full effectiveness matrix |
| Damage Calculator | ✅ Done | STAB, crits, stat stages, weather |
| QTE System | ✅ Done | 5 types: Mash, Timed, Sequence, Hold, Rhythm |
| Battle Engine | ✅ Done | Debug UI for testing, turn-based |
| Monster/Move/Item Templates | ✅ Done | Resource-based, editor-friendly |
| Player Data | ✅ Done | Stats, inventory, monster party |
| Merge System | ✅ Done | Player fuses with monster for types + moves |
| Centralized Enums | ✅ Done | Single source of truth |
| Settings/Config | ✅ Done | Graphics, audio, input, gameplay |
| Main Menu | 🟡 Basic | Needs polish |
| World Map | ❌ | Not started |
| Save/Load | ❌ | Not started |
| Catching | ❌ | Not started |

---

## 🗺️ Roadmap

### Phase 1 — Foundation (Do These First)

#### 1.1 Player Overworld Controller
The player needs to walk around the world.
- `CharacterBody2D` with 4-directional movement
- Grid-based or free movement (grid is more Pokémon-like)
- Collision with walls, NPCs, objects
- Interaction trigger (talk, examine, open doors)
- **Files to create:** `Scripts/Overworld/player_controller.gd`, `Szene/Overworld/player.tscn`

#### 1.2 World Streaming
Seamless area transitions (Route → City → Cave etc.).
- `WorldStreamer` node that loads/unloads neighbor scenes
- `Area2D` triggers at scene edges
- Async loading to avoid frame stutter
- **Files:** `Scripts/Overworld/world_streamer.gd`, `Szene/Overworld/`

#### 1.3 Basic TileMap World
At least one playable area to test movement + encounters.
- A Route with tall grass tiles
- A small town/city
- Transition triggers between them
- **Files:** `Szene/World/route_1.tscn`, `Szene/World/starting_town.tscn`

---

### Phase 2 — Core Gameplay Loop

#### 2.1 Wild Monster Encounters
Random battles when walking in tall grass.
- Step counter with encounter rate
- Encounter table per area (which monsters spawn at which levels)
- Battle transition animation
- **Files:** `Scripts/Overworld/encounter_system.gd`

#### 2.2 Monster Catching
Throw capture items at wild monsters.
- Catch rate formula (based on HP%, status, ball type)
- Ball shake animation (3 shakes + click)
- Add to party or PC box
- **Files:** `Scripts/Battle/catch_system.gd`

#### 2.3 Proper Battle Scene
Replace the debug UI with a polished battle screen.
- Player/monster sprites, HP bars, animations
- Move selection menu with PP display
- Merge button (player fuses with active monster)
- QTE overlay for special moves
- **Files:** `Szene/Battle/battle_scene.tscn`, `Scripts/Battle/battle_ui.gd`

#### 2.4 Party Management UI
View and manage your monster party outside battle.
- 6-slot party display with stats
- Move reordering, item usage on monsters
- Release/rename monsters
- **Files:** `Szene/UI/party_screen.tscn`, `Scripts/UI/party_screen.gd`

---

### Phase 3 — Depth & Polish

#### 3.1 Save/Load System
Persist game progress.
- Save player position, party, inventory, story flags
- Multiple save slots
- Auto-save on area transition
- **Files:** `Scripts/Core/save_manager.gd` (can extend `ConfigManager`)

#### 3.2 NPC & Dialogue System
Talk to NPCs, trigger story events.
- Dialogue box with typewriter text effect
- Branching choices (Yes/No)
- Scripted events (cutscenes, battles)
- **Files:** `Scripts/Overworld/dialogue_system.gd`, `Szene/UI/dialogue_box.tscn`

#### 3.3 Trainer Battles
Battle other human characters.
- Trainer detection (line of sight)
- Pre-battle dialogue
- Prize money on victory
- Trainer rematches
- **Files:** extend `encounter_system.gd` with trainer data

#### 3.4 Shop System
Buy/sell items in towns.
- Shop UI with item list and prices
- Buy quantity selector
- Sell from inventory
- **Files:** `Szene/UI/shop_screen.tscn`, `Scripts/UI/shop_system.gd`

---

### Phase 4 — Expansion

#### 4.1 Evolution System
Monsters evolve at certain levels or with items.
- Level-up evolution check after battle
- Evolution animation sequence
- Item-based evolution (stones)
- **Files:** `Scripts/Monster/evolution_system.gd`

#### 4.2 Monster Storage (Box System)
Store extra monsters beyond your party of 6.
- PC-style box UI in towns
- Organize, move, release monsters
- **Files:** `Szene/UI/storage_screen.tscn`, `Scripts/UI/storage_system.gd`

#### 4.3 Status Effects In Battle
Make burn/poison/paralysis actually work in combat.
- Damage over time (burn, poison)
- Action skip chance (paralysis, freeze, sleep)
- Visual indicators on HP bar
- **Files:** extend `battle_system.gd` and `StatusEffectTemplate.gd`

#### 4.4 Abilities System
Monster passive abilities activate during battle.
- Trigger checks (on switch-in, on hit, on low HP)
- Stat modifiers, immunities, weather
- **Files:** extend `AbilityTemplate.gd`, integrate into battle

---

### Phase 5 — Content

#### 5.1 Create More Monsters
Design unique monsters with proper stats.
- 20–30 monsters for a small region
- Full evolution lines (3 stages each)
- Unique move pools
- **Files:** `Resources/Monsters/*.tres`

#### 5.2 Create More Moves
Cover all 18 types with varied moves.
- Physical, special, and status moves
- QTE-enabled signature moves for special monsters
- TM/HM system for teaching moves
- **Files:** `Resources/Moves/*.tres`

#### 5.3 World Building
Design the full game world.
- 5–8 routes connecting towns
- 3–4 cities/towns with unique themes
- 2–3 dungeons (forest, cave, mountain)
- Victory road + elite challenge
- **Files:** `Szene/World/*.tscn`

---

## 🎯 Recommended Next Steps (Ordered)

```
1. Player overworld controller    ← Start here
2. World streaming + 1 route       ← Then this
3. Wild encounters in tall grass    ← Core loop
4. Proper battle scene (replace debug UI)
5. Monster catching
6. Party management UI
7. Save/Load system
8. NPC dialogue
```

---

## 📁 Project Structure (Planned)

```
Scripts/
├── Battle/
│   ├── battle_system.gd          ✅ Done
│   ├── damage_calculator.gd      ✅ Done
│   ├── type_chart.gd             ✅ Done
│   ├── qte_system.gd             ✅ Done
│   ├── merge_system.gd           ✅ Done
│   ├── catch_system.gd           🔲 Phase 2
│   └── battle_ui.gd              🔲 Phase 2
├── Core/
│   └── save_manager.gd           🔲 Phase 3
├── Overworld/
│   ├── player_controller.gd      🔲 Phase 1
│   ├── world_streamer.gd         🔲 Phase 1
│   ├── encounter_system.gd       🔲 Phase 2
│   └── dialogue_system.gd        🔲 Phase 3
├── UI/
│   ├── party_screen.gd           🔲 Phase 2
│   ├── shop_system.gd            🔲 Phase 3
│   └── storage_system.gd         🔲 Phase 4
├── Player/
│   └── PlayerData.gd             ✅ Done
├── Monster/
│   ├── MonsterTemplate.gd        ✅ Done
│   └── evolution_system.gd       🔲 Phase 4
├── Move/
│   ├── MoveTemplate.gd           ✅ Done
│   └── LevelUpMoves.gd           ✅ Done
├── Item/
│   └── ItemTemplate.gd           ✅ Done
├── Abilities/
│   └── AbilityTemplate.gd        ✅ Done
├── StatusEffects/
│   └── StatusEffectTemplate.gd   ✅ Done
├── Enums/
│   └── Enums.gd                  ✅ Done
└── ConfigManager.gd              ✅ Done
```

---

## 💡 Design Pillars (Don't Forget These!)

1. **Merge Mechanic** — This is your unique selling point. Player-monster fusion should feel impactful. Make merged forms look cool, give strong stat bonuses, and let QTE moves really shine.

2. **QTE Combat** — Don't overuse QTEs or they become tedious. Reserve them for special/signature moves. Make the difficulty scale with move power.

3. **Seamless World** — No loading screens. Area streaming should be invisible to the player.

4. **German Flavor** — You've got German move names (Feuerbellen, Rankenhieb). Lean into it for a unique identity!

---

*Last updated: 2026-07-26*
