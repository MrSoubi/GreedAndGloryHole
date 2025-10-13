# GreedAndGloryHole - Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Architecture & Design Patterns](#architecture--design-patterns)
4. [Core Systems](#core-systems)
5. [File Structure](#file-structure)
6. [Development Guidelines](#development-guidelines)
7. [Key Components Reference](#key-components-reference)

---

## Project Overview

**GreedAndGloryHole** is a 3D action game built with Godot 4.5. The game features a first-person player controller with advanced movement mechanics (walking, sliding, jumping) and a modular upgrade system that allows dynamic modification of player stats and behaviors.

### Core Gameplay Features
- **Advanced Movement System**: Ground, air, and slide movement states with physics-based mechanics
- **Upgrade System**: Three-tier upgrade system (StatBoosts, Equipment, Effects)
- **Event-Driven Architecture**: Global event bus for decoupled communication
- **Dynamic Stats**: Stat system with base values, additive bonuses, and multipliers

---

## Technology Stack

- **Engine**: Godot 4.5 (Forward Plus renderer)
- **Language**: GDScript
- **Target Resolution**: 640x480 (viewport stretched)
- **Control Scheme**: WASD movement, Space (jump), Shift (slide)

---

## Architecture & Design Patterns

### 1. Strategy Pattern (Movement System)
The player movement is implemented using the Strategy pattern, allowing different movement behaviors to be swapped at runtime:

```
PlayerMovementStrategy (abstract base)
    ├── GroundMovement
    ├── AirMovement
    └── SlideMovement
```

**Benefits**:
- Clean separation of movement logic
- Easy to add new movement modes
- Runtime strategy switching based on player state

### 2. Observer Pattern (Event Bus)
A global EventBus singleton manages all game events, enabling loose coupling between systems:

```gdscript
EventBus.on_player_jumped.emit(jump_count)
EventBus.on_player_landed.connect(_on_player_landed)
```

### 3. Composition over Inheritance
The stats system uses composition with `StatDefinition` resources that can be mixed and matched:

```gdscript
@export var walk_speed : StatDefinition
@export var jump_force : StatDefinition
```

### 4. Singleton Pattern (Autoloads)
Global managers are implemented as autoloaded singletons:
- `PlayerStatsManager`: Central player stats management
- `UpgradeManager`: Handles upgrade application/removal
- `GameContext`: Maintains references to active game objects
- `EventBus`: Global event system
- `FeedbackManager`: Visual/audio feedback coordination
- `AudioManager`: Sound effect management

---

## Core Systems

### Player Controller System

The `PlayerController` class (`CharacterBody3D`) is the heart of player interaction:

**Key Responsibilities**:
- Input handling (mouse look, movement keys)
- State management (grounded, sliding, airborne)
- Movement strategy selection and execution
- Event emission for gameplay actions

**Configuration Constants**:
```gdscript
const SENSITIVITY: float = 0.002
const SLIDE_DOWNWARD_FORCE: float = 20.0
const MIN_SLOPE_ANGLE: float = 5.0
const DECELERATION_RATE: float = 10.0
const ACCELERATION_ON_SLOPE: float = 100.0
const SLIDE_JUMP_GRAVITY_MULTIPLIER: float = 0.8
const SLIDE_MAX_SPEED: float = 1000.0
```

**State Variables**:
- `jump_count`: Tracks consecutive jumps
- `is_sliding`: Current slide state
- `is_slide_jumping`: Special jump from slide
- `air_time`: Duration of current air time
- `slide_time`: Duration of current slide

**Physics Process Flow**:
1. Capture input direction
2. Select appropriate movement strategy
3. Execute strategy's move logic
4. Apply velocity and move_and_slide()
5. Update timers and emit events

### Movement Strategy System

Each strategy implements the abstract `PlayerMovementStrategy` class:

#### GroundMovement
- Handles walking and basic jumping
- Initiates sliding when conditions met
- Resets jump counter when grounded

#### AirMovement
- Applies gravity with slide-jump modifier
- Provides air control (lerp toward target velocity)
- Preserves horizontal momentum if exceeds walk speed
- Handles multi-jump logic

#### SlideMovement
- Maintains slide velocity with downward force
- Accelerates on slopes based on angle
- Handles slide-to-jump transition
- Decelerates on flat surfaces

### Stat System

Stats are defined as `StatDefinition` resources with:
- `base_value`: Starting value
- `additive`: Flat bonuses (e.g., +10)
- `multiplier`: Percentage bonuses (e.g., 1.5x)

**Calculation**:
```gdscript
current_value = (base_value + additive) * multiplier
```

**Available Stats**:
- `walk_speed`: Ground movement speed
- `fire_rate`: Attack speed
- `jump_force`: Jump power
- `max_health`: Health pool
- `size`: Player scale
- `weight`: Physics weight
- `air_control`: Air movement responsiveness
- `consecutive_jumps`: Multi-jump count
- `slide_speed`: Maximum slide velocity
- `harvest_range`: Collection distance
- `harvest_rate`: Collection speed

### Upgrade System

Three-tier hierarchy for different upgrade types:

#### BaseUpgrade (Abstract)
```gdscript
@export var stat_to_upgrade : StatDefinition
@export var additive : float
@export var multiplier : float
```

**Methods**:
- `apply_effect()`: Modifies the target stat
- `remove_effect()`: Reverts modifications

#### StatBoostUpgrade
Simple stat increases that reset every run. Used for temporary power-ups.

**Use Cases**:
- In-run power-ups
- Temporary buffs
- Level-up bonuses

#### EquipmentUpgrade
Permanent meta-progression upgrades with slot management.

```gdscript
@export var is_permanent := true
@export var slot : int = 0
```

**Use Cases**:
- Persistent upgrades between runs
- Build customization
- Meta-progression rewards

#### EffectUpgrade
Custom behavior upgrades that don't fit simple stat modifications.

**Examples**:

1. **ExplosiveJumpEffectUpgrade**
   - Triggers shockwave on jump
   - Pushes enemies away within radius
   - Connects to `EventBus.on_player_jump`

2. **MagnetEffectUpgrade**
   - Attracts nearby pickups
   - Uses physics-based pull force
   - Processes every frame

3. **HealingAuraEffectUpgrade**
   - Periodic health regeneration
   - Creates timer in scene tree
   - Auto-cleanup on removal

4. **AgilityOnEnemyJumpUpgrade**
   - Incremental stat boost on enemy jumps
   - Percentage-based increase
   - Stacks indefinitely

### UpgradeManager

Central singleton for upgrade lifecycle management:

```gdscript
var stat_boosts : Array = []
var equipments : Array = []
var effect_upgrades : Array = []
var all_upgrades : Array = []
```

**API**:
- `add_upgrade(upgrade)`: Applies upgrade and tracks it
- `remove_upgrade(upgrade)`: Reverts upgrade effects
- `remove_all_upgrades()`: Clears all active upgrades

**Upgrade Application Flow**:
1. Validate upgrade instance
2. Add to appropriate category array
3. Call `upgrade.apply_effect()`
4. Track in `all_upgrades`

### Event Bus

Global event system for decoupled communication:

**Player Events**:
- `on_player_shot`: Weapon fired
- `on_player_jumped(jump_count)`: Jump performed
- `on_player_died`: Player death
- `on_player_started_sliding`: Slide initiated
- `on_player_stopped_sliding(slide_duration)`: Slide ended
- `on_player_landed(air_duration, jump_count)`: Grounded after airtime
- `on_player_jump_on_enemy()`: Jumped on enemy
- `on_player_process(delta)`: Per-frame player update

**Usage Pattern**:
```gdscript
# Emitting
EventBus.on_player_jumped.emit(jump_count)

# Connecting
EventBus.on_player_landed.connect(_on_player_landed)

# Disconnecting
EventBus.on_player_landed.disconnect(_on_player_landed)
```

### Game Context

Maintains runtime references to active game objects:

```gdscript
var player = null        # Reference to PlayerController
var enemies = []         # Array of enemy instances
var root = null          # Scene root node
```

**Purpose**:
- Global access to key game objects
- Avoids expensive `get_node()` calls
- Enables systems to find targets efficiently

### Feedback Manager

Coordinates visual and audio feedback:

```gdscript
enum FeedbackType {
    HEAL,
    DAMAGE,
    POWERUP
}
```

**Features**:
- VFX instantiation at world positions
- SFX playback via AudioManager
- Extensible for camera shake and other effects

**API**:
```gdscript
FeedbackManager.play_feedback(position, FeedbackType.DAMAGE)
```

---

## File Structure

```
GreedAndGloryHole/
├── project.godot              # Godot project configuration
├── icon.svg                   # Project icon
│
├── Scenes/                    # Scene files (.tscn)
│   ├── Player.tscn           # Player character scene
│   ├── World.tscn            # Main game world
│   ├── PickableUpgrade.tscn  # Collectible upgrade item
│   ├── PickableUpgrade.gd    # Pickup collision logic
│   └── debug_player.gd       # Debug utilities
│
├── Scripts/                   # GDScript source files
│   │
│   ├── Autoloads/            # Singleton managers
│   │   ├── PlayerStats.gd    # Player stat definitions
│   │   ├── UpgradeManager.gd # Upgrade system manager
│   │   ├── EventBus.gd       # Global event dispatcher
│   │   ├── GameContext.gd    # Runtime object references
│   │   ├── FeedbackManager.gd# VFX/SFX coordinator
│   │   └── AudioManager.gd   # Sound management
│   │
│   ├── Player/               # Player-related scripts
│   │   ├── StatDefinition.gd # Stat resource class
│   │   └── Controller/       # Movement system
│   │       ├── PlayerController.gd       # Main controller
│   │       ├── PlayerMovementStrategy.gd # Strategy base
│   │       ├── GroundMovement.gd        # Ground strategy
│   │       ├── AirMovement.gd           # Air strategy
│   │       └── SlideMovement.gd         # Slide strategy
│   │
│   └── Upgrades/             # Upgrade system
│       ├── BaseUpgrade.gd    # Upgrade base class
│       ├── StatBoostUpgrade.gd   # Simple stat boost
│       ├── EquipmentUpgrade.gd   # Permanent equipment
│       ├── EffectUpgrade.gd      # Custom effect base
│       └── Effects/              # Effect implementations
│           ├── ExplosiveJumpEffect.gd  # Jump shockwave
│           ├── MagnetEffect.gd         # Pickup magnet
│           ├── HealingAuraEffect.gd    # Regen aura
│           └── AgilityOnEnemyJump.gd   # Conditional boost
│
└── Data/                      # Resource files (.tres)
    ├── PlayerStats/          # Stat definitions
    │   ├── WalkSpeed.tres
    │   ├── JumpForce.tres
    │   ├── AirControl.tres
    │   └── ...
    └── Upgrades/             # Upgrade resources
        ├── UP_FireRate_A.tres
        ├── UP_JumpCount_A.tres
        └── ...
```

---

## Development Guidelines

### Adding New Movement States

1. Create new class extending `PlayerMovementStrategy`
2. Implement `move(controller, delta)` method
3. Export as `@export var new_strategy: Resource` in PlayerController
4. Add to `movement_strategies` dictionary in `_ready()`
5. Add state transition logic in `_physics_process()`

**Example**:
```gdscript
extends PlayerMovementStrategy
class_name WallRunMovement

func move(controller: CharacterBody3D, delta: float) -> void:
    # Wall run logic here
    pass
```

### Creating New Upgrades

#### Simple Stat Boost:
1. Create `.tres` resource file
2. Set type to `StatBoostUpgrade`
3. Assign `stat_to_upgrade` reference
4. Set `additive` and/or `multiplier` values

#### Custom Effect:
1. Create new `.gd` script extending `EffectUpgrade`
2. Override `apply_effect()` to set up behavior
3. Override `remove_effect()` to clean up
4. Connect to EventBus signals if needed
5. Create corresponding `.tres` resource

**Template**:
```gdscript
extends EffectUpgrade
class_name CustomEffectUpgrade

@export var param: float = 1.0

func apply_effect():
    super.apply_effect()
    EventBus.some_event.connect(_on_event)
    # Setup logic

func remove_effect():
    super.remove_effect()
    EventBus.some_event.disconnect(_on_event)
    # Cleanup logic

func _on_event():
    # Effect behavior
    pass
```

### Adding New Stats

1. Add property to `PlayerStats.gd`:
   ```gdscript
   @export var new_stat : StatDefinition
   ```

2. Create `.tres` resource in `Data/PlayerStats/`
3. Set base_value in the inspector
4. Reference in player controller or upgrade system

### Adding New Events

1. Define signal in `EventBus.gd`:
   ```gdscript
   signal on_new_event(param1: type, param2: type)
   ```

2. Emit where appropriate:
   ```gdscript
   EventBus.on_new_event.emit(value1, value2)
   ```

3. Connect in systems that need to respond:
   ```gdscript
   EventBus.on_new_event.connect(_callback)
   ```

### Working with GameContext

**Setup** (in scene root or manager):
```gdscript
func _ready():
    GameContext.player = $Player
    GameContext.enemies = get_tree().get_nodes_in_group("Enemies")
    GameContext.root = get_tree().current_scene
```

**Usage** (in any script):
```gdscript
func apply_effect():
    var player_pos = GameContext.player.global_position
    for enemy in GameContext.enemies:
        # Process each enemy
        pass
```

### Best Practices

1. **Stat Modifications**: Always use the upgrade system, never modify stats directly
2. **Event Connections**: Always disconnect in `remove_effect()` or cleanup methods
3. **Resource Duplication**: Call `.duplicate()` on upgrade resources before applying
4. **Validation**: Check `is_instance_valid()` before accessing references
5. **Constants**: Define tuning values as exported properties or constants
6. **Error Handling**: Use `push_error()` for critical issues, `push_warning()` for non-critical
7. **Scene Tree**: Add temporary nodes to `GameContext.root`, not directly to player
8. **Timers**: Always clean up timers with `queue_free()` or `stop()`

### Debugging Tips

1. **Movement Issues**: Check which strategy is active in `current_movement_strategy`
2. **Stat Problems**: Print `stat.current_value` to see computed value
3. **Event Not Firing**: Verify signal connections with `get_signal_connection_list()`
4. **Upgrade Not Working**: Check `UpgradeManager.all_upgrades` array
5. **Performance**: Use `delta` timing, avoid `get_tree()` in loops

### Common Pitfalls

1. **Forgetting to call super()**: Always call `super.apply_effect()` in overrides
2. **Not disconnecting signals**: Leads to errors when nodes are freed
3. **Modifying base_value**: Use `additive` and `multiplier` instead
4. **Scene tree timing**: Ensure nodes exist before accessing in `_ready()`
5. **Resource sharing**: Upgrades must be duplicated to avoid cross-contamination

---

## Key Components Reference

### PlayerController Quick Reference

**Exported Properties**:
- `camera_pivot: Node3D` - Camera rotation pivot point
- `ground_strategy: Resource` - Ground movement strategy
- `air_strategy: Resource` - Air movement strategy
- `slide_strategy: Resource` - Slide movement strategy

**Public Variables**:
- `jump_count: int` - Current consecutive jump count
- `current_velocity: Vector3` - Desired velocity for next frame
- `is_sliding: bool` - Slide state flag
- `is_slide_jumping: bool` - Special slide-jump flag

### StatDefinition Quick Reference

**Properties**:
- `base_value: float` - Unchanging base stat
- `additive: float` - Flat modifiers (e.g., +10)
- `multiplier: float` - Percentage modifiers (e.g., 1.5x)
- `current_value: float` - Computed read-only result

### BaseUpgrade Quick Reference

**Properties**:
- `stat_to_upgrade: StatDefinition` - Target stat
- `additive: float` - Flat bonus to apply
- `multiplier: float` - Multiplier bonus to apply

**Methods**:
- `apply_effect()` - Apply stat modifications
- `remove_effect()` - Revert stat modifications

### EventBus Events Quick Reference

| Event | Parameters | Description |
|-------|------------|-------------|
| `on_player_shot` | None | Player fired weapon |
| `on_player_jumped` | `jump_count: int` | Player jumped |
| `on_player_died` | None | Player died |
| `on_player_started_sliding` | None | Slide started |
| `on_player_stopped_sliding` | `slide_duration: float` | Slide ended |
| `on_player_landed` | `air_duration: float, jump_count: int` | Player hit ground |
| `on_player_jump_on_enemy` | None | Jumped on enemy head |
| `on_player_process` | `delta: float` | Per-frame update |

---

## Future Development Considerations

### Potential Extensions

1. **Combat System**
   - Weapon management
   - Projectile handling
   - Enemy AI and health

2. **Resource/Economy System**
   - Collectible currency
   - Shop/vendor system
   - Persistent progression

3. **Level System**
   - Procedural generation
   - Level serialization/loading
   - Checkpoint system

4. **UI System**
   - HUD overlay
   - Upgrade selection menus
   - Pause/settings screens

5. **Save System**
   - Profile management
   - Equipment persistence
   - Settings storage

### Architectural Recommendations

- **Combat**: Consider creating a separate `CombatManager` autoload
- **Economy**: Use resource-based currency definitions similar to stats
- **Persistence**: Implement `save_data()` and `load_data()` methods per system
- **UI**: Use signal-based communication between UI and game logic
- **Networking**: If multiplayer needed, refactor state management for replication

---

## Getting Started for New Developers

1. **Clone Repository**: Get the latest code from the main branch
2. **Open in Godot 4.5**: Load `project.godot` in Godot Engine
3. **Explore Test Scene**: Open `Scenes/World.tscn` to see the game in action
4. **Run the Game**: Press F5 to test gameplay
5. **Study the Code**: Start with `PlayerController.gd` and `BaseUpgrade.gd`
6. **Experiment**: Create a simple `StatBoostUpgrade` resource and place in scene
7. **Review Events**: Look at `EventBus.gd` to understand the communication system
8. **Read This Doc**: Reference this document when implementing features

---

## Contact & Contribution

For questions, bug reports, or feature requests, please contact the repository maintainer or submit an issue on GitHub.

When contributing:
- Follow the existing code style and patterns
- Add comments for complex logic
- Test upgrades with multiple combinations
- Document new events or systems
- Update this document if adding major features

---

**Document Version**: 1.0  
**Last Updated**: 2025-10-13  
**Godot Version**: 4.5  
**Target Audience**: Developers joining the project
