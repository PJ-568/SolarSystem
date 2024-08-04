extends StaticBody3D
class_name 天体

@export_category("轨道相关")
@export var 父天体 : 天体	## 该天体是绕着什么天体转的。可为空。
@export var 轨道半径 : float	## 如果需要椭圆形轨道，可能要更复杂了。
@export var 轨道起始角度 : float

@export_category("重力相关")
@export var 天体半径 : float
@export var 体表重力 : float	## 天体“海平线”位置的重力大小。
var 天体质量 : float	# = 体表重力 * 天体半径 * 天体半径
var 重力加速度 : Vector3

@export_category("自转相关")
@export var 自转周期 : float
@export var 潮汐锁定 : bool	## 是否被父天体潮汐锁定。

func _ready():
	天体质量 = 体表重力 * 天体半径 * 天体半径

# 初始化天体的初始位置、速率自转等。在星系初始化时被调用。
func 初始化() -> void:
	if (父天体 != null):
		self.global_position = 父天体.global_position + (Vector3.FORWARD * 轨道半径).rotated(Vector3.UP, deg_to_rad(轨道起始角度))
		self.constant_linear_velocity = 父天体.constant_linear_velocity + 父天体.取轨道速率(self.global_position)
	
	if (潮汐锁定):
		自转周期 = 取公转周期()
	
	var 角速度 = 0 if 自转周期 == 0 else PI / 自转周期
	self.constant_angular_velocity = 角速度 * Vector3.UP	# Vector3.UP 为自转转轴
	
	print("初始化%" % name)

# 获取某一坐标处该天体的重力加速度
func 取重力加速度(全局位置:Vector3) -> Vector3:
	var d := self.global_position - 全局位置
	return d.normalized() * 天体质量 / d.length_squared()

# 获取该位置达到正圆形轨道所需速率
func 取轨道速率(全局位置:Vector3) -> Vector3:
	var d := self.global_position - 全局位置
	var 速度 := sqrt(天体质量 / d.length())
	var 方向 := d.normalized().cross(Vector3.UP)	# 此处的 Vector3.UP 指的是轨道平面的法向量。
	return 方向 * 速度

# 获取本天体的公转周期
func 取公转周期() -> float:
	return PI * sqrt(pow(轨道半径, 3) / 父天体.天体质量)

# 获取相对体表移动速度
func 取相对体表移速(全局位置:Vector3, 线速度:Vector3) -> Vector3:
	var 天体速率 := self.constant_linear_velocity
	var 天体转速 := self.constant_angular_velocity.cross(全局位置 - self.global_position)
	var 相对移速 := 线速度 - (天体速率 + 天体转速)
	return 相对移速

func _physics_process(delta):
	if (父天体 != null):
		重力加速度 = 父天体.取重力加速度(self.global_position) + 父天体.重力加速度
		
		self.constant_linear_velocity += 重力加速度 * delta
		self.global_position += constant_linear_velocity * delta
	
	self.global_position += self.constant_angular_velocity * delta

func 取父天体数量() -> int:
	if (父天体 == null):
		return 0
	else:
		return 父天体.取父天体数量() + 1
