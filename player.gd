extends CharacterBody3D

@export var walk_speed: float = 5.2
@export var sprint_speed: float = 8.0
@export var acceleration: float = 18.0
@export var gravity: float = 22.0
var can_move := true

func _physics_process(delta: float) -> void:
    if not can_move:
        velocity = Vector3.ZERO
        return
    var input_dir := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
    )
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    var speed := sprint_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
    if direction.length() > 0.1:
        velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
        velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
        rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 8.0)
    else:
        velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
        velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0
    move_and_slide()
