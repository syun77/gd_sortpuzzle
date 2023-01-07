extends Node

# ==============================================
# ソートパズルのロジック.
# ==============================================
#class_name WaterLogic

## タイルオブジェクト.
class MyTile:
	var _uid = 0 # ユニークID.
	var _box_idx = 0 # 箱番号.
	var _tile_pos = 0 # 箱内の位置.
	var _color = 0 # タイルの色.

	## セットアップ.
	func setup(box_idx:int, tile_pos:int, color:int) -> void:
		_box_idx = box_idx
		_tile_pos = tile_pos
		_color = color
		
	## コピー.
	func copy(src:MyTile) -> void:
		_uid = src.get_uid()
		_box_idx = src.get_box_idx()
		_tile_pos = src.get_tile_pos()
		_color = src.get_color()
	
	func move(box_idx:int, tile_pos:int) -> void:
		_box_idx = box_idx
		_tile_pos = tile_pos
	
	func get_box_idx() -> int:
		return _box_idx
	func get_tile_pos() -> int:
		return _tile_pos
	func get_color() -> int:
		return _color
		
	func set_uid(uid:int) -> void:
		_uid = uid
	func get_uid() -> int:
		return _uid
		
## MyTileを入れる箱.
class MyBox:
	var _stack = [] # タイルのスタック.
	var _idx = 0 # 箱番号.
	var _selected = false # 選択中かどうか.
	
	## セットアップ.
	func setup(idx:int) -> void:
		_idx = idx
	
	## コピー.
	func copy(src:MyBox) -> void:
		for d in src._stack:
			var d2 = MyTile.new()
			d2.copy(d)
			_stack.append(d2)

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
	
	func count_tile() -> int:
		return _stack.size()
	
	func get_tile(pos:int) -> MyTile:
		if pos < 0 or count_tile() <= pos:
			return null
		return _stack[pos]
# ----------------------------------------------
# vars.
# ----------------------------------------------
var _box_list = []
var _active_box_list = null
var _tile_dict = {} # タイルへのアクセス用.
var _selected_box = WaterCommon.INVALID_BOX_IDX # 選んでいる箱.

# ----------------------------------------------
# public functions.
# ----------------------------------------------
## 初期化.
func init() -> void:
	_box_list = []
	_selected_box = WaterCommon.INVALID_BOX_IDX

## 生成.
func create(fill_cnt:int, empty_cnt:int) -> void:
	# 初期化.
	init()
	
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

	# 空の容器を作っておく.
	box_idx += 1
	for i in range(1):
		box = MyBox.new()
		box.setup(box_idx)
		_box_list.append(box)
		box_idx += 1

## 更新.
func update(box_idx:int, data:ReplayData) -> bool:
	var ret = false # 入れ替えできたかどうか.
	
	# 2箇所選択したら入れ替える.
	if _check_swap_box(_selected_box, box_idx):
		# 入れ替え実行.
		data.count = _swap_box(_selected_box, box_idx)
		data.tiles = to_tiles()
		
		# 返却用データの設定.
		data.src_box = _selected_box
		data.dst_box = box_idx
		ret = true
		
		# 入れ替えできたら非選択にする.
		box_idx = WaterCommon.INVALID_BOX_IDX

	# 箱の選択状態の更新.
	if _update_box_select(box_idx):
		_selected_box = box_idx
	else:
		# 選択できなかった.
		_selected_box = WaterCommon.INVALID_BOX_IDX
	
	return ret

## すべてのタイル情報を文字列として取得する
func to_tiles() -> String:
	var ret = ""
	var box_list = _get_active_box_list()
	for box in box_list:
		var cnt = box.count_tile()
		for i in range(WaterCommon.BOX_CAPACITY_NUM):
			if i >= cnt:
				ret += "0"
				continue
			var tile:MyTile = box.get_tile(i)
			ret += "%d"%tile.get_color()
	
	return ret

## 完了したかどうか.
func check_completed() -> bool:
	var box_list = _get_active_box_list()
	
	for box in box_list:
		if box.empty():
			continue # 空の箱は判定不要.
		var cnt = box.count_tile()
		if cnt < WaterCommon.BOX_CAPACITY_NUM:
			return false # 一杯になっていない箱がある.
		
		var color = WaterCommon.eColor.NONE
		for i in range(cnt):
			var tile:MyTile = box.get_tile(i)
			if i == 0:
				color = tile.get_color()
				continue
			if tile.get_color() != color:
				return false # 異なる色が1つの箱に入っている.
	
	# すべて完了した.
	return true

## クリア可能かどうか.
func can_resolve() -> bool:
	# まずはコピーする.
	var box_list = []
	for src_box in _box_list:
		var box = MyBox.new()
		box.copy(src_box)
		box_list.append(box)
	
	# アクティブに設定する.
	_active_box_list = box_list

	var depth = 0
	var swap_points = search_swap_point()
	for d in swap_points:
		if _can_resolve_sub(box_list, d, depth):
			_active_box_list = null # 消しておく.
			return true
	
	_active_box_list = null # 消しておく.
	return false

func _can_resolve_sub(box_list, d:ReplayData, depth:int) -> bool:
	depth += 1
	if _check_swap_box(d.src_box, d.dst_box):
		# 交換実行.
		var data = ReplayData.new()
		data.src_box = d.src_box
		data.dst_box = d.dst_box
		data.count = _swap_box(d.src_box, d.dst_box)
		data.tiles = to_tiles()
		#print(depth, " ", data)
		
		var dont_check = false
		if ReplayMgr.has_same_tiles(data):
			dont_check = true # チェック不要.
		
		ReplayMgr.add_undo(data)
		if dont_check:
			# これ以上の探索不要.
			ReplayMgr.undo() # クリアできないので1つ戻す.
			return false
		
		if check_completed():
			return true # クリアできた.

		# 次の入れ替えポイントを探す.
		var swap_points = search_swap_point()
		for d2 in swap_points:
			if _can_resolve_sub(box_list, d2, depth):
				return true # クリアできた.
				
	ReplayMgr.undo() # クリアできないので1つ戻す.
	return false

# ----------------------------------------------
# private functions.
# ----------------------------------------------
## 交換可能かどうか.
func _check_swap_box(src_idx:int, dst_idx:int) -> bool:
	if src_idx == WaterCommon.INVALID_BOX_IDX or dst_idx == WaterCommon.INVALID_BOX_IDX:
		return false # どちらかが無効の場合は交換できない.

	if src_idx == dst_idx:
		return false # 同じ場合も交換できない.
	
	var box_list = _get_active_box_list()
	
	var src_box:MyBox = box_list[src_idx]
	var dst_box:MyBox = box_list[dst_idx]

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

## 交換を実行する.
## @return 移動した数.
func _swap_box(src_idx:int, dst_idx:int) -> int:
	var ret = 0
	
	var box_list = _get_active_box_list()
	
	var src_box:MyBox = box_list[src_idx]
	var dst_box:MyBox = box_list[dst_idx]
	
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
		ret += 1
		
		if src_box.empty():
			break # 空になったので終了.
		if dst_box.full():
			break # 一杯になったので終了.
	
	return ret

## 更新 > 箱の選択
## @return 選択できたらtrue
func _update_box_select(box_idx:int) -> bool:
	var ret = false
	
	for box in _get_active_box_list():
		if box.get_idx() == box_idx:
			if box.is_selected():
				box.set_selected(false) # すでに選択していたら解除.
			else:
				box.set_selected(true) # 選択している.
				ret = true # 選択できた.
		else:
			box.set_selected(false)
	
	return ret
	
func _get_active_box_list():
	if _active_box_list != null:
		return _active_box_list
	return _box_list
# ----------------------------------------------
# properties.
# ----------------------------------------------
func get_selected_box() -> int:
	return _selected_box

func count_box() -> int:
	return _box_list.size()

func get_box(idx:int) -> MyBox:
	if idx < 0 or count_box() <= idx:
		return null
	return _box_list[idx]

func count_tile(idx:int) -> int:
	var box:MyBox = get_box(idx)
	if box == null:
		return 0
	return box.count_tile()

func get_tile(box_idx:int, tile_pos:int) -> MyTile:
	var box:MyBox = get_box(box_idx)
	if box == null:
		return null
	
	if tile_pos < 0 or box.count_tile() <= tile_pos:
		return null

	var tile:MyTile = box.get_tile(tile_pos)
	return tile

func get_tile_color(box_idx:int, tile_pos:int) -> int:
	var tile:MyTile = get_tile(box_idx, tile_pos)
	if tile == null:
		return WaterCommon.eColor.NONE # 無効.
	return tile.get_color()

## タイルのUIDを登録する.
func register_tile_uid(box_idx:int, tile_pos:int, uid:int) -> void:
	var tile:MyTile = get_tile(box_idx, tile_pos)
	if tile == null:
		push_error(str("無効なタイルを指定 box_idx:", box_idx, " tile_pos:", tile_pos))
		return

	tile.set_uid(uid)
	# UIDで登録.
	_tile_dict[uid] = tile

func get_tile_uid(box_idx:int, tile_pos:int) -> int:
	var tile:MyTile = get_tile(box_idx, tile_pos)
	if tile == null:
		return 0
	
	return tile.get_uid()

## UID指定でタイル情報を取得する.
func get_tile_from_uid(uid:int) -> MyTile:
	return _tile_dict[uid]

## UNDOを実行.
func undo(data:ReplayData) -> void:
	var box_list = _get_active_box_list()
	
	var src_box:MyBox = box_list[data.src_box]
	var dst_box:MyBox = box_list[data.dst_box]	
	# 逆順に入れ替える.
	for _i in range(data.count):
		var tile:MyTile = dst_box.pop()
		src_box.push(tile)

## 交換可能な場所を返す
func search_swap_point():
	var box_list = _get_active_box_list()
	
	var ret = []
	for i in range(box_list.size()):
		for j in range(box_list.size()):
			if i == j:
				continue # 同じ場所は交換できない.
			if _check_swap_box(i, j) == false:
				continue # 交換できない
			
			# 交換可能.
			var d = ReplayData.new()
			d.src_box = i
			d.dst_box = j
			ret.append(d)
	
	return ret
