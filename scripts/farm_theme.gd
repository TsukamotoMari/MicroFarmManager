extends RefCounted
class_name FarmTheme

const INK := Color(0.23, 0.16, 0.10)
const CREAM := Color(0.99, 0.95, 0.88)
const WOOD := Color(0.46, 0.28, 0.15)
const WOOD_DARK := Color(0.32, 0.18, 0.09)
const LEAF := Color(0.27, 0.52, 0.30)
const LEAF_DARK := Color(0.18, 0.38, 0.22)
const GOLD := Color(0.93, 0.72, 0.22)
const GOLD_DEEP := Color(0.72, 0.48, 0.10)
const PANEL := Color(0.98, 0.93, 0.82, 0.96)
const MUTED := Color(0.42, 0.32, 0.22)

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
	theme.set_font_size("font_size", "Button", 16)
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_color", "Button", CREAM)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", CREAM)
	theme.set_color("font_disabled_color", "Button", Color(0.85, 0.78, 0.68, 0.7))
	theme.set_color("font_outline_color", "Label", Color(0, 0, 0, 0.18))
	theme.set_constant("outline_size", "Label", 0)
	
	theme.set_stylebox("panel", "PanelContainer", _panel(PANEL, WOOD, 14, 3, 10))
	theme.set_stylebox("panel", "Panel", _panel(PANEL, WOOD, 12, 2, 8))
	theme.set_stylebox("normal", "Button", _panel(LEAF, LEAF_DARK, 12, 2, 8))
	theme.set_stylebox("hover", "Button", _panel(Color(0.34, 0.62, 0.36), LEAF_DARK, 12, 2, 8))
	theme.set_stylebox("pressed", "Button", _panel(LEAF_DARK, WOOD_DARK, 12, 2, 8))
	theme.set_stylebox("disabled", "Button", _panel(Color(0.55, 0.48, 0.38), Color(0.35, 0.28, 0.2), 12, 2, 8))
	theme.set_stylebox("focus", "Button", _panel(LEAF, GOLD, 12, 3, 8))
	
	var bar_bg := _panel(Color(0.32, 0.22, 0.14, 0.55), Color(0, 0, 0, 0), 6, 0, 4)
	var bar_fill := _panel(GOLD, GOLD_DEEP, 6, 0, 4)
	theme.set_stylebox("background", "ProgressBar", bar_bg)
	theme.set_stylebox("fill", "ProgressBar", bar_fill)
	theme.set_color("font_color", "ProgressBar", Color(0, 0, 0, 0))
	
	theme.set_stylebox("panel", "AcceptDialog", _panel(CREAM, WOOD, 16, 3, 12))
	theme.set_stylebox("embedded_border", "AcceptDialog", _panel(CREAM, WOOD, 16, 3, 12))
	return theme

static func chip_style(selected: bool) -> StyleBoxFlat:
	if selected:
		return _panel(Color(0.99, 0.90, 0.58), GOLD_DEEP, 12, 3, 8)
	return _panel(Color(1, 0.97, 0.9), Color(0.62, 0.45, 0.24), 12, 2, 8)

static func locked_chip_style(ready: bool) -> StyleBoxFlat:
	if ready:
		return _panel(Color(0.93, 0.86, 0.70), GOLD_DEEP, 12, 2, 8)
	return _panel(Color(0.78, 0.72, 0.64), Color(0.42, 0.34, 0.26), 12, 2, 8)

static func row_style() -> StyleBoxFlat:
	return _panel(Color(1, 0.97, 0.91), Color(0.62, 0.42, 0.22, 0.45), 10, 1, 8)

static func top_bar_style() -> StyleBoxFlat:
	return _panel(Color(0.98, 0.93, 0.8, 0.94), WOOD, 16, 3, 10)

static func gold_chip_style() -> StyleBoxFlat:
	return _panel(Color(0.99, 0.88, 0.42), GOLD_DEEP, 18, 2, 10)

static func tab_style(active: bool) -> StyleBoxFlat:
	if active:
		return _panel(LEAF, LEAF_DARK, 12, 2, 8)
	return _panel(Color(0.55, 0.38, 0.22), WOOD_DARK, 12, 2, 8)

static func _panel(bg: Color, border: Color, radius: float, border_w: int, pad: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_w)
	box.set_corner_radius_all(int(radius))
	box.set_content_margin_all(pad)
	box.shadow_color = Color(0.12, 0.08, 0.04, 0.28)
	box.shadow_size = 4
	box.shadow_offset = Vector2(0, 2)
	return box

static func _load_font(path: String) -> FontFile:
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return null
	var font := FontFile.new()
	font.load_dynamic_font(path)
	return font
