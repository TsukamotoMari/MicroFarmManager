extends ScrollContainer

## Hidden scrollbars, finger / click-drag panning, no mouse wheel.

@export var scroll_vertical_enabled := true
@export var scroll_horizontal_enabled := false

var _content: Control

func _ready() -> void:
	vertical_scroll_mode = SCROLL_MODE_SHOW_NEVER if scroll_vertical_enabled else SCROLL_MODE_DISABLED
	horizontal_scroll_mode = SCROLL_MODE_SHOW_NEVER if scroll_horizontal_enabled else SCROLL_MODE_DISABLED
	call_deferred("_hook_content_input")

func _hook_content_input() -> void:
	if get_child_count() == 0:
		return
	_content = get_child(0) as Control
	if _content == null:
		return
	if not _content.gui_input.is_connected(_on_content_gui_input):
		_content.gui_input.connect(_on_content_gui_input)

func _gui_input(event: InputEvent) -> void:
	_handle_scroll_input(event)

func _on_content_gui_input(event: InputEvent) -> void:
	_handle_scroll_input(event)

func _handle_scroll_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event()
			return
	if event is InputEventScreenDrag:
		_pan(event.relative)
		accept_event()
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		_pan(event.relative)
		accept_event()

func pan_by(relative: Vector2) -> void:
	_pan(relative)

func _pan(relative: Vector2) -> void:
	if scroll_vertical_enabled:
		var v_bar := get_v_scroll_bar()
		scroll_vertical = clampf(scroll_vertical - relative.y, 0.0, v_bar.max_value)
	if scroll_horizontal_enabled:
		var h_bar := get_h_scroll_bar()
		scroll_horizontal = clampf(scroll_horizontal - relative.x, 0.0, h_bar.max_value)
