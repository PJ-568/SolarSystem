extends Node3D
class_name SolarSystem

var 实例 : SolarSystem = self
# var 天体表 = 取所有子天体()

func 取所有子天体():
	var 子节点 := self.get_children()
	var 天体表 = []
	
	for child in 子节点:
		if (child is 天体):
			天体表.append(child)
			child.初始化()
	
	天体表.sort_custom(比较父天体数量)
	return 天体表

func 比较父天体数量(a:天体, b:天体):
	if a.取父天体数量() < b.取父天体数量():
		return true
	return false

func _ready():
	取所有子天体()
