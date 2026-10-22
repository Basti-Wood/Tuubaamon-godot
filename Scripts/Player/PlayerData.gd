extends Resource
class_name PlayerData

## Player Character - The human who can battle directly or merge with monsters

# =========================
# IDENTITY
# =========================

@export var player_name: String = "Hero"
@export_multiline var description: String = ""
@export var sprite: Texture2D
@export var portrait: Texture2D

# =========================
# BASE STATS (human form)
# =========================

@export var base_hp: int = 100
@export var base_attack: int = 30
@export var base_defense: int = 25
@export var base_special_attack: int = 20
@export var base_special_defense: int = 20
@export var base_speed: int = 40

# =========================
# LEVEL & PROGRESSION
# =========================

@export var level: int = 1
@export var current_exp: int = 0
@export var exp_to_next_level: int = 100

# =========================
# INVENTORY
# =========================

@export var items: Array[ItemData] = []
@export var key_items: Array[ItemData] = []
@export var money: int = 0

# =========================
# MONSTER PARTY
# =========================

@export var monster_party: Array[MonsterData] = []  # Max 6 monsters
@export var active_monster_index: int = -1  # Currently selected monster

# =========================
# MERGE STATE
# =========================

@export var is_merged: bool = false
@export var merged_monster: MonsterData = null

# =========================
# EQUIPMENT (optional future expansion)
# =========================

@export var equipped_weapon: Resource = null
@export var equipped_armor: Resource = null
@export var equipped_accessory: Resource = null
