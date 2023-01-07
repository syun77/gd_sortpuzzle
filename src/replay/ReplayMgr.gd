# =============================
# リプレイ管理.
# =============================
class_name ReplayMgr

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
	pass # TODO: 未実装.

