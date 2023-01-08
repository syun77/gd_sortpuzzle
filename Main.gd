extends Node2D


# -------------------------------------------
# preloads.
# -------------------------------------------
const TileBoxObj = preload("res://WaterTileBox.tscn")
const TileObj = preload("res://WaterTile.tscn")
# -------------------------------------------
# consts.
# -------------------------------------------
enum eState {
	MAIN,
	COMPLETED,
}

# -------------------------------------------
# onready.
# -------------------------------------------
onready var _spinbox_seed = $UILayer/LabelSeed/SpinBox
onready var _spinbox_boxnum = $UILayer/LabelBox/SpinBox
onready var _spinbox_emptynum = $UILayer/LabelEmpty/SpinBox
onready var _checkbox_resolve = $UILayer/LabelResolve/CehckBox
onready var _label_step = $UILayer/LabelStep
onready var _btn_undo = $UILayer/ButtonUndo
onready var _label_caption = $UILayer/LabelCaption

# -------------------------------------------
# vars.
# -------------------------------------------
var _box_list = []
var _tile_list = []
var _state = eState.MAIN

# -------------------------------------------
# private functions.
# -------------------------------------------

## 開始.
func _ready() -> void:	
	# UIに反映.
	_spinbox_boxnum.value = WaterCommon.box_num
	_spinbox_emptynum.value	= WaterCommon.empty_num
	_checkbox_resolve.pressed = WaterCommon.check_resolve
	
	ReplayMgr.reset()
	WaterCommon.new_game_rnd() # 乱数を初期化.
	# シード値を入れる.
	_spinbox_seed.value = WaterCommon.get_seed()
	
	if _create() == false:
		_label_caption.visible = true
		_label_caption.text = "クリア不可能"
	
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

## 生成.
func _create() -> bool:
	var ret = false # クリア可能かどうか.
	
	var box_num = _spinbox_boxnum.value
	var empty_num = _spinbox_emptynum.value
	
	# リトライ回数.
	var cnt_retry = 1
	for _i in range(cnt_retry):
		# 問題を生成.
		print("問題を生成:%d"%(_i+1))
		WaterLogic.create(box_num, empty_num)
		if WaterCommon.check_resolve == false:
			ret = true # クリア可能としてしまう.
			break
		
		# クリア可能かどうか判定。内部でリプレイデータを使う
		#if true:
		if WaterLogic.can_resolve():
			print("[クリア可能]")
			ret = true
			break
		else:
			print("[クリア不可能]")
		
		# リプレイをリセット.
		ReplayMgr.reset()
		
	# リプレイをリセット.
	ReplayMgr.reset()
	return ret

## 問題生成2.
func _create2() -> bool:
	var box_num = _spinbox_boxnum.value
	var empty_num = _spinbox_emptynum.value	
	WaterLogic.create2(box_num, empty_num)
	return true # 必ず解けるはず…

## 更新.
func _process(delta: float) -> void:
	match _state:
		eState.MAIN:
			_update_main(delta)
		eState.COMPLETED:
			_update_completed(delta)
	
	_update_ui(delta)

## 更新 > メイン.
func _update_main(_delta:float) -> void:
	if Input.is_action_just_pressed("ui_click"):
		# 箱の選択.
		var box_idx = _focus_box()
		if box_idx == -1:
			return # 選択位置に何もない.
		
		var data = ReplayData.new()
		if WaterLogic.update(box_idx, data):
			# 入れ替えできたので表示の更新が必要.
			# UNDOに追加.
			print(data)
			ReplayMgr.add_undo(data)
			_copy_from_logic()
			
			print_debug("*Swap Point*")
			var ret = WaterLogic.search_swap_point()
			for d in ret:
				print(d)
			
			if WaterLogic.check_completed():
				_state = eState.COMPLETED
		
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

## 更新 > 完了.
func _update_completed(_delta:float) -> void:
	_label_caption.visible = true

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
	var cnt_undo = ReplayMgr.count_undo()
	_label_step.visible = (cnt_undo > 0)
	_label_step.text = "Step:%d"%cnt_undo
	
	WaterCommon.box_num = _spinbox_boxnum.value
	WaterCommon.empty_num = _spinbox_emptynum.value
	WaterCommon.check_resolve = _checkbox_resolve.pressed

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
	ReplayMgr.undo()
	# Logicからコピーする.
	_copy_from_logic()
