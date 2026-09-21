extends RefCounted
class_name SpriteBank

## Loads mockup-derived PNG sprites from res://assets/sprites/.
## Falls back to null so callers can use procedural art.

const SPRITE_DIR := "res://assets/sprites/"

static var _images: Dictionary = {}
static var _misses: Dictionary = {}

static func reset() -> void:
	_images.clear()
	_misses.clear()

static func has_sprite(sprite_id: String) -> bool:
	return get_image(sprite_id) != null

static func get_image(sprite_id: String) -> Image:
	if sprite_id.is_empty():
		return null
	if _images.has(sprite_id):
		return _images[sprite_id]
	if _misses.has(sprite_id):
		return null
	var path := SPRITE_DIR + sprite_id + ".png"
	if not FileAccess.file_exists(path):
		_misses[sprite_id] = true
		return null
	var image := Image.new()
	var err := image.load(path)
	if err != OK:
		_misses[sprite_id] = true
		return null
	_images[sprite_id] = image
	return image

static func get_texture(sprite_id: String) -> ImageTexture:
	var image := get_image(sprite_id)
	if image == null:
		return null
	return ImageTexture.create_from_image(image)

static func crop_sprite_id(crop_id: String) -> String:
	return crop_id

static func product_sprite_id(product_id: String) -> String:
	match product_id:
		"melon_juice":
			return "watermelon_slice"
		"cider":
			return "apple"
		"oil":
			return "sunflower"
		"hot_sauce":
			return "pepper"
		"slaw":
			return "cabbage"
		"onion_rings":
			return "onion"
		"coffee_cup":
			return "coffee"
		"bread":
			return "flour"
		"blueberry_muffin":
			return "blueberry"
		"peach_preserve":
			return "peach"
		"cherry_syrup":
			return "cherry"
		"chocolate":
			return "cocoa"
		"guacamole":
			return "avocado"
		"truffle_oil":
			return "truffle"
		"saffron_tea":
			return "saffron"
		_:
			return product_id

static func growth_stage_id(crop_id: String, stage: int, max_stages: int) -> String:
	if max_stages <= 0:
		return crop_id
	var t := float(stage) / float(maxi(1, max_stages - 1))
	if t < 0.34:
		return "sprout"
	if t < 0.67:
		return "plant"
	if crop_id == "wheat":
		return "tall"
	return "tall"
