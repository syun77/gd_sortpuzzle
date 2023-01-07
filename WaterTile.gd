extends Node2D
# =================================
# タイルオブジェクト.
# =================================

class_name WaterTile

# ---------------------------------
# consts.
# ---------------------------------

# ---------------------------------
# vars.
# ---------------------------------
var _color = WaterCommon.eColor.RED
var _box_idx = 0
var _tile_pos = 0 # タイルの位置.

# ---------------------------------
# public functions.
# ---------------------------------
func setup(box_idx:int, tile_pos:int, color:int) -> void:
	_box_idx = box_idx
	_tile_pos = tile_pos
	_color = color
func get_box_idx() -> int:
	return _box_idx
func get_tile_pos() -> int:
	return _tile_pos
func get_color() -> int:
	return _color
	
func move(box_idx:int, tile_pos:int) -> void:
	_box_idx = box_idx
	_tile_pos = tile_pos
	
# ---------------------------------
# private functions.
# ---------------------------------
## 色を取得する.
func _get_color() -> Color:
	match _color:
		WaterCommon.eColor.BLACK:
			return Color.black
		WaterCommon.eColor.RED:
			return Color.red
		WaterCommon.eColor.ORANGE:
			return Color.orange
		WaterCommon.eColor.YELLOW:
			return Color.yellow
		WaterCommon.eColor.GREEN:
			return Color.green
		WaterCommon.eColor.LIME:
			return Color.lime
		WaterCommon.eColor.AQUA:
			return Color.aqua
		WaterCommon.eColor.PURPLE:
			return Color.purple
		WaterCommon.eColor.BLUE:
			return Color.blue 
		_:
			return Color.white

## 更新.
func _process(delta: float) -> void:
	update()
	
func _draw() -> void:
	var color = _get_color()
	var px = WaterCommon.get_tile_x(_box_idx, _tile_pos)
	var py = WaterCommon.get_tile_y(_box_idx, _tile_pos)
	var rect = Rect2(px, py, WaterCommon.TILE_WIDTH, WaterCommon.TILE_HEIGHT)
	draw_rect(rect, color)
