extends SceneTree

# Simple test script to verify game functionality
# Run with: godot --headless -s res://test_game.gd

func _init():
	print("=== Micro Farm Manager Test ===")
	print("Testing game data initialization...")
	
	var game_data = GameData.new()
	
	# Test basic game data
	assert(game_data.gold == 50.0, "Gold should start at 50")
	assert(game_data.grid_size == Vector2i(6, 8), "Grid size should be 6x8")
	assert(game_data.crops.has("wheat"), "Wheat crop should exist")
	assert(game_data.robots.has("harvester"), "Harvester robot should exist")
	
	print("✓ Game data initialization passed")
	
	# Test crop planting
	var test_pos = Vector2i(0, 0)
	game_data.gold = 100  # Give some gold
	assert(game_data.plant_crop(test_pos, "wheat"), "Should be able to plant wheat")
	assert(game_data.gold == 95, "Gold should be reduced by crop cost")
	assert(game_data.water == GameData.WATER_MAX - GameData.WATER_PLANT_COST, "Planting should spend water")
	var planted_plot = game_data.get_plot_data(test_pos)
	assert(planted_plot.get("watered", false), "Planted plot should be watered")
	
	game_data.water = 0
	assert(not game_data.plant_crop(Vector2i(1, 0), "wheat"), "Should not plant without water")
	game_data.water = GameData.WATER_MAX
	
	print("✓ Crop planting passed")
	
	# Test crop harvesting (make it ready for testing)
	var plot_data = game_data.get_plot_data(test_pos)
	plot_data.is_ready = true
	game_data.set_plot_data(test_pos, plot_data)
	
	assert(game_data.harvest_crop(test_pos), "Should be able to harvest ready crop")
	assert(game_data.crop_inventory["wheat"] == 1, "Should have 1 wheat in inventory")
	assert(game_data.farmer_xp == 1, "Harvest should grant farmer XP")
	
	print("✓ Crop harvesting passed")
	
	game_data.robot_energy = 0
	assert(not game_data.spend_robot_energy(), "Robot energy should block at zero")
	game_data.robot_energy = GameData.ROBOT_ENERGY_MAX
	assert(game_data.spend_robot_energy(), "Robot energy should spend when available")
	game_data.regen_resources(1.0)
	assert(game_data.water > 0, "Water should regenerate over time")
	
	print("✓ Water and robot energy passed")
	
	# Test selling
	assert(game_data.sell_crop("wheat", 1), "Should be able to sell wheat")
	assert(game_data.crop_inventory["wheat"] == 0, "Wheat should be removed from inventory")
	assert(game_data.gold > 95, "Gold should increase after selling")
	
	print("✓ Crop selling passed")
	
	game_data.gold = 3
	assert(game_data.should_offer_coin_rush(), "Coin rush when broke with nothing to sell")
	game_data.crop_inventory["wheat"] = 2
	assert(not game_data.should_offer_coin_rush(), "No coin rush while crops can be sold")
	game_data.crop_inventory["wheat"] = 0
	game_data.gold = 100
	assert(game_data.plant_crop(Vector2i(2, 0), "wheat"), "Plant wheat for ready-crop test")
	var ready_plot = game_data.get_plot_data(Vector2i(2, 0))
	ready_plot.is_ready = true
	game_data.set_plot_data(Vector2i(2, 0), ready_plot)
	game_data.gold = 3
	assert(not game_data.should_offer_coin_rush(), "No coin rush while harvests are ready")
	
	print("✓ Coin rush gating passed")
	
	# Test product processing
	game_data.crop_inventory["wheat"] = 2
	assert(game_data.process_product("flour", 1), "Should be able to process flour")
	assert(game_data.crop_inventory["wheat"] == 0, "Wheat should be consumed")
	assert(game_data.product_inventory["flour"] == 1, "Should have 1 flour")
	
	print("✓ Product processing passed")
	
	# Test robot hire and upgrades
	game_data.gold = 500
	assert(game_data.robots["harvester"].owned == false, "Robot should not be owned initially")
	assert(game_data.get_robot_level(game_data.robots["harvester"]) == 0, "Robot should start at level 0")
	assert(game_data.upgrade_robot("harvester"), "Should be able to hire harvester")
	assert(game_data.robots["harvester"].owned == true, "Robot should be owned after hire")
	assert(game_data.get_robot_level(game_data.robots["harvester"]) == 1, "Hired robot should be level 1")
	var hire_speed = game_data.robot_work_speed("harvester")
	game_data.gold = game_data.robot_next_cost("harvester")
	assert(game_data.upgrade_robot("harvester"), "Should be able to upgrade harvester")
	assert(game_data.get_robot_level(game_data.robots["harvester"]) == 2, "Robot should reach level 2")
	assert(game_data.robot_work_speed("harvester") > hire_speed, "Upgraded robot should work faster")
	
	print("✓ Robot hire and upgrades passed")
	
	# Test prestige calculation
	game_data.total_gold_earned = 50000
	var prestige_currency = game_data.calculate_prestige_currency()
	assert(prestige_currency == 50, "Should calculate 50 prestige currency")
	assert(game_data.can_prestige() == false, "Should need 100 prestige currency")
	
	game_data.total_gold_earned = 100000
	assert(game_data.can_prestige() == true, "Should be able to prestige with enough currency")
	
	print("✓ Prestige calculation passed")
	
	# Test crop unlocks
	assert(game_data.plant_crop(Vector2i(1, 0), "cabbage") == false, "Locked crops cannot be planted")
	assert(game_data.unlock_crop("cabbage") == false, "Should need wheat harvests before cabbage")
	game_data.crop_harvests["wheat"] = 12
	game_data.gold = 20
	assert(game_data.unlock_crop("cabbage") == false, "Should need gold to unlock cabbage")
	game_data.gold = 35
	assert(game_data.unlock_crop("cabbage"), "Should unlock cabbage after farming wheat and paying")
	assert(game_data.unlocked_crops.has("cabbage"), "Cabbage should be unlocked")
	assert(game_data.unlock_crop("tomato") == false, "Should not skip crop tiers")
	
	print("✓ Crop unlocks passed")
	
	# Test plot unlocks
	var plots = GameData.new()
	assert(plots.unlocked_plot_count() == 8, "Should start with 8 unlocked plots")
	assert(plots.is_plot_unlocked(Vector2i(0, 0)), "Starter plot should be open")
	assert(plots.is_plot_unlocked(Vector2i(5, 7)) == false, "Far plots should start locked")
	assert(plots.plant_crop(Vector2i(5, 7), "wheat") == false, "Cannot plant on locked soil")
	assert(plots.unlock_plot(Vector2i(5, 5)) == false, "Cannot skip to a distant plot")
	plots.gold = 25
	assert(plots.plot_unlock_cost() == 20, "First extra plot should cost 20")
	assert(plots.unlock_plot(Vector2i(4, 0)), "Should unlock a neighboring plot")
	assert(plots.unlocked_plot_count() == 9, "Should have 9 plots after buying one")
	assert(plots.plant_crop(Vector2i(4, 0), "wheat"), "Should plant on a newly bought plot")
	
	print("✓ Plot unlocks passed")
	
	print("=== All tests passed! ===")
	print("The game should run without errors.")
	quit(0)
