extends Node3D
class_name SolarSystem

# var 实例: SolarSystem = self
var 天体表: Array = 初始化所有子天体()

func 初始化所有子天体() -> Array:
	var 子节点 := self.get_children()
	var 表 = []
	
	for child in 子节点:
		if (child is 天体):
			表.append(child)
	
	表.sort_custom(func(a: 天体, b: 天体): return a.取父天体数量() < b.取父天体数量())
	
	for 子天体 in 表:
		子天体.初始化()
	return 表

func _ready():
	# 实例 = self
	天体表 = 初始化所有子天体()
