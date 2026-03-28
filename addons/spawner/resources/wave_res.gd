class_name WaveResource
extends Resource

@export var wave_name: String ## optional label like "Wave 5 - BOSS"
@export var time_between_waves: float = 3.0  ## override the manager's default
@export var max_active_enemies_override: int = -1  ## -1 = use container's default otherwise it overrides each spawner containers max active enemies.
