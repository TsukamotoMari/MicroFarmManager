extends RefCounted
class_name FarmTheme

const INK := Color(0.23, 0.16, 0.10)
const CREAM := Color(0.99, 0.95, 0.88)
const CREAM_MUTED := Color(0.82, 0.74, 0.62)
const WOOD := Color(0.46, 0.28, 0.15)
const WOOD_DARK := Color(0.32, 0.18, 0.09)
const LEAF := Color(0.27, 0.52, 0.30)
const LEAF_DARK := Color(0.18, 0.38, 0.22)
const GOLD := Color(0.93, 0.72, 0.22)
const GOLD_DEEP := Color(0.72, 0.48, 0.10)
const PANEL := Color(0.98, 0.93, 0.82, 0.96)
const MUTED := Color(0.62, 0.54, 0.44)

static var _art := PixelArtGenerator.new()
static var _wood_tex: ImageTexture
static var _wood_highlight_tex: ImageTexture
static var _chip_tex: ImageTexture
static var _chip_selected_tex: ImageTexture

static func create() -> Theme:
	var theme := Theme.new()
	var title_font := _load_font("res://assets/fonts/Fredoka-SemiBold.ttf")
	var body_font := _load_font("res://assets/fonts/Nunito-SemiBold.ttf")
	if title_font:
		theme.default_font = title_font
		theme.set_font("font", "Label", title_font)
		theme.set_font("font", "Button", title_font)
		theme.set_font("title_font", "AcceptDialog", title_font)
	if body_font:
		theme.set_font("font", "TooltipLabel", body_font)
	theme.default_font_size = 16
	theme.set_font_size("font_size", "Label", 16)
	theme.set_font_size("font_size", "Button", 15)
	theme.set_color("font_color", "Label", CREAM)
	theme.set_color("font_color", "Button", CREAM)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", CREAM)
	theme.set_color("font_disabled_color", "Button", Color(0.62, 0.56, 0.48, 0.75))
	theme.set_stylebox("panel", "PanelContainer", wood_panel(10))
	theme.set_stylebox("panel", "Panel", wood_panel(8))
	theme.set_stylebox("normal", "Button", wood_panel(8))
	theme.set_stylebox("hover", "Button", wood_panel(8, true))
	theme.set_stylebox("pressed", "Button", wood_panel(6))
	theme.set_stylebox("disabled", "Button", _panel(Color(0.28, 0.22, 0.18), Color(0.18, 0.12, 0.08), 4, 2, 8))
	theme.set_stylebox("focus", "Button", wood_panel(8, true))
	theme.set_stylebox("background", "ProgressBar", _panel(Color(0.14, 0.10, 0.08), Color(0, 0, 0, 0), 4, 0, 2))
	theme.set_stylebox("fill", "ProgressBar", _panel(GOLD, GOLD_DEEP, 4, 0, 2))
	theme.set_color("font_color", "ProgressBar", Color(0, 0, 0, 0))
	theme.set_stylebox("panel", "AcceptDialog", wood_panel(12))
	theme.set_stylebox("embedded_border", "AcceptDialog", wood_panel(12))
	return theme

static func reset_textures() -> void:
	_wood_tex = null
	_wood_highlight_tex = null
	_chip_tex = null
	_chip_selected_tex = null

static func _ensure_wood_textures() -> void:
	if _wood_tex == null:
		_wood_tex = ImageTexture.create_from_image(_art.create_wood_panel_tile(64, false))
	if _wood_highlight_tex == null:
		_wood_highlight_tex = ImageTexture.create_from_image(_art.create_wood_panel_tile(64, true))
	if _chip_tex == null:
		_chip_tex = ImageTexture.create_from_image(_art.create_chip_tile(false))
	if _chip_selected_tex == null:
		_chip_selected_tex = ImageTexture.create_from_image(_art.create_chip_tile(true))

static func wood_panel(pad: int = 10, highlight: bool = false) -> StyleBoxTexture:
	_ensure_wood_textures()
	var box := StyleBoxTexture.new()
	box.texture = _wood_highlight_tex if highlight else _wood_tex
	box.texture_margin_left = 10
	box.texture_margin_top = 10
	box.texture_margin_right = 10
	box.texture_margin_bottom = 10
	box.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	box.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	box.set_content_margin_all(pad)
	return box

static func chip_style(selected: bool, ready: bool = false) -> StyleBoxTexture:
	_ensure_wood_textures()
	var box := StyleBoxTexture.new()
	if selected:
		box.texture = _chip_selected_tex
	elif ready:
		box.texture = ImageTexture.create_from_image(_art.create_chip_tile(false, true))
	else:
		box.texture = _chip_tex
	box.texture_margin_left = 6
	box.texture_margin_top = 6
	box.texture_margin_right = 6
	box.texture_margin_bottom = 6
	box.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	box.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	box.set_content_margin_all(6)
	return box

static func locked_chip_style(ready: bool) -> StyleBoxTexture:
	return chip_style(false, ready)

static func row_style() -> StyleBoxFlat:
	return _panel(Color(0.24, 0.16, 0.10, 0.92), Color(0.48, 0.32, 0.16), 6, 2, 8)

static func top_bar_style() -> StyleBoxTexture:
	return wood_panel(10)

static func gold_chip_style() -> StyleBoxTexture:
	var box := wood_panel(8, true)
	return box

static func tab_style(active: bool) -> StyleBoxTexture:
	if active:
		var box := wood_panel(6, true)
		return box
	return wood_panel(6)

static func resource_panel_style() -> StyleBoxTexture:
	return wood_panel(8)

static func transparent_panel() -> StyleBoxEmpty:
	return StyleBoxEmpty.new()

static func water_bar_bg() -> StyleBoxFlat:
	return _panel(Color(0.10, 0.14, 0.20), Color(0, 0, 0, 0), 4, 0, 2)

static func water_bar_fill() -> StyleBoxFlat:
	return _panel(Color(0.28, 0.62, 0.96), Color(0.12, 0.38, 0.72), 4, 0, 2)

static func energy_bar_bg() -> StyleBoxFlat:
	return _panel(Color(0.16, 0.14, 0.10), Color(0, 0, 0, 0), 4, 0, 2)

static func energy_bar_fill() -> StyleBoxFlat:
	return _panel(Color(0.96, 0.78, 0.22), GOLD_DEEP, 4, 0, 2)

static func level_bar_bg() -> StyleBoxFlat:
	return _panel(Color(0.18, 0.12, 0.08), Color(0, 0, 0, 0), 3, 0, 2)

static func level_bar_fill() -> StyleBoxFlat:
	return _panel(GOLD, GOLD_DEEP, 3, 0, 2)

static func _panel(bg: Color, border: Color, radius: float, border_w: int, pad: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_w)
	box.set_corner_radius_all(int(radius))
	box.set_content_margin_all(pad)
	return box

static func _load_font(path: String) -> FontFile:
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return null
	var font := FontFile.new()
	font.load_dynamic_font(path)
	return font
