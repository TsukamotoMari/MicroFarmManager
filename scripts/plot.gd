extends Button

signal plot_pressed(grid_position: Vector2i)

var grid_position: Vector2i = Vector2i(0, 0)
var game_data: GameData
var crop_texture: Texture2D
var is_ready: bool = false
var _crop_type = null

@onready var soil: TextureRect = $Soil
@onready var water_overlay: TextureRect = $WaterOverlay
@onready var glow: ColorRect = $Glow
@onready var crop: TextureRect = $Crop
@onready var robot: TextureRect = $Robot
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var price_label: Label = $PriceLabel

var _open_soil: Texture2D
var _open_soil_wet: Texture2D
var _locked_soil: Texture2D
var _water_texture: Texture2D
var _robot_texture: Texture2D
var _pixel_gen := PixelArtGenerator.new()

func _ready():
	pressed.connect(_on_button_pressed)
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	texture_filter = TEXTURE_FILTER_NEAREST
	var empty := StyleBoxEmpty.new()
	add_theme_stylebox_override("normal", empty)
	add_theme_stylebox_override("hover", empty)
	add_theme_stylebox_override("pressed", empty)
	add_theme_stylebox_override("disabled", empty)
	add_theme_stylebox_override("focus", empty)
	_open_soil = ImageTexture.create_from_image(_pixel_gen.create_plot_sprite(false))
	_open_soil_wet = ImageTexture.create_from_image(_pixel_gen.create_plot_sprite(true))
	_locked_soil = ImageTexture.create_from_image(_pixel_gen.create_locked_plot_sprite())
	_water_texture = ImageTexture.create_from_image(_pixel_gen.create_water_overlay())
	_robot_texture = ImageTexture.create_from_image(_pixel_gen.create_robot_sprite())
	water_overlay.texture = _water_texture
	robot.texture = _robot_texture
	robot.visible = false
	water_overlay.visible = false
	update_visual({"crop_type": null, "growth_stage": 0, "is_ready": false, "unlocked": true, "watered": false})

func _process(_delta):
	if is_ready:
		var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.007) * 0.08
		crop.scale = Vector2(pulse, pulse)
		glow.modulate.a = 0.22 + sin(Time.get_ticks_msec() * 0.007) * 0.10
	if water_overlay.visible:
		water_overlay.modulate.a = 0.55 + sin(Time.get_ticks_msec() * 0.005) * 0.15

func set_robot_visible(show_robot: bool):
	robot.visible = show_robot
	if show_robot:
		var bounce := sin(Time.get_ticks_msec() * 0.012) * 2.0
		robot.offset_top = -22.0 + bounce
		robot.offset_bottom = 10.0 + bounce

func _on_button_pressed():
	plot_pressed.emit(grid_position)

func update_visual(plot_data: Dictionary):
	var unlocked := bool(plot_data.get("unlocked", true))
	robot.visible = false
	if not unlocked:
		_crop_type = null
		is_ready = false
		crop.visible = false
		progress_bar.visible = false
		glow.visible = false
		water_overlay.visible = false
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
	
	var watered := bool(plot_data.get("watered", false))
	soil.texture = _open_soil_wet if watered else _open_soil
	soil.modulate = Color.WHITE
	water_overlay.visible = watered and plot_data.get("crop_type", null) != null and not plot_data.get("is_ready", false)
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
	if crop_data:
		var stage_key := "%s:%d:%d" % [crop_type, int(plot_data.get("growth_stage", 0)), int(crop_data.stages)]
		if crop.texture == null or crop.get_meta("stage_key", "") != stage_key:
			var stage := int(plot_data.get("growth_stage", 0))
			var max_stages := int(crop_data.stages)
			var sprite_image: Image
			if is_ready:
				sprite_image = _pixel_gen.create_crop_sprite(crop_type, crop_data.color)
			else:
				sprite_image = _pixel_gen.create_crop_sprite(crop_type, crop_data.color, stage, max_stages)
			crop.texture = ImageTexture.create_from_image(sprite_image)
			crop.set_meta("stage_key", stage_key)
	
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
			growth_progress = float(plot_data.get("growth_stage", 0)) / float(maxi(1, crop_data.stages))
		crop.modulate = Color(0.88, 0.88, 0.88).lerp(Color.WHITE, growth_progress)
		progress_bar.visible = true
		progress_bar.value = growth_progress * 100.0
