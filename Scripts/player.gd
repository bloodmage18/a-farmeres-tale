extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _ready() -> void:
	# Task/tower logic looks her up by this group
	add_to_group("player")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# dialogue / scene fades freeze the player in place
	var locked: bool = GameState.input_locked

	# Handle jump.
	if not locked and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = 0.0 if locked else Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
