extends Node

# =============================
# リプレイ管理.
# =============================
#class_name ReplayMgr

# -----------------------------
# vars.
# -----------------------------
## undoリスト.
var undo_list = []
## redoリスト.
var redo_list = []

# -----------------------------
# public functions.
# -----------------------------
## リセット.
func reset() -> void:
	undo_list.clear()
	redo_list.clear()

## undoを追加する.
func add_undo(d:ReplayData, is_clear_redo:bool=true) -> void:
	undo_list.append(d)
	if is_clear_redo:
		# undoが追加されたらredoは消える.
		redo_list.clear()

## undoできる回数を取得する.
func count_undo() -> int:
	return undo_list.size()

## undoを実行する.
func undo() -> void:
	if count_undo() <= 0:
		return
	
	# リプレイデータを取り出す.
	var data = undo_list.pop_back()
	
	# UNDOを実行.
	WaterLogic.undo(data)

## 過去に同じタイル情報があるかどうか.
func has_same_tiles(d:ReplayData) -> bool:
	# 逆順にする.
	var tmp = []
	for d2 in undo_list:
		tmp.push_front(d2)
	
	for d2 in tmp:
		if d2.tiles == d.tiles:
			return true # 同じデータが見つかった。
	
	return false
