extends RefCounted

# Core game data structure
class_name GameData

# Player resources
var gold: float = 50.0
var gems: int = 0

# Farm grid data
var farm_grid: Array = []  # 2D array of plot data
var grid_size: Vector2i = Vector2i(6, 8)  # 6x8 grid for mobile

# Crop definitions, ordered from starter to luxury.
# Higher tiers grow slower, cost more to plant, and pay more per harvest.
const CROP_ORDER: Array[String] = [
	"wheat", "cabbage", "potato", "carrot", "onion",
	"strawberry", "tomato", "pepper", "sunflower", "corn",
	"grape", "apple", "pumpkin", "watermelon", "coffee"
]

var crops: Dictionary = {
	"wheat": {
		"name": "Wheat",
		"tier": 1,
		"growth_time": 8.0,
		"sell_price": 8,
		"cost": 5,
		"unlock_harvest": 0,
		"unlock_cost": 0,
		"color": Color.YELLOW,
		"stages": 3
	},
	"cabbage": {
		"name": "Cabbage",
		"tier": 2,
		"growth_time": 14.0,
		"sell_price": 18,
		"cost": 12,
		"unlock_harvest": 12,
		"unlock_cost": 35,
		"color": Color(0.35, 0.72, 0.32),
		"stages": 3
	},
	"potato": {
		"name": "Potato",
		"tier": 3,
		"growth_time": 22.0,
		"sell_price": 34,
		"cost": 22,
		"unlock_harvest": 16,
		"unlock_cost": 70,
		"color": Color(0.62, 0.46, 0.24),
		"stages": 4
	},
	"carrot": {
		"name": "Carrot",
		"tier": 4,
		"growth_time": 32.0,
		"sell_price": 60,
		"cost": 38,
		"unlock_harvest": 18,
		"unlock_cost": 140,
		"color": Color.ORANGE,
		"stages": 4
	},
	"onion": {
		"name": "Onion",
		"tier": 5,
		"growth_time": 44.0,
		"sell_price": 98,
		"cost": 60,
		"unlock_harvest": 20,
		"unlock_cost": 250,
		"color": Color(0.62, 0.32, 0.72),
		"stages": 4
	},
	"strawberry": {
		"name": "Strawberry",
		"tier": 6,
		"growth_time": 58.0,
		"sell_price": 160,
		"cost": 95,
		"unlock_harvest": 22,
		"unlock_cost": 420,
		"color": Color(0.90, 0.16, 0.22),
		"stages": 4
	},
	"tomato": {
		"name": "Tomato",
		"tier": 7,
		"growth_time": 75.0,
		"sell_price": 260,
		"cost": 150,
		"unlock_harvest": 24,
		"unlock_cost": 700,
		"color": Color.RED,
		"stages": 5
	},
	"pepper": {
		"name": "Pepper",
		"tier": 8,
		"growth_time": 95.0,
		"sell_price": 410,
		"cost": 230,
		"unlock_harvest": 26,
		"unlock_cost": 1100,
		"color": Color(0.88, 0.12, 0.14),
		"stages": 5
	},
	"sunflower": {
		"name": "Sunflower",
		"tier": 9,
		"growth_time": 120.0,
		"sell_price": 640,
		"cost": 350,
		"unlock_harvest": 28,
		"unlock_cost": 1800,
		"color": Color(0.98, 0.82, 0.16),
		"stages": 5
	},
	"corn": {
		"name": "Corn",
		"tier": 10,
		"growth_time": 150.0,
		"sell_price": 1000,
		"cost": 540,
		"unlock_harvest": 30,
		"unlock_cost": 2800,
		"color": Color.YELLOW_GREEN,
		"stages": 6
	},
	"grape": {
		"name": "Grape",
		"tier": 11,
		"growth_time": 185.0,
		"sell_price": 1560,
		"cost": 820,
		"unlock_harvest": 32,
		"unlock_cost": 4500,
		"color": Color(0.48, 0.18, 0.58),
		"stages": 6
	},
	"apple": {
		"name": "Apple",
		"tier": 12,
		"growth_time": 225.0,
		"sell_price": 2450,
		"cost": 1250,
		"unlock_harvest": 34,
		"unlock_cost": 7000,
		"color": Color(0.86, 0.14, 0.16),
		"stages": 6
	},
	"pumpkin": {
		"name": "Pumpkin",
		"tier": 13,
		"growth_time": 270.0,
		"sell_price": 3800,
		"cost": 1900,
		"unlock_harvest": 36,
		"unlock_cost": 11000,
		"color": Color.ORANGE_RED,
		"stages": 8
	},
	"watermelon": {
		"name": "Watermelon",
		"tier": 14,
		"growth_time": 320.0,
		"sell_price": 5900,
		"cost": 2900,
		"unlock_harvest": 38,
		"unlock_cost": 17000,
		"color": Color(0.18, 0.62, 0.28),
		"stages": 7
	},
	"coffee": {
		"name": "Coffee",
		"tier": 15,
		"growth_time": 380.0,
		"sell_price": 9200,
		"cost": 4400,
		"unlock_harvest": 40,
		"unlock_cost": 26000,
		"color": Color(0.45, 0.22, 0.10),
		"stages": 7
	}
}

# Product definitions (processed from crops)
var products: Dictionary = {
	"flour": {
		"name": "Flour",
		"input_crop": "wheat",
		"input_amount": 2,
		"process_time": 12.0,
		"sell_price": 28,
		"color": Color.WHITE
	},
	"carrot_cake": {
		"name": "Carrot Cake",
		"input_crop": "carrot",
		"input_amount": 3,
		"process_time": 28.0,
		"sell_price": 310,
		"color": Color.ORANGE
	},
	"tomato_sauce": {
		"name": "Tomato Sauce",
		"input_crop": "tomato",
		"input_amount": 2,
		"process_time": 42.0,
		"sell_price": 900,
		"color": Color.DARK_RED
	},
	"popcorn": {
		"name": "Popcorn",
		"input_crop": "corn",
		"input_amount": 1,
		"process_time": 40.0,
		"sell_price": 1750,
		"color": Color.YELLOW
	},
	"pumpkin_pie": {
		"name": "Pumpkin Pie",
		"input_crop": "pumpkin",
		"input_amount": 2,
		"process_time": 90.0,
		"sell_price": 13500,
		"color": Color.ORANGE
	},
	"slaw": {
		"name": "Slaw",
		"input_crop": "cabbage",
		"input_amount": 2,
		"process_time": 16.0,
		"sell_price": 62,
		"color": Color(0.70, 0.85, 0.45)
	},
	"fries": {
		"name": "Fries",
		"input_crop": "potato",
		"input_amount": 2,
		"process_time": 20.0,
		"sell_price": 115,
		"color": Color(0.96, 0.78, 0.28)
	},
	"onion_rings": {
		"name": "Onion Rings",
		"input_crop": "onion",
		"input_amount": 2,
		"process_time": 32.0,
		"sell_price": 340,
		"color": Color(0.90, 0.70, 0.28)
	},
	"jam": {
		"name": "Jam",
		"input_crop": "strawberry",
		"input_amount": 2,
		"process_time": 38.0,
		"sell_price": 560,
		"color": Color(0.78, 0.10, 0.22)
	},
	"hot_sauce": {
		"name": "Hot Sauce",
		"input_crop": "pepper",
		"input_amount": 2,
		"process_time": 48.0,
		"sell_price": 1450,
		"color": Color(0.80, 0.10, 0.10)
	},
	"oil": {
		"name": "Oil",
		"input_crop": "sunflower",
		"input_amount": 2,
		"process_time": 55.0,
		"sell_price": 2250,
		"color": Color(0.96, 0.82, 0.28)
	},
	"wine": {
		"name": "Wine",
		"input_crop": "grape",
		"input_amount": 2,
		"process_time": 70.0,
		"sell_price": 5600,
		"color": Color(0.42, 0.08, 0.22)
	},
	"cider": {
		"name": "Cider",
		"input_crop": "apple",
		"input_amount": 2,
		"process_time": 75.0,
		"sell_price": 8600,
		"color": Color(0.78, 0.28, 0.14)
	},
	"melon_juice": {
		"name": "Melon Juice",
		"input_crop": "watermelon",
		"input_amount": 1,
		"process_time": 60.0,
		"sell_price": 10000,
		"color": Color(0.92, 0.28, 0.38)
	},
	"coffee_cup": {
		"name": "Coffee",
		"input_crop": "coffee",
		"input_amount": 2,
		"process_time": 100.0,
		"sell_price": 32000,
		"color": Color(0.32, 0.18, 0.10)
	}
}

# Robot helpers
var robots: Dictionary = {
	"harvester": {
		"name": "Harvester Bot",
		"cost": 500,
		"speed_multiplier": 2.0,
		"auto_harvest": true,
		"owned": false,
		"level": 0
	},
	"planter": {
		"name": "Planter Bot",
		"cost": 750,
		"speed_multiplier": 1.5,
		"auto_plant": true,
		"owned": false,
		"level": 0
	},
	"processor": {
		"name": "Processor Bot",
		"cost": 1000,
		"speed_multiplier": 2.0,
		"auto_process": true,
		"owned": false,
		"level": 0
	},
	"seller": {
		"name": "Seller Bot",
		"cost": 1500,
		"speed_multiplier": 1.5,
		"auto_sell": true,
		"owned": false,
		"level": 0
	}
}

const ROBOT_MAX_LEVEL: int = 20

func get_robot_level(robot: Dictionary) -> int:
	var level := int(robot.get("level", 0))
	if robot.get("owned", false) and level < 1:
		return 1
	return level

func robot_next_cost(robot_id: String) -> int:
	var robot = robots.get(robot_id)
	if robot == null:
		return 0
	var level := get_robot_level(robot)
	if level <= 0:
		return int(robot.cost)
	return int(round(float(robot.cost) * pow(1.5, float(level))))

func robot_is_maxed(robot_id: String) -> bool:
	return get_robot_level(robots[robot_id]) >= ROBOT_MAX_LEVEL

func robot_work_speed_for_level(robot_id: String, level: int) -> float:
	var robot = robots[robot_id]
	var safe_level := maxi(1, level)
	return float(robot.speed_multiplier) * (1.0 + float(safe_level - 1) * 0.25)

func robot_batch_size_for_level(level: int) -> int:
	return 1 + int((maxi(1, level) - 1) / 5)

func robot_work_speed(robot_id: String) -> float:
	return robot_work_speed_for_level(robot_id, get_robot_level(robots[robot_id]))

func robot_batch_size(robot_id: String) -> int:
	return robot_batch_size_for_level(get_robot_level(robots[robot_id]))

func upgrade_robot(robot_id: String) -> bool:
	var robot = robots.get(robot_id)
	if robot == null or robot_is_maxed(robot_id):
		return false
	var price := robot_next_cost(robot_id)
	if gold < price:
		return false
	gold -= price
	var level := get_robot_level(robot)
	robot.owned = true
	robot.level = level + 1
	return true

func normalize_robots():
	for robot_id in robots:
		var robot = robots[robot_id]
		if robot.get("owned", false) and int(robot.get("level", 0)) < 1:
			robot.level = 1
		if not robot.get("owned", false):
			robot.level = 0

# Prestige system
var prestige_level: int = 0
var prestige_currency: int = 0
var prestige_multipliers: Dictionary = {
	"gold_multiplier": 1.0,
	"growth_speed": 1.0,
	"robot_speed": 1.0
}

# Permanent upgrades (bought with prestige currency)
var permanent_upgrades: Dictionary = {
	"gold_boost": {
		"name": "Gold Boost",
		"description": "+10% gold from all sales",
		"cost": 10,
		"max_level": 10,
		"current_level": 0
	},
	"growth_boost": {
		"name": "Growth Boost",
		"description": "+5% crop growth speed",
		"cost": 15,
		"max_level": 10,
		"current_level": 0
	},
	"robot_efficiency": {
		"name": "Robot Efficiency",
		"description": "+10% robot speed",
		"cost": 20,
		"max_level": 10,
		"current_level": 0
	}
}

# Helper functions for upgrade effects
func get_gold_boost_effect(level: int) -> float:
	return 1.0 + (level * 0.1)

func get_growth_boost_effect(level: int) -> float:
	return 1.0 + (level * 0.05)

func get_robot_efficiency_effect(level: int) -> float:
	return 1.0 + (level * 0.1)

# Inventory
var crop_inventory: Dictionary = {}  # crop_type -> amount
var product_inventory: Dictionary = {}  # product_type -> amount
var crop_harvests: Dictionary = {}  # crop_type -> lifetime harvests this prestige

# Offline progress
var last_save_time: int = 0
var offline_earnings: float = 0.0

# Selected crop for planting
var selected_crop: String = "wheat"

# Unlocked crops
var unlocked_crops: Array = ["wheat"]

# Statistics
var total_harvested: int = 0
var total_gold_earned: float = 0.0
var play_time: float = 0.0

func _init():
	_initialize_farm_grid()
	_initialize_inventory()

const START_PLOT_SIZE: Vector2i = Vector2i(4, 2)
const PLOT_UNLOCK_BASE: int = 20
const PLOT_UNLOCK_SCALE: float = 1.2

func is_starting_plot(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.y >= 0 and grid_pos.x < START_PLOT_SIZE.x and grid_pos.y < START_PLOT_SIZE.y

func _blank_plot(unlocked: bool) -> Dictionary:
	return {
		"crop_type": null,
		"planted_time": 0.0,
		"growth_stage": 0,
		"is_ready": false,
		"unlocked": unlocked
	}

func _initialize_farm_grid():
	farm_grid.clear()
	for x in grid_size.x:
		var column = []
		for y in grid_size.y:
			column.append(_blank_plot(is_starting_plot(Vector2i(x, y))))
		farm_grid.append(column)

func _initialize_inventory():
	for crop in crops:
		crop_inventory[crop] = 0
		crop_harvests[crop] = 0
	for product in products:
		product_inventory[product] = 0

func get_plot_data(grid_pos: Vector2i) -> Dictionary:
	if grid_pos.x >= 0 and grid_pos.x < farm_grid.size():
		var column = farm_grid[grid_pos.x]
		if typeof(column) == TYPE_ARRAY and grid_pos.y >= 0 and grid_pos.y < column.size():
			var plot = column[grid_pos.y]
			if typeof(plot) == TYPE_DICTIONARY:
				return plot
	return {}

func set_plot_data(grid_pos: Vector2i, data: Dictionary):
	if grid_pos.x >= 0 and grid_pos.x < grid_size.x and grid_pos.y >= 0 and grid_pos.y < grid_size.y:
		farm_grid[grid_pos.x][grid_pos.y] = data

func is_plot_unlocked(grid_pos: Vector2i) -> bool:
	return bool(get_plot_data(grid_pos).get("unlocked", false))

func unlocked_plot_count() -> int:
	var count := 0
	for x in grid_size.x:
		for y in grid_size.y:
			if is_plot_unlocked(Vector2i(x, y)):
				count += 1
	return count

func total_plot_count() -> int:
	return grid_size.x * grid_size.y

func plot_unlock_cost() -> int:
	var extra := maxi(0, unlocked_plot_count() - START_PLOT_SIZE.x * START_PLOT_SIZE.y)
	return int(round(float(PLOT_UNLOCK_BASE) * pow(PLOT_UNLOCK_SCALE, float(extra))))

func is_adjacent_to_unlocked(grid_pos: Vector2i) -> bool:
	var neighbors := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for offset in neighbors:
		if is_plot_unlocked(grid_pos + offset):
			return true
	return false

func is_plot_unlockable(grid_pos: Vector2i) -> bool:
	if is_plot_unlocked(grid_pos) or unlocked_plot_count() >= total_plot_count():
		return false
	return is_adjacent_to_unlocked(grid_pos)

func unlock_plot(grid_pos: Vector2i) -> bool:
	var plot = get_plot_data(grid_pos)
	if plot.is_empty() or not is_plot_unlockable(grid_pos):
		return false
	var price := plot_unlock_cost()
	if gold < price:
		return false
	gold -= price
	plot.unlocked = true
	plot.crop_type = null
	plot.planted_time = 0.0
	plot.growth_stage = 0
	plot.is_ready = false
	return true

func normalize_plots(force_starter_layout: bool = false):
	for x in grid_size.x:
		for y in grid_size.y:
			var pos := Vector2i(x, y)
			var plot = get_plot_data(pos)
			if plot.is_empty():
				set_plot_data(pos, _blank_plot(is_starting_plot(pos)))
				continue
			if force_starter_layout or not plot.has("unlocked"):
				plot.unlocked = is_starting_plot(pos) or plot.get("crop_type", null) != null
			if not plot.get("unlocked", false):
				plot.crop_type = null
				plot.planted_time = 0.0
				plot.growth_stage = 0
				plot.is_ready = false

func plant_crop(grid_pos: Vector2i, crop_type: String) -> bool:
	var crop_data = crops.get(crop_type)
	if not crop_data:
		return false
	if not is_crop_unlocked(crop_type):
		return false
	if not is_plot_unlocked(grid_pos):
		return false
	
	if gold < crop_data.cost:
		return false
	
	var plot = get_plot_data(grid_pos)
	if plot.is_empty() or plot.get("crop_type", null) != null:
		return false
	
	gold -= crop_data.cost
	plot.crop_type = crop_type
	plot.planted_time = Time.get_unix_time_from_system()
	plot.growth_stage = 0
	plot.is_ready = false
	plot.unlocked = true
	return true

func harvest_crop(grid_pos: Vector2i) -> bool:
	var plot = get_plot_data(grid_pos)
	if not plot.get("unlocked", false):
		return false
	if plot.get("crop_type", null) == null or not plot.get("is_ready", false):
		return false
	
	crop_inventory[plot.crop_type] += 1
	crop_harvests[plot.crop_type] = int(crop_harvests.get(plot.crop_type, 0)) + 1
	total_harvested += 1
	
	plot.crop_type = null
	plot.planted_time = 0.0
	plot.growth_stage = 0
	plot.is_ready = false
	plot.unlocked = true
	return true

func process_product(product_type: String, amount: int = 1) -> bool:
	var product_data = products.get(product_type)
	if not product_data:
		return false
	
	var input_crop = product_data.input_crop
	if int(crop_inventory.get(input_crop, 0)) < product_data.input_amount * amount:
		return false
	
	crop_inventory[input_crop] -= product_data.input_amount * amount
	product_inventory[product_type] += amount
	return true

func sell_crop(crop_type: String, amount: int = 1) -> bool:
	if int(crop_inventory.get(crop_type, 0)) < amount:
		return false
	
	var crop_data = crops[crop_type]
	var multiplier = prestige_multipliers.gold_multiplier * get_gold_boost_effect(permanent_upgrades.gold_boost.current_level)
	var earnings = crop_data.sell_price * amount * multiplier
	
	crop_inventory[crop_type] -= amount
	gold += earnings
	total_gold_earned += earnings
	return true

func sell_product(product_type: String, amount: int = 1) -> bool:
	if int(product_inventory.get(product_type, 0)) < amount:
		return false
	
	var product_data = products[product_type]
	var multiplier = prestige_multipliers.gold_multiplier * get_gold_boost_effect(permanent_upgrades.gold_boost.current_level)
	var earnings = product_data.sell_price * amount * multiplier
	
	product_inventory[product_type] -= amount
	gold += earnings
	total_gold_earned += earnings
	return true

func calculate_prestige_currency() -> int:
	return int(floor(total_gold_earned / 1000.0))

func can_prestige() -> bool:
	return calculate_prestige_currency() >= 100  # Minimum 100 prestige currency

func update_prestige_multipliers():
	prestige_multipliers.gold_multiplier = 1.0 + (prestige_level * 0.1)
	prestige_multipliers.growth_speed = 1.0 + (prestige_level * 0.05)
	prestige_multipliers.robot_speed = 1.0 + (prestige_level * 0.05)

func is_crop_unlocked(crop_id: String) -> bool:
	return unlocked_crops.has(crop_id)

func previous_crop(crop_id: String) -> String:
	var index := CROP_ORDER.find(crop_id)
	if index <= 0:
		return ""
	return CROP_ORDER[index - 1]

func next_unlock_crop() -> String:
	for crop_id in CROP_ORDER:
		if not unlocked_crops.has(crop_id):
			return crop_id
	return ""

func get_crop_harvests(crop_id: String) -> int:
	return int(crop_harvests.get(crop_id, 0))

func unlock_block_reason(crop_id: String) -> String:
	if is_crop_unlocked(crop_id):
		return ""
	if next_unlock_crop() != crop_id:
		var needed := next_unlock_crop()
		if needed == "":
			return "All crops unlocked"
		return "Unlock " + crops[needed].name + " first"
	var crop = crops[crop_id]
	var prev_id := previous_crop(crop_id)
	if prev_id != "":
		var needed_count := int(crop.unlock_harvest)
		var have := get_crop_harvests(prev_id)
		if have < needed_count:
			return "Harvest " + str(needed_count - have) + " more " + crops[prev_id].name
	var price := int(crop.unlock_cost)
	if gold < price:
		return "Need " + str(price - int(gold)) + " more gold"
	return ""

func is_unlock_harvest_ready(crop_id: String) -> bool:
	if is_crop_unlocked(crop_id) or next_unlock_crop() != crop_id:
		return false
	var prev_id := previous_crop(crop_id)
	if prev_id == "":
		return true
	return get_crop_harvests(prev_id) >= int(crops[crop_id].unlock_harvest)

func can_unlock_crop(crop_id: String) -> bool:
	return unlock_block_reason(crop_id) == "" and not is_crop_unlocked(crop_id) and next_unlock_crop() == crop_id

func unlock_crop(crop_id: String) -> bool:
	if is_crop_unlocked(crop_id):
		return false
	if next_unlock_crop() != crop_id:
		return false
	var reason := unlock_block_reason(crop_id)
	if reason != "":
		return false
	var price := int(crops[crop_id].unlock_cost)
	if gold < price:
		return false
	gold -= price
	unlocked_crops.append(crop_id)
	return true

func normalize_crops():
	if not unlocked_crops.has("wheat"):
		unlocked_crops.insert(0, "wheat")
	for crop_id in crops:
		if not crop_harvests.has(crop_id):
			crop_harvests[crop_id] = 0
		if not crop_inventory.has(crop_id):
			crop_inventory[crop_id] = 0
	if not is_crop_unlocked(selected_crop):
		selected_crop = "wheat"

func update_unlocked_crops() -> bool:
	normalize_crops()
	return false

func do_prestige() -> Dictionary:
	var earned_currency = calculate_prestige_currency()
	
	prestige_currency += earned_currency
	prestige_level += 1
	
	# Reset progress but keep permanent upgrades
	gold = 50
	_initialize_farm_grid()
	_initialize_inventory()
	
	update_prestige_multipliers()
	
	# Reset robots
	for robot in robots:
		robots[robot].owned = false
		robots[robot].level = 0
	
	# Reset unlocked crops
	unlocked_crops = ["wheat"]
	
	# Reset selected crop
	selected_crop = "wheat"
	
	return {
		"prestige_level": prestige_level,
		"earned_currency": earned_currency,
		"total_currency": prestige_currency
	}

func calculate_offline_progress() -> Dictionary:
	var current_time = Time.get_unix_time_from_system()
	var offline_seconds = current_time - last_save_time
	
	if offline_seconds <= 0:
		return {"gold_earned": 0.0, "crops_harvested": 0}
	
	# Simple offline calculation based on auto-harvest bots
	var harvest_bot = robots.get("harvester")
	var auto_harvest_rate = 0.0
	
	if harvest_bot and harvest_bot.owned:
		auto_harvest_rate = robot_work_speed("harvester") * float(robot_batch_size("harvester")) * prestige_multipliers.robot_speed * get_robot_efficiency_effect(permanent_upgrades.robot_efficiency.current_level)
	
	var crops_harvested = int(floor(auto_harvest_rate * offline_seconds))
	var gold_earned = 0.0
	
	if crops_harvested > 0:
		# Assume wheat for offline calculation
		var wheat_data = crops["wheat"]
		var multiplier = prestige_multipliers.gold_multiplier * get_gold_boost_effect(permanent_upgrades.gold_boost.current_level)
		gold_earned = wheat_data.sell_price * crops_harvested * multiplier
		crop_inventory["wheat"] += crops_harvested
		crop_harvests["wheat"] = int(crop_harvests.get("wheat", 0)) + crops_harvested
		total_harvested += crops_harvested
		total_gold_earned += gold_earned
	
	offline_earnings = gold_earned
	
	return {
		"gold_earned": gold_earned,
		"crops_harvested": crops_harvested,
		"offline_seconds": offline_seconds
	}