extends Node2D
# =================================
# タイルオブジェクト.
# =================================

class_name Tile

# ---------------------------------
# consts.
# ---------------------------------
enum eColor {
	BLACK,
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	LIME,
	AQUA,
	PURPLE,
	BLUE,
}

# ---------------------------------
# vars.
# ---------------------------------
var _color = eColor.RED
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
		eColor.BLACK:
			return Color.black
		eColor.RED:
			return Color.red
		eColor.ORANGE:
			return Color.orange
		eColor.YELLOW:
			return Color.yellow
		eColor.GREEN:
			return Color.green
		eColor.LIME:
			return Color.lime
		eColor.AQUA:
			return Color.aqua
		eColor.PURPLE:
			return Color.purple
		eColor.BLUE:
			return Color.blue 
		_:
			return Color.white

## 更新.
func _process(delta: float) -> void:
	update()
	
func _draw() -> void:
	var color = _get_color()
	var px = Common.get_tile_x(_box_idx, _tile_pos)
	var py = Common.get_tile_y(_box_idx, _tile_pos)
	var rect = Rect2(px, py, Common.TILE_WIDTH, Common.TILE_HEIGHT)
	draw_rect(rect, color)
