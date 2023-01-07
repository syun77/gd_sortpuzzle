extends Node2D


# -------------------------------------------
# preloads.
# -------------------------------------------
const TileBoxObj = preload("res://WaterTileBox.tscn")
const TileObj = preload("res://WaterTile.tscn")
# -------------------------------------------
# consts.
# -------------------------------------------


# -------------------------------------------
# onready.
# -------------------------------------------
onready var _spinbox_seed = $UILayer/LabelSeed/SpinBox
onready var _label_step = $UILayer/LabelStep
onready var _btn_undo = $UILayer/ButtonUndo

# -------------------------------------------
# vars.
# -------------------------------------------
var _replay_mgr:ReplayMgr = null

var _box_list = []
var _tile_list = []

# -------------------------------------------
# private functions.
# -------------------------------------------

## 開始.
func _ready() -> void:	
	_replay_mgr = ReplayMgr.new()
	
	WaterCommon.new_game_rnd() # 乱数を初期化.
	# シード値を入れる.
	_spinbox_seed.value = WaterCommon.get_seed()

	WaterLogic.create(4, 1)
	
	# logicを元にゲームオブジェクトを生成する.
	for i in range(WaterLogic.count_box()):
		var box = TileBoxObj.instance()
		box.setup(i)
		for j in range(WaterLogic.count_tile(i)):
			var color = WaterLogic.get_tile_color(i, j)
			if color == WaterCommon.eColor.NONE:
				break
			var tile = TileObj.instance()
			tile.setup(i, j, color)
			box.push(tile)
			_tile_list.append(tile)
			# UIDを登録.
			WaterLogic.register_tile_uid(i, j, tile.get_instance_id())
			add_child(tile)
		_box_list.append(box)
		add_child(box)

## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_click"):
		# 箱の選択.
		var box_idx = _focus_box()
		var data = ReplayData.new()
		if WaterLogic.update(box_idx, data):
			# 入れ替えできたので表示の更新が必要.
			# UNDOに追加.
			_replay_mgr.add_undo(data)
			print(data)
			_copy_from_logic()
		
		# 選択カーソルの更新.
		box_idx = WaterLogic.get_selected_box()
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

## ロジックからタイル情報をコピーする.
func _copy_from_logic() -> void:
	var tile_idx = 0
	for tile in _tile_list:
		var t:WaterTile = tile
		var uid = t.get_instance_id()
		var data:WaterLogic.MyTile = WaterLogic.get_tile_from_uid(uid)
		t.move(data.get_box_idx(), data.get_tile_pos())

## 更新 > UI.
func _update_ui(_delta:float) -> void:
	var cnt_undo = _replay_mgr.count_undo()
	_label_step.visible = (cnt_undo > 0)
	_label_step.text = "Step:%d"%cnt_undo

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

## UNDOの実行.
func _on_ButtonUndo_pressed() -> void:
	_replay_mgr.undo()
	# Logicからコピーする.
	_copy_from_logic()
