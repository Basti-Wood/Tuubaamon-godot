extends Resource
class_name ItemData

# =========================
# IDENTIFICATION
# =========================

@export var ItemName: String
@export var ItemID: int
@export_multiline var Description: String
@export var Icon: Texture2D
@export var Category: Enums.ItemCategory = Enums.ItemCategory.CONSUMABLE
@export var UseContext: Enums.UseContext = Enums.UseContext.BOTH

# =========================
# USAGE
# =========================

@export var Consumable: bool = true
@export var Target: Enums.Target = Enums.Target.ALLY_SINGLE
@export var MaxStack: int = 99
@export var BuyPrice: int = 100
@export var SellPrice: int = 50

# =========================
# EFFECTS
# =========================

# HP/PP Restoration
@export var RestoresHP: int = 0
@export var RestoresHPPercent: float = 0.0  # 0.0 to 1.0
@export var RestoresPP: int = 0
@export var RestoresAllPP: bool = false

# Status Effects
@export var CuresStatus: bool = false
@export var CuresAllStatus: bool = false
@export var SpecificStatusCure: Array[String] = []  # Names of specific statuses to cure

@export var RevivesMonster: bool = false
@export var ReviveHPPercent: float = 0.5

# Stat Boosts (temporary in battle)
@export var BoostAttack: int = 0        # Stages +1 to +6
@export var BoostDefense: int = 0
@export var BoostSpecialAttack: int = 0
@export var BoostSpecialDefense: int = 0
@export var BoostSpeed: int = 0
@export var BoostAccuracy: int = 0
@export var BoostEvasion: int = 0

# Capture mechanics
@export var CaptureRateBonus: float = 1.0  # Multiplier for capture (e.g., 2.0 = 2x easier)

# Evolution
@export var TriggersEvolution: bool = false
@export var EvolutionTypes: Array[Enums.Type] = []  # Which types can evolve with this

# Held Item Effects
@export var HeldItemEffect: String = ""  # Description of passive effect when held
@export var HeldDamageBonus: float = 1.0    # Damage multiplier when held
@export var HeldTypeBoost: Enums.Type = Enums.Type.NONE  # Boosts moves of this type

# =========================
# BATTLE TEXT
# =========================

@export_multiline var UseText: String = ""  # Text displayed when used
@export var UseSound: AudioStream

# =========================
# SPECIAL FLAGS
# =========================

@export var OneTimeUse: bool = false  # For key items
@export var Tradeable: bool = true
@export var Droppable: bool = true
