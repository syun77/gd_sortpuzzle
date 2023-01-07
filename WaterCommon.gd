extends Node

# -----------------------------------------
# consts.
# -----------------------------------------
const BOX_OFS_X = 128.0
const BOX_OFS_Y = 64.0
const BOX_W     = 80.0
# タイル1つあたりのサイズ.
const TILE_WIDTH = 40.0
const TILE_HEIGHT = 40.0
const TILE_MARGIN_X = 4.0
const TILE_MARGIN_Y = 20.0

const TILE_IDX_EMPTY = 0 # 空とするタイル番号.

const BOX_CAPACITY_NUM = 4 # 最大4つまで.
const INVALID_BOX_IDX = -1 # 無効とする箱番号.

enum eColor {
	BLACK,
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	LIME,
	AQUA,
	PURPLE,
	BLUE,
}

# -----------------------------------------
# vars.
# -----------------------------------------
var _seed:int = 0
var _is_reset_game = true # ゲームをリセットするかどうか.

# -----------------------------------------
# public functions.
# -----------------------------------------
## 箱の位置(X).
func get_box_left(idx:int) -> float:
	return BOX_OFS_X + (BOX_W * idx)
## 箱の位置(Y).
func get_box_top(idx:int) -> float:
	return BOX_OFS_Y + (idx * 0)
## 箱のサイズ(幅).
func get_box_width() -> float:
	return (TILE_MARGIN_X * 2) + TILE_WIDTH
## 箱のサイズ(高さ).
func get_box_height() -> float:
	return TILE_MARGIN_Y + (TILE_HEIGHT * BOX_CAPACITY_NUM)

## タイルの位置(X).
func get_tile_x(idx:int, tile_idx:int) -> float:
	var px = get_box_left(idx)
	px += TILE_MARGIN_X
	return px

## タイルの位置(Y).
func get_tile_y(idx:int, tile_idx:int) -> float:
	var py = get_box_top(idx)
	py += TILE_MARGIN_Y + TILE_HEIGHT * (BOX_CAPACITY_NUM - tile_idx - 1)
	return py

## シードの値を保存
func set_seed(v:int=-1, is_update:bool=true) -> void:
	if v >= 0:
		# 値の指定があればそれをシード値とする.
		_seed = v
	if is_update:
		seed(_seed)
func get_seed() -> int:
	return _seed
func set_reset_game(b:bool) -> void:
	_is_reset_game = b
func new_game_rnd() -> void:
	var v = _seed
	if _is_reset_game:
		randomize()
		v = randi()
	set_seed(v)
