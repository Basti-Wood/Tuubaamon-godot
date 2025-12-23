# ================================
# TUUBAAMON RESOURCE SYSTEM GUIDE
# ================================
# 
# This guide explains how to create resource files for your Pokémon-style game
# with Quick Time Event (QTE) support for moves.

## CREATING MONSTERS

To create a new monster:
1. In the Godot editor, create a new Resource in Resources/Monsters/
2. Set the script to: Scripts/Monster/MonsterTemplate.gd
3. Fill in the properties:
   - Name, ID, Description
   - Sprite and animations
   - Types (Normal, Fire, Water, etc.)
   - Base stats (HP, Attack, Defense, etc.)
   - Level-up moves dictionary

Example monster setup:
```
Name: "Flambit"
Monster ID: 1
Description: "A small fire creature that loves warmth."
Types: [FIRE]
Base HP: 45
Base Attack: 55
Base Defense: 40
Base Special Attack: 65
Base Special Defense: 50
Base Speed: 70
```

## CREATING MOVES

To create a new move with QTE:
1. Create a new Resource in Resources/Moves/
2. Set the script to: Scripts/Move/MoveTemplate.gd
3. Configure basic properties:
   - MoveName, Description
   - MoveType (element type)
   - AttackType (Physical, Special, or Status)
   - Damage, Accuracy, MaxPP
   - Target type

4. **Configure QTE settings:**
   - HasQTE: true
   - QTEType: Choose from:
     * BUTTON_MASH: Rapidly press button
     * TIMED_PRESS: Press at the right moment (like Paper Mario)
     * SEQUENCE: Press buttons in correct order
     * HOLD: Hold button for duration
     * RHYTHM: Press to the beat
   - QTETimeWindow: Time to complete (0.5 - 3.0 seconds)
   - QTEDifficulty: 1-10 scale
   - QTESuccessMultiplier: 1.5 = 50% more damage on success
   - QTEPartialMultiplier: 1.2 = 20% more damage on partial
   - QTEFailureMultiplier: 0.75 = 25% less damage on failure

Example move with QTE:
```
MoveName: "Flame Burst"
Description: "A fiery explosion requiring precise timing."
MoveType: FIRE
AttackType: SPECIAL
Damage: 60
Accuracy: 100
MaxPP: 15
Target: ENEMY_SINGLE

HasQTE: true
QTEType: TIMED_PRESS
QTETimeWindow: 1.0
QTEDifficulty: 3
QTESuccessMultiplier: 1.5  (90 damage on perfect timing)
QTEPartialMultiplier: 1.2  (72 damage on good timing)
QTEFailureMultiplier: 0.8  (48 damage on miss)
```

## CREATING ITEMS

To create items:
1. Create a new Resource in Resources/Items/
2. Set the script to: Scripts/Item/ItemTempalte.gd
3. Configure properties:
   - ItemName, ItemID, Description
   - Category (Consumable, Battle Item, Capture, etc.)
   - UseContext (Battle, Overworld, or Both)
   - Effects (RestoresHP, CuresStatus, BoostAttack, etc.)

Example healing item:
```
ItemName: "Healing Potion"
ItemID: 1
Description: "Restores 50 HP to a monster."
Category: CONSUMABLE
UseContext: BOTH
RestoresHP: 50
MaxStack: 99
BuyPrice: 200
```

Example capture item:
```
ItemName: "Capture Sphere"
ItemID: 10
Description: "Used to capture wild monsters."
Category: CAPTURE
UseContext: BATTLE
CaptureRateBonus: 1.0  (standard capture rate)
MaxStack: 99
BuyPrice: 100
```

## CREATING STATUS EFFECTS

To create status effects:
1. Create a new Resource in Resources/StatusEffects/
2. Set the script to: Scripts/StatusEffects/StatusEffectTemplate.gd
3. Configure properties

Example burn status:
```
Name: "Burn"
Description: "The monster is burned and takes damage each turn."
StatusType: PERSISTENT
MaxTurns: -1  (infinite)
CanStack: false
DamagePerTurnPercent: 0.0625  (6.25% of max HP)
AttackModifier: 0.5  (halves physical attack)
```

## CREATING ABILITIES

To create passive abilities:
1. Create a new Resource in Resources/Abilities/
2. Set the script to: Scripts/Abilities/AbilityTemplate.gd
3. Configure properties based on ability type

Example abilities:

**Blaze** (boosts Fire moves at low HP):
```
AbilityName: "Blaze"
Description: "Powers up Fire-type moves when HP is low."
TriggerType: ON_HP_THRESHOLD
HPThreshold: 0.33  (activates at 33% HP or less)
BoostMoveType: FIRE
MoveTypeBoost: 1.5  (50% damage boost)
```

**Intimidate** (lowers opponent's Attack on entry):
```
AbilityName: "Intimidate"
Description: "Lowers the opponent's Attack when entering battle."
TriggerType: ON_SWITCH_IN
AttackStageChange: -1
ActivationText: "[Monster]'s Intimidate lowered the opponent's Attack!"
```

**Thick Fat** (resists Fire and Ice):
```
AbilityName: "Thick Fat"
Description: "Thick fat protects from Fire and Ice moves."
TriggerType: PASSIVE
ResistMoveType: FIRE  (create two ability instances for Fire and Ice)
MoveTypeResistance: 0.5  (halves damage)
```

**Regenerator** (heals each turn):
```
AbilityName: "Regenerator"
Description: "Restores HP gradually each turn."
TriggerType: ON_TURN_END
RegeneratesHP: true
RegenPercentPerTurn: 0.0625  (6.25% per turn)
```

**Static** (may paralyze on contact):
```
AbilityName: "Static"
Description: "May paralyze attackers on contact."
TriggerType: ON_TAKING_DAMAGE
InflictsStatusOnContact: true
ContactStatus: [ParalysisStatusEffect]
ContactStatusChance: 30
```

## USING THE QTE SYSTEM IN BATTLE

The QTE system automatically integrates with the battle system. When a move
with HasQTE = true is used:

1. The battle system detects the QTE requirement
2. QTESystem.start_qte() is called with the move's settings
3. Player performs the QTE action
4. Damage is calculated with the appropriate multiplier
5. Results are displayed

### QTE Types Explained:

**BUTTON_MASH**: Press action button repeatedly before time runs out
- Good for powerful physical moves
- Difficulty = number of presses required

**TIMED_PRESS**: Press action button at the perfect moment
- Best for precise strikes (like Paper Mario)
- Difficulty = smaller timing window

**SEQUENCE**: Press directional buttons in order
- Good for combo moves
- Difficulty = longer sequence

**HOLD**: Hold action button for duration
- Good for charging attacks
- Difficulty = longer hold required

**RHYTHM**: Press button on the beat
- Good for musical or dance-based moves
- Difficulty = more beats to hit

## BATTLE SYSTEM INTEGRATION

The battle system (Scripts/Battle/battle_system.gd) handles:
- Turn order based on speed and move priority
- Automatic QTE initiation for moves
- Damage calculation with type effectiveness
- Status effects
- Stat changes
- Fainting and battle end conditions

To start a battle:
```gdscript
var battle_system = BattleSystem.new()

var player_team = [
	{
		"name": "Flambit",
		"level": 15,
		"types": [MoveData.e_Type.FIRE],
		"current_hp": 55,
		"max_hp": 55,
		"attack": 25,
		"defense": 20,
		# ... other stats
	}
]

var enemy_team = [
	{
		"name": "Aquadrop",
		"level": 14,
		"types": [MoveData.e_Type.WATER],
		# ... stats
	}
]

battle_system.start_battle(player_team, enemy_team)
```

## TYPE EFFECTIVENESS

The type chart (Scripts/Battle/type_chart.gd) includes all 18 Pokémon types:
- Fire > Grass, Ice, Bug, Steel
- Water > Fire, Ground, Rock
- Electric > Water, Flying
- etc.

Use TypeChart.get_effectiveness() to check matchups.

## DAMAGE CALCULATION

The damage calculator (Scripts/Battle/damage_calculator.gd) uses a formula
similar to Pokémon:

Damage = ((2 * Level / 5 + 2) * Power * Attack / Defense) / 50 + 2

Then applies modifiers:
- Critical hit: 1.5x
- STAB (Same Type Attack Bonus): 1.5x
- Type effectiveness: 0x, 0.5x, 1x, or 2x
- QTE multiplier: Based on performance
- Random factor: 0.85 to 1.0

## EXAMPLE RESOURCE WORKFLOW

1. Create a Fire-type starter monster
2. Create 4 moves with different QTE types for it
3. Create status effects (Burn, Paralysis)
4. Create healing items
5. Test in battle with the QTE system

The QTE system adds Paper Mario-style interactivity to every battle!
