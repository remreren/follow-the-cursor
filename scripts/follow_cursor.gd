extends CharacterBody2D

@export var v_max: float = 10.0
@export var a_max: float = 100.0
@export var rot_max: float = deg_to_rad(50) # Maximum rotation in radians

var target_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	target_position = position

func _input(event):
	if event is InputEventMouseMotion:
		target_position = event.position
	
	if event is InputEventMouseButton:
		# target_position = event.position - global_position
		pass

func angle_to_vector2(radians: float) -> Vector2:
	# Convert the angle from degrees to radians if necessary
	var x = cos(radians)
	var y = sin(radians)

	# Create and return the vector
	return Vector2(x, y)

func _physics_process(delta):
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)
	
	if distance_to_target < 1:
		return
	
	var desired_angle = direction.angle()
	var current_angle = rotation
	var desired_rotation_diff = wrapf(desired_angle - current_angle, -PI, PI)

	if abs(desired_rotation_diff) > rot_max * delta:
		desired_rotation_diff = sign(desired_rotation_diff) * rot_max * delta
	
	rotation += desired_rotation_diff
	velocity = v_max * angle_to_vector2(rotation)
	
	move_and_slide()
