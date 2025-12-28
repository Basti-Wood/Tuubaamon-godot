# Centralized Enums System

## Overview
All enums in the Tuubaamon project are now centralized in [Enums.gd](Enums.gd). This ensures that when you update an enum value, all files that reference it will automatically use the updated version.

## Available Enums

### Type System
- **Enums.Type** - Element types for monsters, moves, and items
  - Used in: MonsterTemplate, MoveTemplate, ItemTemplate, TypeChart
  - Values: NONE, NORMAL, FIRE, WATER, ELECTRIC, GRASS, ICE, FIGHTING, POISON, GROUND, FLYING, PSYCHIC, BUG, ROCK, GHOST, DRAGON, DARK, STEEL, FAIRY

### Combat System
- **Enums.AttackType** - Physical, Special, or Status moves
  - Used in: MoveTemplate
  - Values: PHYSICAL, SPECIAL, STATUS

- **Enums.Target** - Who can be targeted by moves/items
  - Used in: MoveTemplate, ItemTemplate
  - Values: ENEMY_SINGLE, ENEMY_ALL, ALLY_SINGLE, ALLY_ALL, ALL, SELF

### QTE System
- **Enums.QTEType** - Types of Quick Time Events
  - Used in: MoveTemplate, QTESystem
  - Values: NONE, BUTTON_MASH, TIMED_PRESS, SEQUENCE, HOLD, RHYTHM

- **Enums.QTEResult** - Result quality of QTE performance
  - Used in: QTESystem
  - Values: FAILURE, PARTIAL, SUCCESS, PERFECT

### Monster System
- **Enums.GrowthRate** - How fast monsters level up
  - Used in: MonsterTemplate
  - Values: FAST, MEDIUM, SLOW

### Item System
- **Enums.ItemCategory** - Type of item
  - Used in: ItemTemplate
  - Values: CONSUMABLE, BATTLE_ITEM, CAPTURE, EVOLUTION, KEY_ITEM, HELD_ITEM

- **Enums.UseContext** - Where items can be used
  - Used in: ItemTemplate
  - Values: BATTLE, OVERWORLD, BOTH

### Ability System
- **Enums.TriggerType** - When abilities activate
  - Used in: AbilityTemplate
  - Values: PASSIVE, ON_BATTLE_START, ON_SWITCH_IN, ON_TAKING_DAMAGE, ON_DEALING_DAMAGE, ON_TURN_START, ON_TURN_END, ON_HP_THRESHOLD, ON_STATUS, ON_MOVE_USED, ON_WEATHER, ON_TERRAIN, ON_FAINT

### Status Effect System
- **Enums.StatusType** - Duration type of status effects
  - Used in: StatusEffectTemplate
  - Values: PERSISTENT, TEMPORARY, INSTANT

## Usage Examples

### Accessing Enums
```gdscript
# Set a monster's type
var monster = MonsterData.new()
monster.primary_type = Enums.Type.FIRE
monster.secondary_type = Enums.Type.FLYING

# Set a move's properties
var move = MoveData.new()
move.MoveType = Enums.Type.FIRE
move.AttackType = Enums.AttackType.SPECIAL
move.Target = Enums.Target.ENEMY_SINGLE
move.QTEType = Enums.QTEType.TIMED_PRESS

# Check type effectiveness
var effectiveness = TypeChart.get_effectiveness(Enums.Type.WATER, [Enums.Type.FIRE])
```

### Comparing Enum Values
```gdscript
# Check if a QTE was successful
if qte_result == Enums.QTEResult.PERFECT:
    print("Perfect QTE!")

# Check monster type
if monster.primary_type == Enums.Type.FIRE:
    print("Fire type monster!")
```

## Benefits

1. **Single Source of Truth**: Change an enum once and it updates everywhere
2. **No Duplication**: No need to maintain the same enum in multiple files
3. **Consistency**: All files use the same enum values
4. **Easier Refactoring**: Rename or add enum values in one place
5. **Better Intellisense**: IDE can suggest all available enum values from Enums class

## Modifying Enums

To add, remove, or rename enum values:

1. Open [Enums.gd](Enums.gd)
2. Find the relevant enum
3. Make your changes
4. All files automatically use the updated enum!

**Note**: Godot will automatically update any `.tres` resource files that use these enums.

## Migration Notes

The following local enums have been moved to Enums.gd:
- `MoveData.e_Type` → `Enums.Type`
- `MoveData.e_AttackType` → `Enums.AttackType`
- `MoveData.e_Target` → `Enums.Target`
- `MoveData.e_QTEType` → `Enums.QTEType`
- `MonsterData.e_Type` → `Enums.Type`
- `MonsterData.e_GrowthRate` → `Enums.GrowthRate`
- `ItemData.e_Type` → `Enums.Type`
- `ItemData.e_Target` → `Enums.Target`
- `ItemData.e_ItemCategory` → `Enums.ItemCategory`
- `ItemData.e_UseContext` → `Enums.UseContext`
- `TypeChart.Type` → `Enums.Type`
- `AbilityData.e_TriggerType` → `Enums.TriggerType`
- `StatusEffect.e_Type` → `Enums.StatusType`
- `QTESystem.QTEType` → `Enums.QTEType`
- `QTESystem.QTEResult` → `Enums.QTEResult`
