extends Node2D


# -------------------------------------------
# preloads.
# -------------------------------------------
const TileBoxObj = preload("res://WaterTileBox.tscn")
const TileObj = preload("res://WaterTile.tscn")
const ReplayObj = preload("res://src/replay/ReplayMgr.gd")

# -------------------------------------------
# consts.
# -------------------------------------------


# -------------------------------------------
# onready.
# -------------------------------------------
onready var _spinbox_seed = $LabelSeed/SpinBox

# -------------------------------------------
# vars.
# -------------------------------------------
var _replay_mgr:ReplayMgr = null
var _logic:WaterLogic = null

var _box_list = []

# -------------------------------------------
# private functions.
# -------------------------------------------

## 開始.
func _ready() -> void:	
	_replay_mgr = ReplayObj.new()
	_logic = WaterLogic.new()
	
	WaterCommon.new_game_rnd() # 乱数を初期化.
	# シード値を入れる.
	_spinbox_seed.value = WaterCommon.get_seed()

	_logic.create(4, 1)
	
	# logicを元にゲームオブジェクトを生成する.
	for i in range(_logic.count_box()):
		var box = TileBoxObj.instance()
		box.setup(i)
		for j in range(_logic.count_tile(i)):
			var color = _logic.get_tile_color(i, j)
			if color == WaterCommon.eColor.NONE:
				break
			var tile = TileObj.instance()
			tile.setup(i, j, color)
			box.push(tile)
			add_child(tile)
		_box_list.append(box)
		add_child(box)

## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_click"):
		# 箱の選択.
		var box_idx = _focus_box()
		var data = ReplayData.new()
		if _logic.update(box_idx, data):
			# 入れ替えできたので表示の更新が必要.
			print(data)
			var src_box:WaterTileBox = _box_list[data.src_box]
			var dst_box:WaterTileBox = _box_list[data.dst_box]
			for _i in range(data.count):
				var src_tile:WaterTile = src_box.pop()
				dst_box.push(src_tile)
		
		# 選択カーソルの更新.
		box_idx = _logic.get_selected_box()
		for box in _box_list:
			if box.get_idx() == box_idx:
				if box.is_selected():
					box.set_selected(false) # すでに選択していたら解除.
				else:
					box.set_selected(true) # 選択している.
			else:
				box.set_selected(false)
	
	_update_ui(delta)


## マウスの位置にある箱を取得する.
func _focus_box() -> int:
	var mouse = get_viewport().get_mouse_position()
	var mx = mouse.x
	var my = mouse.y
	for box in _box_list:
		var box_idx = box.get_idx()
		var x1 = WaterCommon.get_box_left(box_idx)
		var y1 = WaterCommon.get_box_top(box_idx)
		var x2 = x1 + WaterCommon.get_box_width()
		var y2 = y1 + WaterCommon.get_box_height()
		if x1 <= mx and mx <= x2:
			if y1 <= my and my <= y2:
				# フォーカスしている.
				return box_idx
	
	# 選択していない.
	return -1

## 更新 > UI.
func _update_ui(_delta:float) -> void:
	pass

# ----------------------------------------
# signals.
# ----------------------------------------
## やり直しボタンを押した.
func _on_ButtonRetry_pressed() -> void:
	WaterCommon.set_seed(_spinbox_seed.value, false)
	WaterCommon.set_reset_game(false) # リセットしない.
	get_tree().change_scene("res://Main.tscn")

## 次のゲームに進む.
func _on_ButtonNextGame_pressed() -> void:
	WaterCommon.set_reset_game(true)
	get_tree().change_scene("res://Main.tscn")
