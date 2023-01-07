extends Area2D

# ===========================================
# Tileを入れる箱.
# ===========================================
class_name WaterTileBox

# -------------------------------------------
# onready.
# -------------------------------------------
onready var _label = $Label

# -------------------------------------------
# vars.
# -------------------------------------------
var _stack = [] # タイルのスタック.
var _idx = 0 # 箱番号.
var _selected = false # 選択中かどうか.
var _timer = 0.0

# -------------------------------------------
# public functions.
# -------------------------------------------
func setup(idx:int) -> void:
	_idx = idx

func get_idx() -> int:
	return _idx


func clear() -> void:
	_stack.clear()

func can_push() -> bool:
	if _stack.size() >= WaterCommon.BOX_CAPACITY_NUM:
		# 容量オーバー.
		return false
	return true

func empty() -> bool:
	if _stack.size() <= 0:
		return true # 空
	return false

func full() -> bool:
	if _stack.size() >= WaterCommon.BOX_CAPACITY_NUM:
		return true # 満タン.
	return false
	
func push(tile:WaterTile) -> void:
	if can_push() == false:
		return # 入れられない.
	
	var tile_pos = _stack.size()
	tile.move(_idx, tile_pos)
	_stack.push_back(tile)

func pop() -> WaterTile:
	if empty():
		return null
	return _stack.pop_back()

# 同じ色をまとめて取得する.
func pop2() -> Array:
	var ret = []
	var color = WaterCommon.TILE_IDX_EMPTY # 無効な色.
	while empty() == false:
		var tile:WaterTile = pop()
		if color != WaterCommon.TILE_IDX_EMPTY:
			if color != tile.get_color():
				# 同じ色でない.
				push(tile) # 返却する.
				break # 終了.
		
		# 次のタイルを調べる.
		ret.append(tile)
	
	return ret

func top_color() -> int:
	if empty():
		return WaterCommon.TILE_IDX_EMPTY # 空.
	
	var tile:WaterTile = _stack.back()
	return tile.get_color()

func is_selected() -> bool:
	return _selected
func set_selected(b:bool) -> void:
	_selected = b

# -------------------------------------------
# private functions.
# -------------------------------------------
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	_timer += delta
	
	var px = WaterCommon.get_box_left(_idx)
	var py = WaterCommon.get_box_top(_idx) + WaterCommon.get_box_height()
	_label.rect_position.x = px
	_label.rect_position.y = py
	var buf = ""
	for tile in _stack:
		buf += "%d\n"%tile.get_color()
	_label.text = buf
	
	update()
	
func _draw() -> void:
	var px = WaterCommon.get_box_left(_idx)
	var py = WaterCommon.get_box_top(_idx)
	var w = WaterCommon.get_box_width()
	var h = WaterCommon.get_box_height()
	var rect = Rect2(px, py, w, h)
	var line_width = WaterCommon.TILE_MARGIN_X
	var color = Color.white
	if _selected:
		var rate = abs(sin(_timer * 4))
		color = Color.yellow.linear_interpolate(Color.red, rate)
	draw_rect(rect, color, false, line_width)
