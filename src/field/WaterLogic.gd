extends Node

class_name WaterLogic

## タイルオブジェクト.
class MyTile:
	var _box_idx = 0 # 箱番号.
	var _tile_pos = 0 # 箱内の位置.
	var _color = 0 # タイルの色.

	## セットアップ.
	func setup(box_idx:int, tile_pos:int, color:int) -> void:
		_box_idx = box_idx
		_tile_pos = tile_pos
		_color = color
	
	func move(box_idx:int, tile_pos:int) -> void:
		_box_idx = box_idx
		_tile_pos = tile_pos
	
	func get_box_idx() -> int:
		return _box_idx
	func get_tile_pos() -> int:
		return _tile_pos
	func get_color() -> int:
		return _color
		
## MyTileを入れる箱.
class MyBox:
	var _stack = [] # タイルのスタック.
	var _idx = 0 # 箱番号.
	var _selected = false # 選択中かどうか.
	
	## セットアップ.
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
		
	func push(tile:MyTile) -> void:
		if can_push() == false:
			return # 入れられない.
		
		var tile_pos = _stack.size()
		tile.move(_idx, tile_pos)
		_stack.push_back(tile)

	func pop() -> MyTile:
		if empty():
			return null
		return _stack.pop_back()

	# 同じ色をまとめて取得する.
	func pop2() -> Array:
		var ret = []
		var color = WaterCommon.TILE_IDX_EMPTY # 無効な色.
		while empty() == false:
			var tile:MyTile = pop()
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
		
		var tile:MyTile = _stack.back()
		return tile.get_color()

	func is_selected() -> bool:
		return _selected
	func set_selected(b:bool) -> void:
		_selected = b

# ----------------------------------------------
# vars.
# ----------------------------------------------
var _box_list = []

## 生成.
func create(fill_cnt:int, empty_cnt:int) -> void:
	var tbl = []
	for j in range(fill_cnt):
		for i in range(WaterCommon.BOX_CAPACITY_NUM):
			tbl.append(j + 1) # 1始まり.
	tbl.shuffle()
	print(tbl)
	
	var box:MyBox = null
	var box_idx = 0
	for i in range(tbl.size()):
		var v = tbl[i]
		box_idx = int(i / WaterCommon.BOX_CAPACITY_NUM)
		var tile_idx = i % WaterCommon.BOX_CAPACITY_NUM
		if tile_idx == 0:
			# 箱を生成.
			box = MyBox.new()
			box.setup(box_idx)
			_box_list.append(box)
		
		# タイルを生成.
		var tile = MyTile.new()
		tile.setup(box_idx, tile_idx, v)
		box.push(tile)
		add_child(tile)

	# 空の容器を作っておく.
	box_idx += 1
	for i in range(1):
		box = MyBox.new()
		box.setup(box_idx)
		_box_list.append(box)
		box_idx += 1
