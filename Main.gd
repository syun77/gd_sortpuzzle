extends Node2D


# -------------------------------------------
# preloads.
# -------------------------------------------
const TileBoxObj = preload("res://WaterTileBox.tscn")
const TileObj = preload("res://WaterTile.tscn")
const ReplayObj = preload("res://src/reply/ReplayMgr.gd")

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
var _selected_box = WaterCommon.INVALID_BOX_IDX # 選んでいる箱.
var _box_list = []
var _replay_mgr:ReplayMgr

# -------------------------------------------
# private functions.
# -------------------------------------------

## 開始.
func _ready() -> void:	
	_replay_mgr = ReplayObj.new()
	
	WaterCommon.new_game_rnd() # 乱数を初期化.
	# シード値を入れる.
	_spinbox_seed.value = WaterCommon.get_seed()
	
	var box_num = 4
	var tbl = []
	for j in range(box_num):
		for i in range(WaterCommon.BOX_CAPACITY_NUM):
			tbl.append(j + 1) # 1始まり.
	tbl.shuffle()

	print(tbl)

	var box:WaterTileBox = null
	var box_idx = 0
	for i in range(tbl.size()):
		var v = tbl[i]
		box_idx = int(i / WaterCommon.BOX_CAPACITY_NUM)
		var tile_idx = i % WaterCommon.BOX_CAPACITY_NUM
		if tile_idx == 0:
			# 箱を生成.
			box = TileBoxObj.instance()
			box.setup(box_idx)
			add_child(box)
			_box_list.append(box)
		
		# タイルを生成.
		var tile = TileObj.instance()
		tile.setup(box_idx, tile_idx, v)
		box.push(tile)
		add_child(tile)

	# 空の容器を作っておく.
	box_idx += 1
	for i in range(1):
		box = TileBoxObj.instance()
		box.setup(box_idx)
		add_child(box)
		_box_list.append(box)
		box_idx += 1

## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_click"):
		# 箱の選択.
		var box_idx = _focus_box()
		# 2箇所選択したら入れ替える.
		if _check_swap_box(_selected_box, box_idx):
			# 入れ替え実行.
			_swap_box(_selected_box, box_idx)
			# 入れ替えできたら非選択にする.
			box_idx = WaterCommon.INVALID_BOX_IDX

		# 箱の選択状態の更新.
		if _update_box_select(box_idx):
			_selected_box = box_idx
		else:
			# 選択できなかった.
			_selected_box = WaterCommon.INVALID_BOX_IDX
	
	_update_ui(delta)

## 更新 > 箱の選択
## @return 選択できたらtrue
func _update_box_select(box_idx:int) -> bool:
	var ret = false
	
	for box in _box_list:
		if box.get_idx() == box_idx:
			if box.is_selected():
				box.set_selected(false) # すでに選択していたら解除.
			else:
				box.set_selected(true) # 選択している.
				ret = true # 選択できた.
		else:
			box.set_selected(false)
	
	return ret	

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

## 交換可能かどうか.
func _check_swap_box(src_idx:int, dst_idx:int) -> bool:
	if src_idx == WaterCommon.INVALID_BOX_IDX or dst_idx == WaterCommon.INVALID_BOX_IDX:
		return false # どちらかが無効の場合は交換できない.

	if src_idx == dst_idx:
		return false # 同じ場合も交換できない.
	
	var src_box:WaterTileBox = _box_list[src_idx]
	var dst_box:WaterTileBox = _box_list[dst_idx]

	if src_box.empty():
		return false # 空なので移動できない.
	
	if dst_box.empty():
		# 移動先が空なら無条件で移動可能.
		return true
	
	if dst_box.full():
		return false # 一杯なので移動不可.
	
	var src_color = src_box.top_color()
	var dst_color = dst_box.top_color()
	if src_color != dst_color:
		return false # 色が誓う.

	# 交換できる.
	return true

func _swap_box(src_idx:int, dst_idx:int) -> void:
	var src_box:WaterTileBox = _box_list[src_idx]
	var dst_box:WaterTileBox = _box_list[dst_idx]
	
	while true:
		var src_tile = src_box.pop()
		var dst_color = dst_box.top_color()
		if dst_box.empty() == false:
			# 移動先が空でない.
			if src_tile.get_color() != dst_color:
				# 違う色になったので終了.
				# 戻しておきます.
				src_box.push(src_tile)
				break
		
		# 移動先に追加.
		dst_box.push(src_tile)
		
		if src_box.empty():
			break # 空になったので終了.
		if dst_box.full():
			break # 一杯になったので終了.

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
