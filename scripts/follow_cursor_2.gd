extends CharacterBody2D

@export var max_velocity = 250.0
@export var max_acceleration = 100.0
@export var slowing_distance := 100.0  
@export var max_rotation = deg_to_rad(20) # Maximum rotation in radians

# var speed := 200.0

var P0: Vector2
var P1: Vector2
var P2: Vector2
var P3: Vector2
var direction: Vector2

var v_0: float = 10.0
var t: float = 0.2  # Parameter for the Bezier curve

var speed: float = 10.0
var target_position: Vector2
var moving: bool = false

var trajectory_line: Line2D

func angle_to_vector2(radians: float) -> Vector2:
	# Convert the angle from degrees to radians if necessary
	var x = cos(radians)
	var y = sin(radians)

	# Create and return the vector
	return Vector2(x, y)

func vector2_to_angle(vector: Vector2) -> float:
	# Calculate the angle in radians using atan2
	var angle_radians = atan2(vector.y, vector.x)

	return angle_radians

var start_point: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	P0 = position
	direction = angle_to_vector2(rotation)
	P1 = calculate_control_point(P0, direction, v_0)
	
	trajectory_line = Line2D.new()
	trajectory_line.width = 1
	trajectory_line.default_color = Color(1, 0, 0)
	add_child(trajectory_line)
	start_point = global_position
	trajectory_line.rotation = global_rotation

func calc_control_point_2(p0: Vector2, p3: Vector2, direction: Vector2, speed: float):
	var control_distance = speed * 0.5  # Adjust the multiplier as needed
	var control_point = p0
	
	if (p3.y > p0.y):
		control_point.y += control_distance
	else:
		control_point.y -= control_distance
	
	return control_point

func _input(event):
	if event is InputEventMouseMotion:
		# P0 = position
		# P1 = calculate_control_point(P0, direction, v_0 * 10)
		# P3 = event.position - global_position
		# P2 = calc_control_point_2(P0, P3, direction, v_0 * 10)
		# draw_trajectory()
		target_position = event.position - global_position

func test1231(delta):
	var direction = (target_position - global_position).normalized()
	var desired_angle = calculate_tangent2(P0, P1, P3, t)
	
	var desired_angle_rad = vector2_to_angle(desired_angle)
	var current_angle = rotation
	
	var angle_difference = desired_angle_rad - current_angle
	
	rotation += angle_difference

func what_fuck(delta):
	P0 = position
	P1 = calculate_control_point(P0, direction, v_0)
	P2 = target_position

func latest_shit(delta):
	P1 = calculate_control_point(P0, direction, v_0)

	var direction = (target_position - global_position).normalized()
	
	var angle_to_target = direction.angle()
	var current_angle = rotation
	
	var angle_difference = angle_to_target - current_angle
	
	angle_difference = atan2(sin(angle_difference), cos(angle_difference))
	
	if abs(angle_difference) > max_rotation * delta:
		angle_difference = sign(angle_difference) * max_rotation * delta

	rotation += angle_difference
	
	var new_direction = angle_to_vector2(rotation)
	
	velocity = new_direction.normalized() * v_0

	move_and_slide()

func calculate_control_point(p0: Vector2, direction: Vector2, speed: float) -> Vector2:
	var control_distance = speed * 0.5  # Adjust the multiplier as needed
	var control_point = p0 + (direction.normalized() * control_distance)
	return control_point

func calculate_bezier_point(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q1 = p0.lerp(p1, t)
	var q2 = p1.lerp(p2, t)
	return q1.lerp(q2, t)

func calculate_tangent3(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, delta: float) -> Vector2:
	var q0 = p0.lerp(p1, delta)
	var q1 = p1.lerp(p2, delta)
	var q2 = p2.lerp(p3, delta)
	
	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)
	
	var tangent = 3 * (r0 - r1)
	return tangent.normalized()

func calculate_tangent2(p0: Vector2, p1: Vector2, p2: Vector2, delta: float) -> Vector2:
	var q0 = p0.lerp(p1, delta)
	var q1 = p1.lerp(p2, delta)
	
	var tangent = 2 * (q0 - q1)
	return tangent.normalized()

func calculate_tangent_vector(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	# Derivative of the quadratic Bezier curve:
	# B'(t) = 2 * (1 - t) * (P1 - P0) + 2 * t * (P2 - P1)

	var one_minus_t = 1.0 - t
	var tangent: Vector2 = 2 * one_minus_t * (p1 - p0) + 2 * t * (p2 - p1)
	return tangent.normalized()  # Return the normalized tangent vector

func bezier3(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var q2 = p2.lerp(p3, t)
	
	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)
	
	return r0.lerp(r1, t)

func draw_trajectory():
	trajectory_line.clear_points()
	var points = []
	for i in range(101):
		var t = i / 100.0
		var point = calculate_bezier_point(P0, P1, target_position - start_point, t)
		points.append(point)
	trajectory_line.points = points
	
	points = []
	for i in range(101):
		var t = i / 100.0
		var point = bezier3(P0, P1, P2, P3, t)
		points.append(point)
	trajectory_line.points = points
	
	# print(calculate_length(trajectory_line))

func calculate_length(line: Line2D) -> float:
	if len(line.points) < 2:
		return 0.0
	
	var length: float = 0.0
	var prevPoint: Vector2 = line.points[0]
	var currPoint: Vector2
	
	for idx in range(1, len(line.points)):
		currPoint = line.points[idx]
		length += prevPoint.distance_to(currPoint)
		prevPoint = currPoint
	
	return length

func yet_another(delta):
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)

	# Calculate the desired speed
	var desired_speed = speed
	if distance_to_target < slowing_distance:
		desired_speed = speed * (distance_to_target / slowing_distance)

	# Calculate the desired velocity
	var desired_velocity = direction * desired_speed

	# Calculate the steering force
	var steering = desired_velocity - velocity
	velocity += steering * delta

	var angle_to_target = direction.angle()
	var current_angle = rotation
	var angle_difference = angle_to_target - current_angle

	if abs(angle_difference) > max_rotation * delta:
		angle_difference = sign(angle_difference) * max_rotation * delta

	# Apply the movement
	rotation += angle_difference
	
	move_and_slide()

func first_shit(delta):
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)
	
	# Calculate the desired speed
	var desired_speed = velocity
	if distance_to_target < slowing_distance:
		desired_speed = speed * (distance_to_target / slowing_distance)

	var desired_velocity = direction * desired_speed

	var steering = desired_velocity - velocity
	if steering.length() > max_acceleration:
		steering = steering.normalized() * max_acceleration


	velocity += steering * delta
	if velocity.length() > max_velocity:
		velocity = velocity.normalized() * max_velocity

	var angle_to_target = direction.angle()
	var current_angle = rotation
	var angle_difference = angle_to_target - current_angle

	if abs(angle_difference) > max_rotation * delta:
		angle_difference = sign(angle_difference) * max_rotation * delta

	rotation += angle_difference

	move_and_slide()

@export var v_t: float = 10.0
@export var r_t: float = 30.0

func _physics_process(delta):
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)
	
	var speed = distance_to_target
	speed = clampf(speed, 0.0, v_t)
	
	var desired_angle = direction.angle()
	var desired_rotation_diff = desired_angle - rotation
	
	var rotation_diff = clampf(desired_rotation_diff, -r_t, r_t)
	
	rotation += rotation_diff * delta
	velocity = speed * direction
	
	move_and_slide()	
