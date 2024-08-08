extends RigidBody3D
class_name PJ568Player

@export_category("世界")
@export var 所处星系: SolarSystem

@export_category("节点")
@export var 镜头: Camera3D
@export var 镜头位点: Node3D
@export var 地面检测: RayCast3D

@export_category("设置")
@export var 鼠标灵敏度: float = .3
var 鼠标输入: Vector2
var 镜头X旋转: float
@export var 喷气背包强度: float = 800
@export var 自动转向速度: float = 2
@export var 跳跃强度: float = 5.0

var 最近的天体重力: Vector3 = Vector3.ZERO
var 在地图视角: bool

# 是否着陆 => 地面检测.is_colliding()
# 取地面 => 地面检测.get_collider() as 天体


func _ready():
	打开地图视角(false)


func 打开地图视角(设定在地图视角:bool) -> void:
	在地图视角 = 设定在地图视角
	if (在地图视角):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		镜头.current = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		镜头.current = true


func _physics_process(delta):
	for 子天体 in 所处星系.天体表:
		var force = 子天体.取重力加速度(global_position) * self.mass
		apply_central_force(force)

		# 忽略距离实在太远的天体的重力影响
		if (子天体.global_position.distance_to(global_position) < 2.0 * 子天体.天体半径):
			if (force.length() > 最近的天体重力.length()):
				最近的天体重力 = force # 确定“下”的方向


	if (not 在地图视角):
		处理运动输入(delta)
		处理镜头输入(delta)

	处理自动转向(delta)

	鼠标输入 = Vector2.ZERO


func 处理运动输入(_delta) -> void:
	var 移动方向 := Vector3.ZERO

	var 前 := -global_transform.basis.z
	var 左 := -global_transform.basis.x
	var 上 := global_transform.basis.y

	if (Input.is_action_pressed("前进")):
		移动方向 += 前
	if (Input.is_action_pressed("后退")):
		移动方向 -= 前
	if (Input.is_action_pressed("左移")):
		移动方向 += 左
	if (Input.is_action_pressed("右移")):
		移动方向 -= 左
	if (Input.is_action_pressed("上移")):
		移动方向 += 上
	if (Input.is_action_pressed("下移")):
		移动方向 -= 上

	if (移动方向 != Vector3.ZERO):
		apply_central_force(喷气背包强度 * 移动方向.normalized())

	if (地面检测.is_colliding() and Input.is_action_pressed("上移")):
		apply_central_impulse(跳跃强度 * 上)


func 处理镜头输入(_delta) -> void:
	var deltaX = 鼠标输入.y * 鼠标灵敏度
	var deltaY = -鼠标输入.x * 鼠标灵敏度

	if (Input.is_action_pressed("切换旋转")):
		rotate(镜头位点.global_transform.basis.z, deg_to_rad(deltaY))
	else:
		rotate_object_local(Vector3.UP, deg_to_rad(deltaY))
		if (镜头X旋转 + deltaX > -90 and 镜头X旋转 + deltaX < 90):
			镜头位点.rotate_x(deg_to_rad(-deltaX))
			镜头X旋转 += deltaX


func 处理自动转向(delta) -> void:
	angular_velocity = Vector3.ZERO
	angular_damp = 10.0

	var 不在重力范围: bool = 最近的天体重力 == Vector3.ZERO
	if (不在重力范围):
		var dx: float = lerp(0.0, -镜头X旋转, 自动转向速度 * delta)
		镜头X旋转 += dx

		镜头位点.rotate_x(deg_to_rad(-dx))
		rotate(镜头位点.global_transform.basis.x, deg_to_rad(dx))
	else:
		var 转向目标方向的向量 = Quaternion(global_transform.basis.y, -最近的天体重力.normalized()) * global_transform.basis.get_rotation_quaternion()
		if (地面检测.is_colliding()):
			global_rotation = 转向目标方向的向量.normalized().get_euler()
		else:
			global_rotation = global_transform.basis.get_rotation_quaternion().slerp(转向目标方向的向量.normalized(), 自动转向速度 * delta).get_euler()


func _input(event):
	if (event is InputEventMouseMotion):
		鼠标输入 += event.relative
	if (Input.is_action_just_released("暂停")):
		打开地图视角(not 在地图视角)
