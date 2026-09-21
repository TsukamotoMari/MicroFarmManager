extends Control

@onready var game_data = GameData.new()
@onready var farm_grid: GridContainer = %FarmGrid
@onready var gold_label: Label = %GoldLabel
@onready var coin_icon: TextureRect = %CoinIcon
@onready var subtitle_label: Label = %SubtitleLabel
@onready var farm_hint: Label = %FarmHint
@onready var crop_bar: HBoxContainer = %CropBar
@onready var market_list: VBoxContainer = %MarketList
@onready var robot_list: VBoxContainer = %RobotList
@onready var prestige_info: Label = %PrestigeInfo
@onready var prestige_button: Button = %PrestigeButton
@onready var achievement_label: Label = %AchievementLabel
@onready var achievement_list: VBoxContainer = %AchievementList
@onready var crop_scroll: ScrollContainer = %CropScroll
@onready var market_scroll: ScrollContainer = %MarketScroll
@onready var robot_scroll: ScrollContainer = %RobotScroll
@onready var upgrade_scroll: ScrollContainer = %UpgradeScroll
@onready var upgrade_list: VBoxContainer = %UpgradeList
@onready var progress_scroll: ScrollContainer = %ProgressScroll
@onready var market_tab: Button = %MarketTab
@onready var bots_tab: Button = %BotsTab
@onready var upgrades_tab: Button = %UpgradesTab
@onready var progress_tab: Button = %ProgressTab
@onready var progress_box: VBoxContainer = %ProgressBox
@onready var toast: Label = %Toast
@onready var offline_popup: AcceptDialog = %OfflinePopup
@onready var coin_rush_popup: AcceptDialog = %CoinRushPopup
@onready var coin_rush_hint: Label = %CoinRushHint
@onready var coin_rush_button: Button = %CoinRushButton
@onready var background: TextureRect = %Background
@onready var top_bar: PanelContainer = %TopBar
@onready var gold_chip: PanelContainer = %GoldChip
@onready var farm_panel: PanelContainer = %FarmPanel
@onready var update_banner: PanelContainer = %UpdateBanner
@onready var update_message: Label = %UpdateMessage
@onready var update_button: Button = %UpdateButton
@onready var version_label: Label = %VersionLabel
@onready var version_request: HTTPRequest = %VersionRequest
@onready var level_label: Label = %LevelLabel
@onready var level_bar: ProgressBar = %LevelBar
@onready var resource_bars: PanelContainer = %ResourceBars
@onready var water_icon: TextureRect = %WaterIcon
@onready var water_bar: ProgressBar = %WaterBar
@onready var water_label: Label = %WaterLabel
@onready var energy_icon: TextureRect = %EnergyIcon
@onready var energy_bar: ProgressBar = %EnergyBar
@onready var energy_label: Label = %EnergyLabel
@onready var farm_center: CenterContainer = %FarmCenter
@onready var content_panel: PanelContainer = %ContentPanel
@onready var title_label: Label = $SafeArea/Layout/TopBar/TopRow/TitleBlock/TitleLabel
@onready var layout_box: VBoxContainer = $SafeArea/Layout
@onready var tab_bar: HBoxContainer = %TabBar

var app_update: AppUpdate
const PLOT_DISPLAY_SIZE := 48
const GRID_GAP := 2
const FARM_FRAME_PAD := 12
const CONTENT_MIN_HEIGHT := 108
const CROP_CHIP_DRAG_THRESHOLD := 10.0
var save_vault: SaveVault
var plot_nodes = []
var update_check_timer: float = 0.0
var _loaded_save_time: int = 0
var save_timer: float = 0.0
var harvest_accumulator: float = 0.0
var plant_accumulator: float = 0.0
var process_accumulator: float = 0.0
var sell_accumulator: float = 0.0
var robot_warmups: Dictionary = {}
var last_inventory_signature: String = ""
var last_plot_gold: int = -1
var toast_timer: float = 0.0
var current_tab: String = "market"
var coin_rush_taps: int = 0
var coin_rush_cooldown: float = 0.0
var broke_prompt_cooldown: float = 0.0
var art := PixelArtGenerator.new()
var active_robot_plot: Vector2i = Vector2i(-1, -1)
var robot_plot_timer: float = 0.0
var _crop_chip_touch: Dictionary = {}
var _check_update_button: Button
var _daily_section: VBoxContainer
var _daily_claim_button: Button
var _daily_info_label: Label
var _goals_list: VBoxContainer
var _goal_buttons: Dictionary = {}

const ROBOT_WARMUP_SECONDS := 6.0
const COIN_RUSH_COOLDOWN := 90.0
const COIN_RUSH_TAPS_NEEDED := 5
const COIN_RUSH_REWARD := 5
const UPDATE_CHECK_DELAY := 0.75
const UPDATE_CHECK_INTERVAL := 45.0

const ROBOT_HELP := {
	"harvester": "Automatically harvests ready crops.",
	"planter": "Plants your selected crop on empty soil.",
	"processor": "Turns harvested crops into products.",
	"seller": "Sells crafted products only."
}

var achievements: Dictionary = {
	"first_harvest": {
		"name": "First Harvest",
		"description": "Harvest your first crop",
		"unlocked": false,
		"requirement_type": "harvest_count",
		"requirement_value": 1
	},
	"farmer": {
		"name": "Farmer",
		"description": "Harvest 100 crops",
		"unlocked": false,
		"requirement_type": "harvest_count",
		"requirement_value": 100
	},
	"master_farmer": {
		"name": "Master Farmer",
		"description": "Harvest 1000 crops",
		"unlocked": false,
		"requirement_type": "harvest_count",
		"requirement_value": 1000
	},
	"rich": {
		"name": "Getting Rich",
		"description": "Earn 10,000 gold total",
		"unlocked": false,
		"requirement_type": "gold_earned",
		"requirement_value": 10000
	},
	"millionaire": {
		"name": "Millionaire",
		"description": "Earn 1,000,000 gold total",
		"unlocked": false,
		"requirement_type": "gold_earned",
		"requirement_value": 1000000
	},
	"robot_owner": {
		"name": "Robot Owner",
		"description": "Buy your first robot",
		"unlocked": false,
		"requirement_type": "robot_owned",
		"requirement_value": 1
	},
	"prestige_1": {
		"name": "First Prestige",
		"description": "Prestige for the first time",
		"unlocked": false,
		"requirement_type": "prestige_level",
		"requirement_value": 1
	},
	"prestige_5": {
		"name": "Prestige Master",
		"description": "Reach prestige level 5",
		"unlocked": false,
		"requirement_type": "prestige_level",
		"requirement_value": 5
	},
	"crop_collector": {
		"name": "Crop Collector",
		"description": "Unlock 15 different crops",
		"unlocked": false,
		"requirement_type": "crops_unlocked",
		"requirement_value": 15
	},
	"luxury_farmer": {
		"name": "Luxury Farmer",
		"description": "Unlock every crop through Saffron",
		"unlocked": false,
		"requirement_type": "crops_unlocked",
		"requirement_value": 22
	}
}

func _ready():
	theme = FarmTheme.create()
	texture_filter = TEXTURE_FILTER_NEAREST
	_apply_backdrop()
	_configure_mobile_layout()
	_load_game()
	app_update = AppUpdate.new()
	app_update.connect_installer_signals()
	_setup_farm_grid()
	_setup_ui()
	_show_tab("market")
	_check_offline_progress()
	_prompt_daily_reward()
	if not coin_rush_button.pressed.is_connected(_on_coin_rush_tap):
		coin_rush_button.pressed.connect(_on_coin_rush_tap)
	save_vault = SaveVault.new()
	if not save_vault.read_finished.is_connected(_on_cloud_save_read):
		save_vault.read_finished.connect(_on_cloud_save_read)
	app_update.update_available.connect(_on_update_available)
	app_update.status_changed.connect(_on_update_status_changed)
	app_update.check_finished.connect(_on_update_check_finished)
	if not update_button.pressed.is_connected(_on_update_button_pressed):
		update_button.pressed.connect(_on_update_button_pressed)
	version_request.timeout = 20.0
	_update_version_label()
	get_tree().create_timer(UPDATE_CHECK_DELAY).timeout.connect(_check_for_app_update)
	call_deferred("_restore_cloud_save")
	set_process(true)

func _configure_mobile_layout():
	var farm_scroll := layout_box.get_node_or_null("FarmScroll")
	if farm_scroll:
		layout_box.add_child(farm_panel)
		layout_box.move_child(farm_panel, farm_scroll.get_index())
		farm_scroll.queue_free()
	layout_box.move_child(tab_bar, layout_box.get_child_count() - 1)
	farm_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	content_panel.custom_minimum_size = Vector2(0, CONTENT_MIN_HEIGHT)
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	crop_scroll.custom_minimum_size = Vector2(0, 68)
	farm_hint.add_theme_font_size_override("font_size", 11)
	for scroll in [market_scroll, robot_scroll, upgrade_scroll, progress_scroll]:
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _farm_block_height() -> int:
	var rows: int = game_data.grid_size.y
	var inner_h: int = rows * PLOT_DISPLAY_SIZE + (rows - 1) * GRID_GAP
	return inner_h + FARM_FRAME_PAD * 2

func _resize_farm_panel() -> void:
	farm_panel.custom_minimum_size = Vector2(0, _farm_block_height())
	var cols: int = game_data.grid_size.x
	var rows: int = game_data.grid_size.y
	var inner_w: int = cols * PLOT_DISPLAY_SIZE + (cols - 1) * GRID_GAP
	var inner_h: int = rows * PLOT_DISPLAY_SIZE + (rows - 1) * GRID_GAP
	var host := farm_center.get_node_or_null("FarmHost") as Control
	if host:
		host.custom_minimum_size = Vector2(inner_w + FARM_FRAME_PAD * 2, inner_h + FARM_FRAME_PAD * 2)
		var frame := host.get_node_or_null("FarmFrame") as NinePatchRect
		if frame:
			frame.texture = ImageTexture.create_from_image(
				art.create_farm_fence_frame(inner_w, inner_h, FARM_FRAME_PAD)
			)
			frame.texture_filter = TEXTURE_FILTER_NEAREST
			frame.patch_margin_left = FARM_FRAME_PAD
			frame.patch_margin_top = FARM_FRAME_PAD
			frame.patch_margin_right = FARM_FRAME_PAD
			frame.patch_margin_bottom = FARM_FRAME_PAD

func _apply_backdrop():
	SpriteBank.reset()
	FarmTheme.reset_textures()
	background.texture = ImageTexture.create_from_image(art.create_background(480, 854))
	background.texture_filter = TEXTURE_FILTER_NEAREST
	coin_icon.texture = ImageTexture.create_from_image(art.create_coin_icon())
	coin_icon.texture_filter = TEXTURE_FILTER_NEAREST
	coin_icon.custom_minimum_size = Vector2(22, 22)
	coin_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	water_icon.texture = ImageTexture.create_from_image(art.create_water_icon())
	energy_icon.texture = ImageTexture.create_from_image(art.create_energy_icon())
	top_bar.add_theme_stylebox_override("panel", FarmTheme.top_bar_style())
	gold_chip.add_theme_stylebox_override("panel", FarmTheme.gold_chip_style())
	gold_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.42))
	gold_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	farm_panel.add_theme_stylebox_override("panel", FarmTheme.transparent_panel())
	content_panel.add_theme_stylebox_override("panel", FarmTheme.wood_panel(10))
	resource_bars.add_theme_stylebox_override("panel", FarmTheme.resource_panel_style())
	toast.add_theme_stylebox_override("normal", FarmTheme.wood_panel(8))
	update_banner.add_theme_stylebox_override("panel", FarmTheme.wood_panel(8, true))
	water_bar.add_theme_stylebox_override("background", FarmTheme.water_bar_bg())
	water_bar.add_theme_stylebox_override("fill", FarmTheme.water_bar_fill())
	energy_bar.add_theme_stylebox_override("background", FarmTheme.energy_bar_bg())
	energy_bar.add_theme_stylebox_override("fill", FarmTheme.energy_bar_fill())
	level_bar.add_theme_stylebox_override("background", FarmTheme.level_bar_bg())
	level_bar.add_theme_stylebox_override("fill", FarmTheme.level_bar_fill())
	_apply_tab_icons()
	_apply_pixel_label_colors()

func _update_version_label():
	if app_update == null:
		return
	version_label.text = "v" + app_update.get_local_version_name() + " · " + str(app_update.get_local_version_code())

func _check_for_app_update():
	if app_update == null:
		return
	app_update.check_for_update(version_request)

func _on_check_update_pressed():
	if app_update == null:
		return
	app_update.reset_and_check(version_request)
	_show_toast("Checking for updates…")

func _on_update_available(_info: Dictionary):
	_refresh_update_banner()

func _on_update_status_changed(_message: String):
	_refresh_update_banner()

func _on_update_check_finished(found: bool, error: String) -> void:
	if found:
		_refresh_update_banner()
	elif not error.is_empty() and not app_update.has_update():
		_show_toast(error)

func _on_update_button_pressed():
	app_update.install_update()
	_refresh_update_banner()

func _refresh_update_banner():
	if not app_update.has_update():
		update_banner.visible = false
		return
	update_banner.visible = true
	var remote := app_update.remote
	if app_update.message != "":
		update_message.text = app_update.message
	elif app_update.ready:
		update_message.text = "Download finished. Tap Install now and confirm the Android screen."
	else:
		update_message.text = "Micro Farm %s (build %d) is ready. Download it, then install over this app to keep your save." % [
			str(remote.get("version", "?")),
			int(remote.get("versionCode", 0))
		]
	update_button.disabled = app_update.busy
	update_button.text = "Downloading…" if app_update.busy else ("Install now" if app_update.ready else "Download update")

func _apply_pixel_label_colors():
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", FarmTheme.CREAM)
	title_label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.02, 0.85))
	title_label.add_theme_constant_override("outline_size", 2)
	version_label.visible = false
	subtitle_label.add_theme_font_size_override("font_size", 11)
	subtitle_label.add_theme_color_override("font_color", FarmTheme.CREAM_MUTED)
	level_label.add_theme_font_size_override("font_size", 10)
	level_label.add_theme_color_override("font_color", FarmTheme.CREAM_MUTED)
	farm_hint.add_theme_color_override("font_color", FarmTheme.CREAM)
	farm_hint.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.02, 0.9))
	farm_hint.add_theme_constant_override("outline_size", 3)
	gold_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.42))
	water_label.add_theme_color_override("font_color", FarmTheme.CREAM_MUTED)
	energy_label.add_theme_color_override("font_color", FarmTheme.CREAM_MUTED)

func _apply_tab_icons():
	var tabs := {
		"market": market_tab,
		"bots": bots_tab,
		"upgrades": upgrades_tab,
		"progress": progress_tab
	}
	for tab_id in tabs:
		var button: Button = tabs[tab_id]
		button.icon = ImageTexture.create_from_image(art.create_tab_icon(tab_id))
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 26)
		button.add_theme_font_size_override("font_size", 12)
		button.add_theme_color_override("font_color", FarmTheme.CREAM)

func _process(delta):
	game_data.play_time += delta
	game_data.regen_resources(delta)
	robot_plot_timer = maxf(0.0, robot_plot_timer - delta)
	if robot_plot_timer <= 0.0:
		_clear_robot_marker()
	update_check_timer += delta
	if update_check_timer >= UPDATE_CHECK_INTERVAL:
		update_check_timer = 0.0
		if app_update != null and not app_update.has_update():
			_check_for_app_update()
	if coin_rush_cooldown > 0.0:
		coin_rush_cooldown = maxf(0.0, coin_rush_cooldown - delta)
	if broke_prompt_cooldown > 0.0:
		broke_prompt_cooldown = maxf(0.0, broke_prompt_cooldown - delta)
	_update_crop_growth(delta)
	_update_ui()
	_auto_robot_actions(delta)
	_check_achievements()
	_check_broke_state()
	
	save_timer += delta
	if save_timer >= 30.0:
		save_timer = 0.0
		_save_game()
	
	if toast.visible:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast.visible = false

func _setup_farm_grid():
	plot_nodes.clear()
	for x in game_data.grid_size.x:
		plot_nodes.append([])
		for y in game_data.grid_size.y:
			plot_nodes[x].append(null)
	var cols: int = game_data.grid_size.x
	var rows: int = game_data.grid_size.y
	var inner_w: int = cols * PLOT_DISPLAY_SIZE + (cols - 1) * GRID_GAP
	var inner_h: int = rows * PLOT_DISPLAY_SIZE + (rows - 1) * GRID_GAP
	if farm_center.get_node_or_null("FarmHost") == null:
		var host := Control.new()
		host.name = "FarmHost"
		host.custom_minimum_size = Vector2(inner_w + FARM_FRAME_PAD * 2, inner_h + FARM_FRAME_PAD * 2)
		var frame := NinePatchRect.new()
		frame.name = "FarmFrame"
		frame.texture = ImageTexture.create_from_image(art.create_farm_fence_frame(inner_w, inner_h, FARM_FRAME_PAD))
		frame.texture_filter = TEXTURE_FILTER_NEAREST
		frame.set_anchors_preset(Control.PRESET_FULL_RECT)
		frame.patch_margin_left = FARM_FRAME_PAD
		frame.patch_margin_top = FARM_FRAME_PAD
		frame.patch_margin_right = FARM_FRAME_PAD
		frame.patch_margin_bottom = FARM_FRAME_PAD
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(frame)
		farm_grid.reparent(host)
		farm_grid.position = Vector2(FARM_FRAME_PAD, FARM_FRAME_PAD)
		farm_center.add_child(host)
	farm_grid.columns = cols
	farm_grid.add_theme_constant_override("h_separation", GRID_GAP)
	farm_grid.add_theme_constant_override("v_separation", GRID_GAP)
	for child in farm_grid.get_children():
		farm_grid.remove_child(child)
		child.queue_free()
	for y in rows:
		for x in cols:
			var plot = preload("res://scenes/plot.tscn").instantiate()
			plot.grid_position = Vector2i(x, y)
			plot.game_data = game_data
			plot.plot_pressed.connect(_on_plot_pressed)
			farm_grid.add_child(plot)
			plot_nodes[x][y] = plot
	_resize_farm_panel()
	_refresh_farm_visuals()

func _setup_ui():
	_update_gold_display()
	_setup_crop_selector()
	_setup_robot_panel()
	_setup_upgrades_panel()
	_refresh_inventory_panel()
	_setup_daily_panel()
	_setup_prestige_panel()
	_setup_check_update_button()
	_setup_achievements_panel()
	
	if not market_tab.pressed.is_connected(_on_market_tab):
		market_tab.pressed.connect(_on_market_tab)
		bots_tab.pressed.connect(_on_bots_tab)
		upgrades_tab.pressed.connect(_on_upgrades_tab)
		progress_tab.pressed.connect(_on_progress_tab)
		prestige_button.pressed.connect(_on_prestige_pressed)

func _on_market_tab():
	_show_tab("market")

func _on_bots_tab():
	_show_tab("bots")

func _on_upgrades_tab():
	_show_tab("upgrades")

func _on_progress_tab():
	_show_tab("progress")
	_refresh_daily_panel()

func _show_tab(tab_name: String):
	current_tab = tab_name
	market_scroll.visible = tab_name == "market"
	robot_scroll.visible = tab_name == "bots"
	upgrade_scroll.visible = tab_name == "upgrades"
	progress_scroll.visible = tab_name == "progress"
	_style_tab(market_tab, tab_name == "market")
	_style_tab(bots_tab, tab_name == "bots")
	_style_tab(upgrades_tab, tab_name == "upgrades")
	_style_tab(progress_tab, tab_name == "progress")
	if tab_name == "progress":
		_refresh_daily_panel()

func _style_tab(button: Button, active: bool):
	var style := FarmTheme.tab_style(active)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_color_override("font_color", FarmTheme.GOLD if active else FarmTheme.CREAM_MUTED)
	button.modulate = Color(1.05, 1.02, 0.92) if active else Color(0.82, 0.78, 0.72)

func _format_gold(amount: float) -> String:
	var value := int(amount)
	var text := str(value)
	var result := ""
	var count := 0
	for i in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = text[i] + result
		count += 1
	return result

func _update_gold_display():
	gold_label.text = _format_gold(game_data.gold) + "g"
	var crop_data = game_data.crops.get(game_data.selected_crop, {})
	var tier := int(crop_data.get("tier", 1))
	var grow := int(crop_data.get("growth_time", 0))
	var version_suffix := ""
	if app_update != null:
		version_suffix = " · v" + app_update.get_local_version_name() + " · " + str(app_update.get_local_version_code())
	subtitle_label.text = "T" + str(tier) + " " + str(crop_data.get("name", "Wheat")) + " · " + str(grow) + "s · " + str(game_data.unlocked_plot_count()) + "/" + str(game_data.total_plot_count()) + " plots" + version_suffix
	var xp_into := game_data.farmer_xp_into_level()
	level_label.text = "Next Level " + str(xp_into) + " / " + str(GameData.FARMER_XP_PER_LEVEL)
	level_bar.max_value = float(GameData.FARMER_XP_PER_LEVEL)
	level_bar.value = float(xp_into)
	water_bar.max_value = GameData.WATER_MAX
	water_bar.value = game_data.water
	water_label.text = str(int(floor(game_data.water))) + " / " + str(int(GameData.WATER_MAX))
	energy_bar.max_value = GameData.ROBOT_ENERGY_MAX
	energy_bar.value = game_data.robot_energy
	energy_label.text = str(int(floor(game_data.robot_energy))) + " / " + str(int(GameData.ROBOT_ENERGY_MAX))
	_update_farm_hint()

func _update_farm_hint():
	var parts: PackedStringArray = []
	var next_id := game_data.next_unlock_crop()
	if next_id == "":
		parts.append("Crops glow gold when they are ready to harvest")
	else:
		var next_crop = game_data.crops[next_id]
		var prev_id := game_data.previous_crop(next_id)
		var have := game_data.get_crop_harvests(prev_id)
		var need := int(next_crop.unlock_harvest)
		parts.append("Unlock T" + str(int(next_crop.tier)) + " " + next_crop.name + "  ·  " + str(mini(have, need)) + "/" + str(need) + " " + game_data.crops[prev_id].name + "  ·  " + _format_gold(next_crop.unlock_cost) + "g")
	if game_data.unlocked_plot_count() < game_data.total_plot_count():
		parts.append("Next plot " + _format_gold(game_data.plot_unlock_cost()) + "g")
	farm_hint.text = "  ·  ".join(parts)

func _clear_children(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _style_crop_chip(chip: Button, selected: bool, locked: bool = false, ready: bool = false):
	var normal := FarmTheme.chip_style(selected, ready) if not locked else FarmTheme.locked_chip_style(ready)
	var hover := FarmTheme.chip_style(true, ready) if not locked else FarmTheme.locked_chip_style(true)
	chip.add_theme_stylebox_override("normal", normal)
	chip.add_theme_stylebox_override("hover", hover)
	chip.add_theme_stylebox_override("pressed", hover)

func _crop_chip_text(crop_id: String) -> String:
	var crop_data = game_data.crops[crop_id]
	if game_data.is_crop_unlocked(crop_id):
		return crop_data.name + "\n" + str(int(crop_data.cost)) + "g · " + str(int(crop_data.growth_time)) + "s"
	if game_data.next_unlock_crop() == crop_id:
		var prev_id := game_data.previous_crop(crop_id)
		var have := game_data.get_crop_harvests(prev_id)
		var need := int(crop_data.unlock_harvest)
		return crop_data.name + "\n" + str(mini(have, need)) + "/" + str(need) + " · " + str(int(crop_data.unlock_cost)) + "g"
	return crop_data.name + "\nT" + str(int(crop_data.tier)) + " Locked"

func _apply_crop_chip(chip: Button, crop_id: String):
	var unlocked := game_data.is_crop_unlocked(crop_id)
	var ready := game_data.is_unlock_harvest_ready(crop_id)
	chip.text = _crop_chip_text(crop_id)
	chip.modulate = Color.WHITE if unlocked or ready else Color(0.72, 0.72, 0.72)
	_style_crop_chip(chip, crop_id == game_data.selected_crop, not unlocked, ready)

func _setup_crop_selector():
	_clear_children(crop_bar)
	for crop_id in game_data.CROP_ORDER:
		var crop_data = game_data.crops[crop_id]
		var chip := Button.new()
		chip.set_meta("crop_id", crop_id)
		chip.custom_minimum_size = Vector2(76, 68)
		chip.icon = ImageTexture.create_from_image(art.create_crop_sprite(crop_id, crop_data.color))
		chip.expand_icon = true
		chip.add_theme_constant_override("icon_max_width", 36)
		chip.add_theme_font_size_override("font_size", 10)
		chip.add_theme_color_override("font_color", FarmTheme.CREAM)
		chip.add_theme_color_override("font_pressed_color", FarmTheme.GOLD)
		chip.add_theme_color_override("font_hover_color", Color.WHITE)
		_apply_crop_chip(chip, crop_id)
		chip.focus_mode = Control.FOCUS_NONE
		chip.gui_input.connect(_on_crop_chip_gui_input.bind(crop_id, chip))
		crop_bar.add_child(chip)

func _refresh_crop_chips():
	if crop_bar.get_child_count() == 0:
		_setup_crop_selector()
		return
	for child in crop_bar.get_children():
		if child is Button:
			_apply_crop_chip(child, child.get_meta("crop_id"))

func _on_crop_chip_gui_input(event: InputEvent, crop_id: String, chip: Button) -> void:
	var key := chip.get_instance_id()
	if event is InputEventScreenTouch:
		if event.pressed:
			_crop_chip_touch[key] = {"start": event.position, "dragging": false}
		else:
			var touch: Dictionary = _crop_chip_touch.get(key, {})
			_crop_chip_touch.erase(key)
			if not touch.get("dragging", false):
				_on_crop_chip_pressed(crop_id)
			chip.accept_event()
	elif event is InputEventScreenDrag:
		var touch: Dictionary = _crop_chip_touch.get(key, {})
		if touch.is_empty():
			return
		if event.position.distance_to(touch["start"]) > CROP_CHIP_DRAG_THRESHOLD:
			touch["dragging"] = true
		if touch["dragging"]:
			crop_scroll.pan_by(event.relative)
			chip.accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_crop_chip_touch[key] = {"start": event.position, "dragging": false}
		else:
			var touch: Dictionary = _crop_chip_touch.get(key, {})
			_crop_chip_touch.erase(key)
			if not touch.get("dragging", false):
				_on_crop_chip_pressed(crop_id)
			chip.accept_event()
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		var touch: Dictionary = _crop_chip_touch.get(key, {})
		if touch.is_empty():
			return
		if event.position.distance_to(touch["start"]) > CROP_CHIP_DRAG_THRESHOLD:
			touch["dragging"] = true
		if touch["dragging"]:
			crop_scroll.pan_by(event.relative)
			chip.accept_event()

func _on_crop_chip_pressed(crop_id: String):
	if game_data.is_crop_unlocked(crop_id):
		game_data.selected_crop = crop_id
		_refresh_crop_chips()
		_update_gold_display()
		_show_toast("Selected " + game_data.crops[crop_id].name)
		return
	if game_data.next_unlock_crop() != crop_id:
		_show_toast(game_data.unlock_block_reason(crop_id))
		return
	if game_data.unlock_crop(crop_id):
		call_deferred("_setup_crop_selector")
		_show_toast(game_data.crops[crop_id].name + " unlocked")
		_update_gold_display()
	else:
		_show_toast(game_data.unlock_block_reason(crop_id))

func _setup_robot_panel():
	_clear_children(robot_list)
	var robot_icon := ImageTexture.create_from_image(art.create_robot_sprite())
	for robot_id in game_data.robots:
		var robot = game_data.robots[robot_id]
		var level := game_data.get_robot_level(robot)
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.add_theme_stylebox_override("panel", FarmTheme.row_style())
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_theme_constant_override("separation", 10)
		var icon := TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture_filter = TEXTURE_FILTER_NEAREST
		icon.custom_minimum_size = Vector2(36, 36)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = robot_icon
		var info := VBoxContainer.new()
		info.mouse_filter = Control.MOUSE_FILTER_PASS
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var title := Label.new()
		if level > 0:
			title.text = robot.name + "  ·  Lv " + str(level)
		else:
			title.text = robot.name
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title.add_theme_font_size_override("font_size", 16)
		var help := Label.new()
		if level > 0:
			help.text = ROBOT_HELP.get(robot_id, "") + "\n" + _robot_progress_text(robot_id)
		else:
			help.text = ROBOT_HELP.get(robot_id, "") + "\nHire to start, then keep upgrading."
		help.mouse_filter = Control.MOUSE_FILTER_IGNORE
		help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		help.add_theme_font_size_override("font_size", 12)
		help.add_theme_color_override("font_color", FarmTheme.MUTED)
		info.add_child(title)
		info.add_child(help)
		var action := Button.new()
		action.custom_minimum_size = Vector2(108, 36)
		if game_data.robot_is_maxed(robot_id):
			action.text = "Maxed"
			action.disabled = true
		elif level > 0:
			action.text = "Lv " + str(level + 1) + "  " + _format_gold(game_data.robot_next_cost(robot_id)) + "g"
			action.pressed.connect(_on_robot_upgrade.bind(robot_id))
		else:
			action.text = "Hire  " + _format_gold(game_data.robot_next_cost(robot_id)) + "g"
			action.pressed.connect(_on_robot_upgrade.bind(robot_id))
		row.add_child(icon)
		row.add_child(info)
		row.add_child(action)
		card.add_child(row)
		robot_list.add_child(card)

func _robot_multiplier() -> float:
	return game_data.get_total_robot_multiplier()

func _robot_stat_line(robot_id: String) -> String:
	var interval := game_data.robot_action_interval(robot_id, _robot_multiplier())
	return "Every %.1fs  ·  %d per action" % [interval, game_data.robot_batch_size(robot_id)]

func _robot_progress_text(robot_id: String) -> String:
	var text := _robot_stat_line(robot_id)
	if game_data.robot_is_maxed(robot_id):
		return text + "\nFully upgraded"
	var next_level := game_data.get_robot_level(game_data.robots[robot_id]) + 1
	var next_interval := 1.0 / maxf(0.001, game_data.robot_work_speed_for_level(robot_id, next_level) * _robot_multiplier())
	return text + "\nNext: every %.1fs  ·  %d per action" % [
		next_interval,
		game_data.robot_batch_size_for_level(next_level)
	]

func _on_robot_upgrade(robot_id: String):
	var robot = game_data.robots[robot_id]
	var price := game_data.robot_next_cost(robot_id)
	if game_data.robot_is_maxed(robot_id):
		return
	if game_data.gold < price:
		_show_toast("Need " + _format_gold(price - game_data.gold) + " more gold")
		return
	var was_new := game_data.get_robot_level(robot) <= 0
	if game_data.upgrade_robot(robot_id):
		_reset_robot_warmup(robot_id, ROBOT_WARMUP_SECONDS if was_new else 2.0)
		call_deferred("_setup_robot_panel")
		if was_new:
			_show_toast(robot.name + " hired")
		else:
			_show_toast(robot.name + " reached Lv " + str(game_data.get_robot_level(robot)))

func _refresh_inventory_panel():
	_clear_children(market_list)
	var header := Label.new()
	header.text = "Crops"
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", FarmTheme.MUTED)
	market_list.add_child(header)
	
	for crop_id in game_data.CROP_ORDER:
		if not game_data.unlocked_crops.has(crop_id):
			continue
		var crop_data = game_data.crops[crop_id]
		var count := int(game_data.crop_inventory.get(crop_id, 0))
		_add_market_row(
			art.create_crop_sprite(crop_id, crop_data.color),
			crop_data.name,
			"x" + str(count) + "  ·  sells for " + str(crop_data.sell_price) + "g",
			"Sell",
			count > 0,
			_on_sell_crop.bind(crop_id)
		)
	
	var crafted := Label.new()
	crafted.text = "Products"
	crafted.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crafted.add_theme_font_size_override("font_size", 14)
	crafted.add_theme_color_override("font_color", FarmTheme.MUTED)
	market_list.add_child(crafted)
	
	for product_id in game_data.products:
		var product = game_data.products[product_id]
		if not game_data.unlocked_crops.has(product.input_crop):
			continue
		var inv_count := int(game_data.product_inventory.get(product_id, 0))
		var have := int(game_data.crop_inventory.get(product.input_crop, 0))
		var can_make := have >= int(product.input_amount)
		_add_product_row(
			art.create_product_sprite(product_id, product.color),
			product.name,
			"x" + str(inv_count) + "  ·  " + str(product.input_amount) + " " + game_data.crops[product.input_crop].name + " to make",
			can_make,
			inv_count > 0,
			product_id
		)
	last_inventory_signature = _inventory_signature()

func _add_product_row(icon_image: Image, title_text: String, subtitle_text: String, can_make: bool, can_sell: bool, product_id: String):
	var card := PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_theme_stylebox_override("panel", FarmTheme.row_style())
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_theme_constant_override("separation", 10)
	var icon := TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture_filter = TEXTURE_FILTER_NEAREST
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = ImageTexture.create_from_image(icon_image)
	var info := VBoxContainer.new()
	info.mouse_filter = Control.MOUSE_FILTER_PASS
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := Label.new()
	title.text = title_text
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("font_size", 15)
	var subtitle := Label.new()
	subtitle.text = subtitle_text
	subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", FarmTheme.MUTED)
	info.add_child(title)
	info.add_child(subtitle)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	var make_btn := Button.new()
	make_btn.custom_minimum_size = Vector2(64, 36)
	make_btn.text = "Make"
	make_btn.disabled = not can_make
	if can_make:
		make_btn.pressed.connect(_on_make_product.bind(product_id))
	var sell_btn := Button.new()
	sell_btn.custom_minimum_size = Vector2(64, 36)
	sell_btn.text = "Sell"
	sell_btn.disabled = not can_sell
	if can_sell:
		sell_btn.pressed.connect(_on_sell_product.bind(product_id))
	actions.add_child(make_btn)
	actions.add_child(sell_btn)
	row.add_child(icon)
	row.add_child(info)
	row.add_child(actions)
	card.add_child(row)
	market_list.add_child(card)

func _add_market_row(icon_image: Image, title_text: String, subtitle_text: String, action_text: String, enabled: bool, callback: Callable):
	var card := PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_theme_stylebox_override("panel", FarmTheme.row_style())
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_theme_constant_override("separation", 10)
	var icon := TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture_filter = TEXTURE_FILTER_NEAREST
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = ImageTexture.create_from_image(icon_image)
	var info := VBoxContainer.new()
	info.mouse_filter = Control.MOUSE_FILTER_PASS
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := Label.new()
	title.text = title_text
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("font_size", 15)
	var subtitle := Label.new()
	subtitle.text = subtitle_text
	subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", FarmTheme.MUTED)
	info.add_child(title)
	info.add_child(subtitle)
	var action := Button.new()
	action.custom_minimum_size = Vector2(72, 34)
	action.text = action_text
	action.disabled = not enabled
	if enabled:
		action.pressed.connect(callback)
	row.add_child(icon)
	row.add_child(info)
	row.add_child(action)
	card.add_child(row)
	market_list.add_child(card)

func _on_sell_crop(crop_id: String):
	if game_data.sell_crop(crop_id, 1):
		call_deferred("_refresh_inventory_panel")
	else:
		_show_toast("Nothing to sell")

func _on_make_product(product_id: String):
	if game_data.process_product(product_id, 1):
		call_deferred("_refresh_inventory_panel")
		_show_toast("Made " + game_data.products[product_id].name)
	else:
		_show_toast("Need more crops to craft")

func _on_sell_product(product_id: String):
	if game_data.sell_product(product_id, 1):
		call_deferred("_refresh_inventory_panel")
	else:
		_show_toast("Nothing to sell")

func _setup_upgrades_panel():
	_clear_children(upgrade_list)
	var header := Label.new()
	header.text = "Spend gold to improve this run."
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_theme_font_size_override("font_size", 13)
	header.add_theme_color_override("font_color", FarmTheme.MUTED)
	upgrade_list.add_child(header)
	for upgrade_id in game_data.farm_upgrades:
		var upgrade = game_data.farm_upgrades[upgrade_id]
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.add_theme_stylebox_override("panel", FarmTheme.row_style())
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_theme_constant_override("separation", 10)
		var info := VBoxContainer.new()
		info.mouse_filter = Control.MOUSE_FILTER_PASS
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var title := Label.new()
		title.text = upgrade.name + "  ·  Lv " + str(upgrade.current_level) + "/" + str(upgrade.max_level)
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title.add_theme_font_size_override("font_size", 15)
		var help := Label.new()
		help.text = upgrade.description
		help.mouse_filter = Control.MOUSE_FILTER_IGNORE
		help.add_theme_font_size_override("font_size", 12)
		help.add_theme_color_override("font_color", FarmTheme.MUTED)
		info.add_child(title)
		info.add_child(help)
		var action := Button.new()
		action.custom_minimum_size = Vector2(92, 36)
		if upgrade.current_level >= upgrade.max_level:
			action.text = "Maxed"
			action.disabled = true
		else:
			action.text = _format_gold(game_data.farm_upgrade_cost(upgrade_id)) + "g"
			action.pressed.connect(_on_buy_farm_upgrade.bind(upgrade_id))
		row.add_child(info)
		row.add_child(action)
		card.add_child(row)
		upgrade_list.add_child(card)

func _on_buy_farm_upgrade(upgrade_id: String):
	if game_data.buy_farm_upgrade(upgrade_id):
		call_deferred("_setup_upgrades_panel")
		_show_toast(game_data.farm_upgrades[upgrade_id].name + " upgraded")
	else:
		_show_toast("Need more gold")

func _reset_robot_warmup(robot_id: String, seconds: float):
	robot_warmups[robot_id] = seconds
	match robot_id:
		"harvester":
			harvest_accumulator = 0.0
		"planter":
			plant_accumulator = 0.0
		"processor":
			process_accumulator = 0.0
		"seller":
			sell_accumulator = 0.0

func _robot_ready(robot_id: String, delta: float) -> bool:
	var warmup := float(robot_warmups.get(robot_id, 0.0))
	if warmup <= 0.0:
		return true
	robot_warmups[robot_id] = maxf(0.0, warmup - delta)
	return false

func _check_broke_state():
	if not game_data.should_offer_coin_rush() or coin_rush_cooldown > 0.0 or broke_prompt_cooldown > 0.0:
		return
	if coin_rush_popup.visible:
		return
	broke_prompt_cooldown = 20.0
	_offer_coin_rush()

func _offer_coin_rush():
	coin_rush_taps = 0
	coin_rush_button.text = "Tap!  0/" + str(COIN_RUSH_TAPS_NEEDED)
	coin_rush_hint.text = "Out of gold and nothing left to sell!\nTap the coin " + str(COIN_RUSH_TAPS_NEEDED) + " times to earn " + str(COIN_RUSH_REWARD) + " gold."
	coin_rush_popup.popup_centered()

func _on_coin_rush_tap():
	if coin_rush_taps >= COIN_RUSH_TAPS_NEEDED:
		return
	coin_rush_taps += 1
	coin_rush_button.text = "Tap!  " + str(coin_rush_taps) + "/" + str(COIN_RUSH_TAPS_NEEDED)
	if coin_rush_taps >= COIN_RUSH_TAPS_NEEDED:
		game_data.gold += float(COIN_RUSH_REWARD)
		coin_rush_cooldown = COIN_RUSH_COOLDOWN
		_update_gold_display()
		_show_toast("Earned " + str(COIN_RUSH_REWARD) + " gold from Coin Rush")
		coin_rush_popup.hide()

func _inventory_signature() -> String:
	return str(game_data.crop_inventory) + str(game_data.product_inventory)

func _setup_daily_panel() -> void:
	game_data.ensure_daily_state()
	if _daily_section == null or not is_instance_valid(_daily_section):
		_daily_section = VBoxContainer.new()
		_daily_section.add_theme_constant_override("separation", 6)
		progress_box.add_child(_daily_section)
		progress_box.move_child(_daily_section, 0)
		var title := Label.new()
		title.text = "Daily"
		title.add_theme_font_size_override("font_size", 16)
		title.add_theme_color_override("font_color", FarmTheme.GOLD)
		_daily_section.add_child(title)
		_daily_info_label = Label.new()
		_daily_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_daily_info_label.add_theme_font_size_override("font_size", 12)
		_daily_info_label.add_theme_color_override("font_color", FarmTheme.CREAM_MUTED)
		_daily_section.add_child(_daily_info_label)
		_daily_claim_button = Button.new()
		_daily_claim_button.custom_minimum_size = Vector2(0, 40)
		_daily_claim_button.pressed.connect(_on_claim_daily_reward)
		_daily_section.add_child(_daily_claim_button)
		var goals_title := Label.new()
		goals_title.text = "Today's Goals"
		goals_title.add_theme_font_size_override("font_size", 14)
		goals_title.add_theme_color_override("font_color", FarmTheme.CREAM)
		_daily_section.add_child(goals_title)
		_goals_list = VBoxContainer.new()
		_goals_list.add_theme_constant_override("separation", 6)
		_daily_section.add_child(_goals_list)
	_refresh_daily_panel()

func _refresh_daily_panel() -> void:
	if _daily_section == null or not is_instance_valid(_daily_section):
		return
	game_data.ensure_daily_state()
	var preview_streak := game_data.preview_daily_streak()
	var next_reward := game_data.daily_streak_reward(preview_streak)
	_daily_info_label.text = "Login streak: Day " + str(preview_streak) + " / 7  ·  Best daily bonuses stack up to day 7."
	if game_data.can_claim_daily_reward():
		_daily_claim_button.disabled = false
		_daily_claim_button.text = "Claim daily  +" + str(next_reward) + "g"
	else:
		_daily_claim_button.disabled = true
		_daily_claim_button.text = "Daily claimed  ·  Day " + str(maxi(1, game_data.login_streak)) + "/7"
	_clear_children(_goals_list)
	_goal_buttons.clear()
	for goal_id in ["harvest", "sell", "craft"]:
		if not game_data.daily_goals.has(goal_id):
			continue
		var goal: Dictionary = game_data.daily_goals[goal_id]
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.add_theme_stylebox_override("panel", FarmTheme.row_style())
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var title := Label.new()
		title.text = str(goal.get("name", "Goal"))
		title.add_theme_font_size_override("font_size", 14)
		var progress := Label.new()
		progress.text = str(goal.get("description", "")) + "\n" + str(int(goal.get("progress", 0))) + " / " + str(int(goal.get("target", 1)))
		progress.add_theme_font_size_override("font_size", 11)
		progress.add_theme_color_override("font_color", FarmTheme.MUTED)
		progress.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(title)
		info.add_child(progress)
		var action := Button.new()
		action.custom_minimum_size = Vector2(88, 36)
		if bool(goal.get("claimed", false)):
			action.text = "Done"
			action.disabled = true
		elif game_data.can_claim_daily_goal(goal_id):
			action.text = "+" + str(int(goal.get("reward", 0))) + "g"
			action.disabled = false
			action.pressed.connect(_on_claim_daily_goal.bind(goal_id))
		else:
			action.text = str(int(goal.get("reward", 0))) + "g"
			action.disabled = true
		row.add_child(info)
		row.add_child(action)
		card.add_child(row)
		_goals_list.add_child(card)
		_goal_buttons[goal_id] = action

func _on_claim_daily_reward() -> void:
	var result := game_data.claim_daily_reward()
	if not bool(result.get("ok", false)):
		_show_toast("Already claimed today")
		return
	_show_toast("Day " + str(int(result.get("streak", 1))) + " reward: +" + str(int(result.get("gold", 0))) + "g")
	_update_gold_display()
	_refresh_daily_panel()
	_save_game()

func _on_claim_daily_goal(goal_id: String) -> void:
	var result := game_data.claim_daily_goal(goal_id)
	if not bool(result.get("ok", false)):
		_show_toast("Goal not ready")
		return
	_show_toast(str(result.get("name", "Goal")) + " +" + str(int(result.get("gold", 0))) + "g")
	_update_gold_display()
	_refresh_daily_panel()
	_save_game()

func _prompt_daily_reward() -> void:
	game_data.ensure_daily_state()
	if game_data.can_claim_daily_reward():
		_show_toast("Daily reward ready — open Progress")

func _setup_prestige_panel():
	var currency = game_data.calculate_prestige_currency()
	var text := "Prestige Level " + str(game_data.prestige_level) + "\n"
	text += "Stars stored: " + str(game_data.prestige_currency) + "\n"
	text += "Stars from a reset: " + str(currency) + "\n"
	text += "Need 100 stars to prestige. Each level boosts gold, growth, and bots."
	if game_data.can_prestige():
		text += "\nPrestige is ready."
	prestige_info.text = text

func _setup_check_update_button() -> void:
	if _check_update_button != null and is_instance_valid(_check_update_button):
		return
	_check_update_button = Button.new()
	_check_update_button.custom_minimum_size = Vector2(0, 40)
	_check_update_button.text = "Check for updates"
	_check_update_button.pressed.connect(_on_check_update_pressed)
	var insert_at := prestige_button.get_index() + 1
	progress_box.add_child(_check_update_button)
	progress_box.move_child(_check_update_button, insert_at)

func _setup_achievements_panel():
	_clear_children(achievement_list)
	var unlocked_count := 0
	for achievement_id in achievements:
		var achievement = achievements[achievement_id]
		var row := Label.new()
		if achievement.unlocked:
			row.text = "★  " + achievement.name
			row.add_theme_color_override("font_color", FarmTheme.GOLD_DEEP)
			unlocked_count += 1
		else:
			row.text = "☆  " + achievement.name + "  —  " + achievement.description
			row.add_theme_color_override("font_color", FarmTheme.MUTED)
		row.add_theme_font_size_override("font_size", 13)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		achievement_list.add_child(row)
	achievement_label.text = "Achievements  " + str(unlocked_count) + "/" + str(achievements.size())

func _update_prestige_button():
	if game_data.can_prestige():
		prestige_button.disabled = false
		prestige_button.text = "Prestige Reset"
	else:
		prestige_button.disabled = true
		prestige_button.text = "Need 100 prestige stars"

func _check_offline_progress():
	if game_data.last_save_time > 0:
		var result = game_data.calculate_offline_progress()
		if int(result.get("crops_harvested", 0)) > 0 or float(result.get("gold_earned", 0.0)) > 0.0:
			_show_offline_popup(result)
			_update_gold_display()
			call_deferred("_refresh_inventory_panel")
			_save_game()

func _show_offline_popup(result):
	var seconds := int(result.get("offline_seconds", 0))
	var time_text := _format_offline_duration(seconds)
	if bool(result.get("capped", false)):
		time_text += " (max offline)"
	var lines: PackedStringArray = ["Welcome back!", "You were away for " + time_text + "."]
	var crops_harvested := int(result.get("crops_harvested", 0))
	var crops_kept := int(result.get("crops_kept", 0))
	var gold_earned := float(result.get("gold_earned", 0.0))
	if crops_harvested > 0:
		lines.append("Robots harvested " + str(crops_harvested) + " crops.")
	if gold_earned > 0.0:
		lines.append("Seller bots banked " + _format_gold(gold_earned) + " gold.")
	elif crops_kept > 0:
		lines.append("Stored " + str(crops_kept) + " crops in your market inventory.")
	offline_popup.dialog_text = "\n".join(lines)
	offline_popup.popup_centered()

func _format_offline_duration(seconds: int) -> String:
	if seconds >= 3600:
		var hours := int(seconds / 3600)
		var minutes := int((seconds % 3600) / 60)
		if minutes > 0:
			return str(hours) + "h " + str(minutes) + "m"
		return str(hours) + " hours"
	return str(maxi(1, int(seconds / 60))) + " minutes"

func _show_toast(message: String):
	toast.text = message
	toast.visible = true
	toast_timer = 2.2

func _update_crop_growth(_delta):
	var current_time = Time.get_unix_time_from_system()
	var growth_multiplier = game_data.get_total_growth_multiplier()
	
	for x in game_data.grid_size.x:
		for y in game_data.grid_size.y:
			var plot_data = game_data.get_plot_data(Vector2i(x, y))
			if plot_data.is_empty() or not plot_data.get("unlocked", false):
				continue
			if plot_data.get("crop_type", null) != null and not plot_data.get("is_ready", false) \
					and plot_data.get("watered", false):
				var crop_data = game_data.crops[plot_data.crop_type]
				var elapsed = (current_time - plot_data.planted_time) * growth_multiplier
				var progress = elapsed / crop_data.growth_time
				if progress >= 1.0:
					plot_data.is_ready = true
					plot_data.growth_stage = crop_data.stages
					game_data.set_plot_data(Vector2i(x, y), plot_data)
				else:
					plot_data.growth_stage = int(progress * crop_data.stages)
					game_data.set_plot_data(Vector2i(x, y), plot_data)
				plot_nodes[x][y].update_visual(plot_data)

func _auto_robot_actions(delta):
	if not game_data.has_active_robots():
		return
	var robot_multiplier := _robot_multiplier()
	var harvester = game_data.robots.get("harvester")
	if harvester and harvester.owned and _robot_ready("harvester", delta) and game_data.can_spend_robot_energy(0.01):
		harvest_accumulator += delta * game_data.robot_work_speed("harvester") * robot_multiplier
		if harvest_accumulator >= 1.0:
			if game_data.spend_robot_energy():
				var ticks := int(floor(harvest_accumulator))
				_auto_harvest(ticks * game_data.robot_batch_size("harvester"))
				harvest_accumulator = fmod(harvest_accumulator, 1.0)
			else:
				harvest_accumulator = 0.0
	var planter = game_data.robots.get("planter")
	if planter and planter.owned and _robot_ready("planter", delta) and game_data.can_spend_robot_energy(0.01):
		plant_accumulator += delta * game_data.robot_work_speed("planter") * robot_multiplier
		if plant_accumulator >= 1.0:
			if game_data.spend_robot_energy():
				var ticks := int(floor(plant_accumulator))
				_auto_plant(ticks * game_data.robot_batch_size("planter"))
				plant_accumulator = fmod(plant_accumulator, 1.0)
			else:
				plant_accumulator = 0.0
	var processor = game_data.robots.get("processor")
	if processor and processor.owned and _robot_ready("processor", delta) and game_data.can_spend_robot_energy(0.01):
		process_accumulator += delta * game_data.robot_work_speed("processor") * robot_multiplier
		if process_accumulator >= 1.0:
			if game_data.spend_robot_energy():
				var ticks := int(floor(process_accumulator))
				_auto_process(ticks * game_data.robot_batch_size("processor"))
				process_accumulator = fmod(process_accumulator, 1.0)
			else:
				process_accumulator = 0.0
	var seller = game_data.robots.get("seller")
	if seller and seller.owned and _robot_ready("seller", delta) and game_data.can_spend_robot_energy(0.01):
		sell_accumulator += delta * game_data.robot_work_speed("seller") * robot_multiplier
		if sell_accumulator >= 1.0:
			if game_data.spend_robot_energy():
				var ticks := int(floor(sell_accumulator))
				_auto_sell(ticks * game_data.robot_batch_size("seller"))
				sell_accumulator = fmod(sell_accumulator, 1.0)
			else:
				sell_accumulator = 0.0

func _auto_harvest(harvest_count):
	for x in game_data.grid_size.x:
		for y in game_data.grid_size.y:
			if harvest_count <= 0:
				return
			var pos := Vector2i(x, y)
			var plot_data = game_data.get_plot_data(pos)
			if plot_data.get("crop_type", null) != null and plot_data.get("is_ready", false):
				var crop_type: String = plot_data.crop_type
				if game_data.harvest_crop(pos):
					harvest_count -= 1
					_show_robot_at(pos, 1.2)
					_spawn_harvest_popup(pos, game_data.last_harvest_gold_value(crop_type))
					plot_nodes[x][y].update_visual(game_data.get_plot_data(pos))
					_on_crops_changed()

func _auto_plant(plant_count):
	for x in game_data.grid_size.x:
		for y in game_data.grid_size.y:
			if plant_count <= 0:
				return
			var pos := Vector2i(x, y)
			var plot_data = game_data.get_plot_data(pos)
			if plot_data.get("unlocked", false) and plot_data.get("crop_type", null) == null:
				if game_data.plant_crop(pos, game_data.selected_crop):
					plant_count -= 1
					_show_robot_at(pos, 0.9)
					plot_nodes[x][y].update_visual(game_data.get_plot_data(pos))

func _auto_process(process_count):
	for product_id in game_data.products.keys():
		if process_count <= 0:
			break
		if game_data.process_product(product_id, 1):
			process_count -= 1

func _auto_sell(sell_count):
	for product_id in game_data.product_inventory.keys():
		if sell_count <= 0:
			break
		if game_data.product_inventory[product_id] > 0 and game_data.sell_product(product_id, 1):
			sell_count -= 1

func _update_ui():
	_update_gold_display()
	var gold_now := int(game_data.gold)
	if gold_now != last_plot_gold:
		last_plot_gold = gold_now
		_refresh_farm_visuals()
	if _inventory_signature() != last_inventory_signature:
		_refresh_inventory_panel()
	_setup_prestige_panel()
	_update_prestige_button()
	if current_tab == "progress":
		_refresh_daily_panel()

func _on_crops_changed():
	_refresh_crop_chips()
	_update_farm_hint()

func _on_plot_pressed(grid_pos: Vector2i):
	var plot_data = game_data.get_plot_data(grid_pos)
	if not game_data.is_plot_unlocked(grid_pos):
		var price := game_data.plot_unlock_cost()
		if game_data.unlock_plot(grid_pos):
			_refresh_farm_visuals()
			_show_toast("Plot unlocked")
		elif not game_data.is_plot_unlockable(grid_pos):
			_show_toast("Unlock a neighboring plot first")
		else:
			_show_toast("Need " + _format_gold(price - game_data.gold) + " more gold")
		return
	if plot_data.get("crop_type", null) == null:
		if game_data.plant_crop(grid_pos, game_data.selected_crop):
			plot_nodes[grid_pos.x][grid_pos.y].update_visual(game_data.get_plot_data(grid_pos))
		elif not game_data.is_crop_unlocked(game_data.selected_crop):
			_show_toast("Unlock this crop first")
		elif not game_data.can_spend_water():
			_show_toast("Need water to plant — wait for the well to refill")
		else:
			var cost = game_data.crops[game_data.selected_crop].cost
			_show_toast("Need " + _format_gold(cost) + " gold to plant")
			if game_data.should_offer_coin_rush() and coin_rush_cooldown <= 0.0:
				_offer_coin_rush()
	elif plot_data.get("is_ready", false):
		var crop_type: String = plot_data.crop_type
		if game_data.harvest_crop(grid_pos):
			_spawn_harvest_popup(grid_pos, game_data.last_harvest_gold_value(crop_type))
			plot_nodes[grid_pos.x][grid_pos.y].update_visual(game_data.get_plot_data(grid_pos))
			_on_crops_changed()
	else:
		_show_toast("Still growing...")

func _on_prestige_pressed():
	if game_data.can_prestige():
		var result = game_data.do_prestige()
		robot_warmups.clear()
		harvest_accumulator = 0.0
		plant_accumulator = 0.0
		process_accumulator = 0.0
		sell_accumulator = 0.0
		_setup_ui()
		_refresh_farm_visuals()
		_show_toast("Prestige level " + str(result.prestige_level))

func _refresh_farm_visuals():
	for x in game_data.grid_size.x:
		for y in game_data.grid_size.y:
			var pos := Vector2i(x, y)
			var plot_node = plot_nodes[x][y]
			plot_node.update_visual(game_data.get_plot_data(pos))
			plot_node.set_robot_visible(pos == active_robot_plot and robot_plot_timer > 0.0)

func _show_robot_at(grid_pos: Vector2i, seconds: float = 1.0):
	active_robot_plot = grid_pos
	robot_plot_timer = seconds
	if grid_pos.x >= 0 and grid_pos.y >= 0:
		plot_nodes[grid_pos.x][grid_pos.y].set_robot_visible(true)

func _clear_robot_marker():
	active_robot_plot = Vector2i(-1, -1)
	for column in plot_nodes:
		for plot_node in column:
			if plot_node:
				plot_node.set_robot_visible(false)

func _spawn_harvest_popup(grid_pos: Vector2i, gold_value: int):
	if gold_value <= 0:
		return
	var plot_node = plot_nodes[grid_pos.x][grid_pos.y]
	var label := Label.new()
	label.text = "+" + str(gold_value) + "g"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.35, 0.98, 0.45))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.18, 0.08, 0.9))
	label.add_theme_constant_override("outline_size", 3)
	label.position = plot_node.global_position + Vector2(4, -8)
	add_child(label)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 28.0, 0.9)
	tween.tween_property(label, "modulate:a", 0.0, 0.9)
	tween.chain().tween_callback(label.queue_free)

func _check_achievements():
	for achievement_id in achievements:
		var achievement = achievements[achievement_id]
		if achievement.unlocked:
			continue
		var requirement_met := false
		match achievement.requirement_type:
			"harvest_count":
				requirement_met = game_data.total_harvested >= achievement.requirement_value
			"gold_earned":
				requirement_met = game_data.total_gold_earned >= achievement.requirement_value
			"robot_owned":
				var robot_count := 0
				for robot in game_data.robots.values():
					if robot.owned:
						robot_count += 1
				requirement_met = robot_count >= achievement.requirement_value
			"prestige_level":
				requirement_met = game_data.prestige_level >= achievement.requirement_value
			"crops_unlocked":
				requirement_met = game_data.unlocked_crops.size() >= achievement.requirement_value
		if requirement_met:
			achievement.unlocked = true
			_setup_achievements_panel()
			_show_toast("Achievement: " + achievement.name)

func _save_game():
	game_data.last_save_time = Time.get_unix_time_from_system()
	var save_data := _build_save_dict()
	_write_local_save(save_data)
	_loaded_save_time = int(save_data.get("last_save_time", 0))
	if save_vault != null and save_vault.is_available():
		save_vault.write_save(JSON.stringify(save_data))

func _build_save_dict() -> Dictionary:
	var achievements_save = {}
	for achievement_id in achievements:
		achievements_save[achievement_id] = {"unlocked": achievements[achievement_id].unlocked}
	return {
		"gold": game_data.gold,
		"farm_grid": game_data.farm_grid,
		"crop_inventory": game_data.crop_inventory,
		"product_inventory": game_data.product_inventory,
		"robots": game_data.robots,
		"prestige_level": game_data.prestige_level,
		"prestige_currency": game_data.prestige_currency,
		"permanent_upgrades": game_data.permanent_upgrades,
		"farm_upgrades": game_data.farm_upgrades,
		"unlocked_crops": game_data.unlocked_crops,
		"crop_harvests": game_data.crop_harvests,
		"selected_crop": game_data.selected_crop,
		"total_harvested": game_data.total_harvested,
		"total_gold_earned": game_data.total_gold_earned,
		"play_time": game_data.play_time,
		"last_save_time": game_data.last_save_time,
		"water": game_data.water,
		"robot_energy": game_data.robot_energy,
		"farmer_xp": game_data.farmer_xp,
		"login_streak": game_data.login_streak,
		"last_login_day": game_data.last_login_day,
		"daily_reward_claimed": game_data.daily_reward_claimed,
		"daily_goal_day": game_data.daily_goal_day,
		"daily_goals": game_data.daily_goals,
		"economy_version": 4,
		"achievements": achievements_save
	}

func _write_local_save(save_data: Dictionary) -> void:
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func _read_local_save_dict() -> Dictionary:
	var file = FileAccess.open("user://save_data.json", FileAccess.READ)
	if not file:
		return {}
	var json_string = file.get_as_text()
	file.close()
	return _parse_save_dict(json_string)

func _parse_save_dict(json_string: String) -> Dictionary:
	if json_string.is_empty():
		return {}
	var json = JSON.new()
	if json.parse(json_string) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {}
	return json.data

func _apply_save_dict(save_data: Dictionary) -> void:
	game_data.gold = save_data.get("gold", 50.0)
	var saved_grid = save_data.get("farm_grid", [])
	if _is_valid_farm_grid(saved_grid):
		game_data.farm_grid = saved_grid
	game_data.crop_inventory = _merge_dictionary(game_data.crop_inventory, save_data.get("crop_inventory", {}))
	game_data.product_inventory = _merge_dictionary(game_data.product_inventory, save_data.get("product_inventory", {}))
	game_data.robots = _merge_dictionary(game_data.robots, save_data.get("robots", {}))
	game_data.normalize_robots()
	game_data.prestige_level = save_data.get("prestige_level", 0)
	game_data.prestige_currency = save_data.get("prestige_currency", 0)
	game_data.permanent_upgrades = _merge_dictionary(game_data.permanent_upgrades, save_data.get("permanent_upgrades", {}))
	game_data.farm_upgrades = _merge_dictionary(game_data.farm_upgrades, save_data.get("farm_upgrades", {}))
	game_data.unlocked_crops = save_data.get("unlocked_crops", ["wheat"])
	game_data.crop_harvests = _merge_dictionary(game_data.crop_harvests, save_data.get("crop_harvests", {}))
	game_data.selected_crop = save_data.get("selected_crop", "wheat")
	game_data.total_harvested = save_data.get("total_harvested", 0)
	game_data.total_gold_earned = save_data.get("total_gold_earned", 0.0)
	game_data.play_time = save_data.get("play_time", 0.0)
	game_data.last_save_time = save_data.get("last_save_time", 0)
	game_data.water = float(save_data.get("water", GameData.WATER_MAX))
	game_data.robot_energy = float(save_data.get("robot_energy", GameData.ROBOT_ENERGY_MAX))
	game_data.farmer_xp = int(save_data.get("farmer_xp", 0))
	game_data.login_streak = int(save_data.get("login_streak", 0))
	game_data.last_login_day = int(save_data.get("last_login_day", 0))
	game_data.daily_reward_claimed = bool(save_data.get("daily_reward_claimed", false))
	game_data.daily_goal_day = int(save_data.get("daily_goal_day", 0))
	game_data.daily_goals = save_data.get("daily_goals", {})
	if int(save_data.get("economy_version", 0)) < 1:
		game_data.unlocked_crops = ["wheat"]
		game_data.selected_crop = "wheat"
	game_data.update_prestige_multipliers()
	game_data.normalize_crops()
	game_data.normalize_plots(int(save_data.get("economy_version", 0)) < 2)
	if int(save_data.get("economy_version", 0)) < 3:
		game_data.water = GameData.WATER_MAX
		game_data.robot_energy = GameData.ROBOT_ENERGY_MAX
	game_data.ensure_daily_state()
	var achievements_save = save_data.get("achievements", {})
	for achievement_id in achievements_save:
		if achievements.has(achievement_id):
			achievements[achievement_id].unlocked = achievements_save[achievement_id].get("unlocked", false)
	_loaded_save_time = int(save_data.get("last_save_time", 0))

func _restore_cloud_save() -> void:
	if OS.get_name() != "Android" or save_vault == null or not save_vault.is_available():
		return
	save_vault.prepare_restore()
	save_vault.read_save()

func _on_cloud_save_read(ok: bool, json_text: String, exists: bool) -> void:
	if not ok:
		if exists:
			save_vault.prepare_restore()
		return
	var cloud_data := _parse_save_dict(json_text)
	if cloud_data.is_empty():
		return
	var cloud_time := int(cloud_data.get("last_save_time", 0))
	if cloud_time <= _loaded_save_time:
		return
	var had_local_save := _loaded_save_time > 0
	_apply_save_dict(cloud_data)
	_write_local_save(cloud_data)
	_refresh_after_cloud_restore()
	if not had_local_save:
		_show_toast("Farm restored from cloud save")

func _refresh_after_cloud_restore() -> void:
	_refresh_farm_visuals()
	_setup_crop_selector()
	_setup_robot_panel()
	_setup_upgrades_panel()
	_refresh_inventory_panel()
	_setup_prestige_panel()
	_setup_achievements_panel()
	_setup_daily_panel()
	_update_gold_display()

func _merge_dictionary(base: Dictionary, incoming: Dictionary) -> Dictionary:
	var merged = base.duplicate(true)
	for key in incoming:
		if merged.has(key) and merged[key] is Dictionary and incoming[key] is Dictionary:
			merged[key] = _merge_dictionary(merged[key], incoming[key])
		else:
			merged[key] = incoming[key]
	return merged

func _is_valid_farm_grid(grid) -> bool:
	if typeof(grid) != TYPE_ARRAY or grid.size() != game_data.grid_size.x:
		return false
	for x in game_data.grid_size.x:
		if typeof(grid[x]) != TYPE_ARRAY or grid[x].size() != game_data.grid_size.y:
			return false
	return true

func _load_game():
	var save_data := _read_local_save_dict()
	if not save_data.is_empty():
		_apply_save_dict(save_data)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()
		get_tree().quit()
