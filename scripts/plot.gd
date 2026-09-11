extends Button

signal plot_pressed(grid_position: Vector2i)

var grid_position: Vector2i = Vector2i(0, 0)
var game_data: GameData
var crop_texture: Texture2D
var is_ready: bool = false
var _crop_type = null

@onready var soil: TextureRect = $Soil
@onready var glow: ColorRect = $Glow
@onready var crop: TextureRect = $Crop
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var price_label: Label = $PriceLabel

var _open_soil: Texture2D
var _locked_soil: Texture2D

func _ready():
	pressed.connect(_on_button_pressed)
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty := StyleBoxEmpty.new()
	add_theme_stylebox_override("normal", empty)
	add_theme_stylebox_override("hover", empty)
	add_theme_stylebox_override("pressed", empty)
	add_theme_stylebox_override("disabled", empty)
	add_theme_stylebox_override("focus", empty)
	var pixel_gen := PixelArtGenerator.new()
	_open_soil = ImageTexture.create_from_image(pixel_gen.create_plot_sprite())
	_locked_soil = ImageTexture.create_from_image(pixel_gen.create_locked_plot_sprite())
	soil.texture = _open_soil
	update_visual({"crop_type": null, "growth_stage": 0, "is_ready": false, "unlocked": true})

func _process(_delta):
	if not is_ready:
		return
	var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.007) * 0.08
	crop.scale = Vector2(pulse, pulse)
	glow.modulate.a = 0.22 + sin(Time.get_ticks_msec() * 0.007) * 0.10

func _on_button_pressed():
	plot_pressed.emit(grid_position)

func update_visual(plot_data: Dictionary):
	var unlocked := bool(plot_data.get("unlocked", true))
	if not unlocked:
		_crop_type = null
		is_ready = false
		crop.visible = false
		progress_bar.visible = false
		glow.visible = false
		crop.scale = Vector2.ONE
		soil.texture = _locked_soil
		soil.modulate = Color(0.82, 0.82, 0.82)
		var can_buy := game_data != null and game_data.is_plot_unlockable(grid_position)
		price_label.visible = can_buy
		if can_buy:
			var cost := game_data.plot_unlock_cost()
			price_label.text = str(cost) + "g"
			if game_data.gold >= cost:
				price_label.add_theme_color_override("font_color", Color(0.99, 0.92, 0.55))
				soil.modulate = Color(0.95, 0.95, 0.88)
			else:
				price_label.add_theme_color_override("font_color", Color(0.86, 0.72, 0.62))
		return
	
	soil.texture = _open_soil
	soil.modulate = Color.WHITE
	price_label.visible = false
	var crop_type = plot_data.get("crop_type", null)
	_crop_type = crop_type
	is_ready = bool(plot_data.get("is_ready", false))
	
	if crop_type == null:
		crop.visible = false
		progress_bar.visible = false
		glow.visible = false
		crop.scale = Vector2.ONE
		return
	
	var crop_data = game_data.crops.get(crop_type) if game_data else null
	if crop_data and (_crop_type == crop_type):
		if crop.texture == null or crop.get_meta("crop_id", "") != crop_type:
			var pixel_gen := PixelArtGenerator.new()
			crop.texture = ImageTexture.create_from_image(pixel_gen.create_crop_sprite(crop_type, crop_data.color))
			crop.set_meta("crop_id", crop_type)
	
	crop.visible = true
	if is_ready:
		glow.visible = true
		progress_bar.visible = false
		crop.modulate = Color.WHITE
	else:
		glow.visible = false
		crop.scale = Vector2.ONE
		var growth_progress: float = 0.0
		if crop_data:
			growth_progress = float(plot_data.get("growth_stage", 0)) / float(crop_data.stages)
		crop.modulate = Color(0.82, 0.82, 0.82).lerp(Color.WHITE, growth_progress)
		crop.scale = Vector2(0.55 + growth_progress * 0.45, 0.55 + growth_progress * 0.45)
		progress_bar.visible = true
		progress_bar.value = growth_progress * 100.0
