# Spawner

>Make an issue on github if you want to add anything or report a bug. Also thanks to micycle8778 for their customizable packed scene [script](https://github.com/micycle8778/customizable-packed-scene/tree/master)

1. **Download the project files.**
2. Move the `spawner` folder into your `/addons` folder inside your Godot project.
3. Enable the **addon** through the project settings, and start spawning endless amount of enemies with **ease!**

## Key Features
There are **multiple new nodes** with this addon! The following are [Spawner Container](#spawner-container), [Wave Manager](#wave-manager), [Spawner](#spawner-1), and 
[Multiple Spawner](#multiple-spawner).

# Videos
[![Watch the video](https://img.youtube.com/vi/iu7QYOg6fM4/maxresdefault.jpg)](https://youtu.be/iu7QYOg6fM4)


# Spawner Container
The **Spawner Container** must be **used as the parent** of either the **Spawner** or **Multiple Spawner** nodes. 

In the **Inspector** you can:
* Manually **start or stop the waves** as soon as the game loads (_ready()).
* A max number of active enemies. 


In the **signals**:
* **Remotely start or stop the wave**. 

Here is an example on what the signal connections would look like from the **Spawner Container** into your level script:

```gdscript
extends Node2D

@onready var single_enemy_spawner_container_node  = $SpawnerContainer

func _on_start_single_pressed():
    single_enemy_spawner_container_node.start_wave.emit(true)

func _on_stop_single_pressed():
    single_enemy_spawner_container_node.start_wave.emit(false)
```

# Wave Manager
The **Wave Manager** handles spawning waves of enemiess across **multiple Spawner Containers** automatically.

Place the **Wave Manager** as a node in your **level scene**, that your Spawner Container nodes are in.

In the **Inspector** you can:
* Add **Wave Resources** to the waves array, one per wave.
* **Auto Start** the waves as soon as the game loads in the _ready()
* Set the **time between waves** in seconds.

In the **signals**:
* Emits a signal when a **wave starts**, with the wave index (starts at 0).
* Emits a signal when a **wave is completed**, with the wave index (starts at 0).
* Emits a signal with the **time remaining** before the next wave starts.
* Emits a signal once **all waves are completed** (How many waves you set in the inspector with the wave resources).

Here is an example on what the signal connections would look like in your level script:
```gdscript
extends Node2D

@onready var wave_manager : WaveManager = $WaveManager

func _ready():
    wave_manager.wave_started.connect(_on_wave_started)
    wave_manager.wave_completed.connect(_on_wave_completed)
    wave_manager.between_waves_countdown.connect(_on_countdown)
    wave_manager.all_waves_completed.connect(_on_all_waves_completed)

func _on_wave_started(index):
    print("Wave started: " + str(index))

func _on_wave_completed(index):
    print("Wave completed: " + str(index))

func _on_countdown(time_left):
    print("Next wave in: " + str(time_left))

func _on_all_waves_completed():
    print("All waves completed!")
```

# Spawner
The Enemy Spawner must have its **enemy scene and max enemy spawn amount set in the Inspector**.

You can also:

* Change the **time between each spawn** (in seconds).

* **Enable custom spawn area** if you want enemies to spawn in a specific region.

To use a **custom spawn area**:

1. Add a **CollisionShape**.

2. Set its **shape to Rectangle**.

3. Make sure to **disable it**.

4. Then, in the **Spawner**, set that **CollisionShape** as the **spawn area**.

In the **signals**:
* Emits a signal on how many enemies are spawned.

* Emits a signal that passes a parameter of the object spawned.

* Emits a signal once that spawner finished spawning.

Here is an example on what the signal connections would look like in your level script:

```gdscript
extends Node2D

@onready var single_enemy_spawner_node  = $SpawnerContainer/Spawner

func _ready():
	single_enemy_spawner_node.enemy_spawned.connect(single_spawner_enemy_spawned)
    single_enemy_spawner_node.amount_enemy_spawned.connect(single_spawner_amount_of_enemy_spawned)
	single_enemy_spawner_node.finished_spawning.connect(single_spawner_finished_spawning)

func single_spawner_enemy_spawned(enemy):
	print("Enemy name: " + str(enemy.name))

func single_spawner_amount_of_enemy_spawned(amount):
	print("Single enemy spawner spawned: " + str(amount))

func single_spawner_finished_spawning():
	print("Single enemy spawner finished spawning.")
```
# Multiple Spawner
The **Multiple Spawner** works similarly to the normal Spawner, but with some differences.

In the **Inspector** you have to:

1. Open the **Enemy Scene Array** and add a new element.

2. Click **New EnemyResource** for each enemy you want to add.

3. Inside each **EnemyResource**, select the *enemy scene*, set the **chance for it to spawn**, the **maximum amount** of that enemy to spawn, and its **size in pixels**.

You can also:

* Change the **time between each spawn** (in seconds).

* **Enable custom spawn area** if you want enemies to spawn in a specific region.

To use a **custom spawn area**:

1. Add a **CollisionShape**.

2. Set its **shape to Rectangle**.

3. Make sure to **disable it**.

4. Then, in the **Spawner**, set that **CollisionShape** as the **spawn area**.

In the **signals**:
* Emits a signal on how many enemies are spawned.

* Emits a signal that passes a parameter of the object spawned.

* Emits a signal once that spawner finished spawning.

Here is an example on what the signal connections would look like in your level script:
```gdscript
extends Node2D

@onready var multi_enemy_spawner_node  = $SpawnerContainer/MultipleSpawner

func _ready():
	multi_enemy_spawner_node.enemy_spawned.connect(multiple_spawner_enemy_spawned)
    multi_enemy_spawner_node.amount_enemy_spawned.connect(multiple_spawner_amount_enemy_spawned)
	multi_enemy_spawner_node.finished_spawning.connect(multiple_spawner_finished_spawning)

func multiple_spawner_enemy_spawned(enemy):
	print("Enemy name: " + str(enemy.name))

func multiple_spawner_amount_enemy_spawned(amount):
	print("Multiple enemy spawner spawned: " + str(amount))

func multiple_spawner_finished_spawning():
	print("Multiple enemy spawner finished spawning.")

```

