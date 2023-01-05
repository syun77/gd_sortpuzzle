extends Node2D


# -------------------------------------------
# preloads.
# -------------------------------------------
const TileBoxObj = preload("res://TileBox.tscn")
const TileObj = preload("res://Tile.tscn")

# -------------------------------------------
# consts.
# -------------------------------------------
const INVALID_BOX_IDX = -1 # 無効とする箱番号.

# -------------------------------------------
# vars.
# -------------------------------------------
var _selected_box = INVALID_BOX_IDX # 選んでいる箱.
var _box_list = []

# -------------------------------------------
# private functions.
# -------------------------------------------

## 開始.
func _ready() -> void:
	randomize()
	
	var box_num = 4
	var tbl = []
	for j in range(box_num):
		for i in range(Common.BOX_CAPACITY_NUM):
			tbl.append(j + 1) # 1始まり.
	tbl.shuffle()

	print(tbl)

	var box:TileBox = null
	var box_idx = 0
	for i in range(tbl.size()):
		var v = tbl[i]
		box_idx = int(i / Common.BOX_CAPACITY_NUM)
		var tile_idx = i % Common.BOX_CAPACITY_NUM
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
			box_idx = INVALID_BOX_IDX
		
		for box in _box_list:
			if box.get_idx() == box_idx:
				if box.is_selected():
					box.set_selected(false) # すでに選択していたら解除.
				else:
					box.set_selected(true) # 選択している.
			else:
				box.set_selected(false)
		_selected_box = box_idx

func _focus_box() -> int:
	var mouse = get_viewport().get_mouse_position()
	var mx = mouse.x
	var my = mouse.y
	for box in _box_list:
		var box_idx = box.get_idx()
		var x1 = Common.get_box_left(box_idx)
		var y1 = Common.get_box_top(box_idx)
		var x2 = x1 + Common.get_box_width()
		var y2 = y1 + Common.get_box_height()
		if x1 <= mx and mx <= x2:
			if y1 <= my and my <= y2:
				# フォーカスしている.
				return box_idx
	
	# 選択していない.
	return -1

func _check_swap_box(from_idx:int, to_idx:int) -> bool:
	if from_idx == INVALID_BOX_IDX or to_idx == INVALID_BOX_IDX:
		return false # どちらかが無効の場合は交換できない.

	if from_idx == to_idx:
		return false # 同じ場合も交換できない.
	
	var from_box:TileBox = _box_list[from_idx]
	var to_box:TileBox = _box_list[to_idx]

	if from_box.empty():
		return false # 空なので移動できない.
	
	if to_box.empty():
		# 移動先が空なら無条件で移動可能.
		return true
	
	if to_box.full():
		return false # 一杯なので移動不可.
	
	var from_color = from_box.top_color()
	var to_color = to_box.top_color()
	if from_color != to_color:
		return false # 色が誓う.

	# 交換できる.
	return true

func _swap_box(from_idx:int, to_idx:int) -> void:
	var from_box:TileBox = _box_list[from_idx]
	var to_box:TileBox = _box_list[to_idx]
	
	while true:
		var from_tile = from_box.pop()
		var to_color = to_box.top_color()
		if to_box.empty() == false:
			# 移動先が空でない.
			if from_tile.get_color() != to_color:
				# 違う色になったので終了.
				# 戻しておきます.
				from_box.push(from_tile)
				break
		
		# 移動先に追加.
		to_box.push(from_tile)
		
		if from_box.empty():
			break # 空になったので終了.
		if to_box.full():
			break # 一杯になったので終了.

# ----------------------------------------
# signals.
# ----------------------------------------
## やり直しボタンを押した.
func _on_ButtonRetry_pressed() -> void:
	get_tree().change_scene("res://Main.tscn")
