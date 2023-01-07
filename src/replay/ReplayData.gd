# =============================
# リプレイデータ.
# =============================
class_name ReplayData

# -----------------------------
# vars.
# -----------------------------
## すべてのタイル情報.
var tiles = ""
## 移動元の箱.
var src_box = WaterCommon.INVALID_BOX_IDX
## 移動先の箱.
var dst_box = WaterCommon.INVALID_BOX_IDX
## 移動した数.
var count = 0


# -----------------------------
# public functions.
# -----------------------------
# -----------------------------
# private functions.
# -----------------------------
func _to_string() -> String:
	return "src:%d dst:%d count:%d tiles:%s"%[src_box, dst_box, count, tiles]
