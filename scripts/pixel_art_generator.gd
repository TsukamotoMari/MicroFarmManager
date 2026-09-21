extends RefCounted
class_name PixelArtGenerator

const OUTLINE := Color(0.14, 0.08, 0.05, 0.95)

func create_crop_sprite(crop_type: String, color: Color, growth_stage: int = -1, max_stages: int = 3) -> Image:
	if growth_stage >= 0 and max_stages > 0 and growth_stage < max_stages:
		return _create_crop_stage_sprite(crop_type, color, growth_stage, max_stages)
	var sheet := SpriteBank.get_image(SpriteBank.crop_sprite_id(crop_type))
	if sheet != null:
		return _copy_image(sheet)
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	match crop_type:
		"wheat":
			_draw_wheat(image)
		"carrot":
			_draw_carrot(image)
		"tomato":
			_draw_tomato(image)
		"corn":
			_draw_corn(image)
		"pumpkin":
			_draw_pumpkin(image)
		"cabbage":
			_draw_cabbage(image)
		"potato":
			_draw_potato(image)
		"onion":
			_draw_onion(image)
		"strawberry":
			_draw_strawberry(image)
		"pepper":
			_draw_pepper(image)
		"sunflower":
			_draw_sunflower(image)
		"grape":
			_draw_grape(image)
		"apple":
			_draw_apple(image)
		"blueberry":
			_draw_blueberry(image)
		"peach":
			_draw_peach(image)
		"cherry":
			_draw_cherry(image)
		"cocoa":
			_draw_cocoa(image)
		"avocado":
			_draw_avocado(image)
		"truffle":
			_draw_truffle(image)
		"saffron":
			_draw_saffron(image)
		"watermelon":
			_draw_watermelon(image)
		"coffee":
			_draw_coffee_cherries(image)
		_:
			_disc(image, 16, 16, 7, color)
	_add_outline(image, OUTLINE)
	return image

func create_product_sprite(product_id: String, fallback_color: Color = Color.WHITE) -> Image:
	var sheet := SpriteBank.get_image(SpriteBank.product_sprite_id(product_id))
	if sheet != null:
		return _copy_image(sheet)
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	match product_id:
		"popcorn":
			_draw_popcorn(image)
		"flour":
			_draw_flour(image)
		"carrot_cake":
			_draw_carrot_cake(image)
		"tomato_sauce":
			_draw_tomato_sauce(image)
		"pumpkin_pie":
			_draw_pumpkin_pie(image)
		"slaw":
			_draw_slaw(image)
		"fries":
			_draw_fries(image)
		"onion_rings":
			_draw_onion_rings(image)
		"jam":
			_draw_jam(image)
		"hot_sauce":
			_draw_hot_sauce(image)
		"oil":
			_draw_oil(image)
		"wine":
			_draw_wine(image)
		"cider":
			_draw_cider(image)
		"melon_juice":
			_draw_melon_juice(image)
		"coffee_cup":
			_draw_coffee_cup(image)
		"bread":
			_draw_bread(image)
		"blueberry_muffin":
			_draw_blueberry_muffin(image)
		"peach_preserve":
			_draw_peach_preserve(image)
		"cherry_syrup":
			_draw_cherry_syrup(image)
		"chocolate":
			_draw_chocolate(image)
		"guacamole":
			_draw_guacamole(image)
		"truffle_oil":
			_draw_truffle_oil(image)
		"saffron_tea":
			_draw_saffron_tea(image)
		_:
			_disc(image, 16, 16, 7, fallback_color)
	_add_outline(image, OUTLINE)
	return image

func create_plot_sprite(watered: bool = false) -> Image:
	var image := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	var soil_a := Color(0.58, 0.36, 0.18) if not watered else Color(0.40, 0.26, 0.14)
	var soil_b := Color(0.48, 0.30, 0.14) if not watered else Color(0.32, 0.22, 0.12)
	var rim := Color(0.22, 0.12, 0.06)
	var rim_hi := Color(0.68, 0.46, 0.22)
	var rim_mid := Color(0.42, 0.26, 0.12)
	for y in 48:
		for x in 48:
			var edge := mini(mini(x, y), mini(47 - x, 47 - y))
			if edge < 2:
				image.set_pixel(x, y, rim)
			elif edge < 4:
				image.set_pixel(x, y, rim_hi if (x < 8 or y < 8) else rim_mid)
			else:
				var furrow := (y % 5) < 2
				var n := sin(x * 0.45 + y * 0.2) * 0.035
				var c := soil_b if furrow else soil_a
				c = Color(clampf(c.r + n, 0, 1), clampf(c.g + n * 0.5, 0, 1), clampf(c.b + n * 0.3, 0, 1))
				if watered and ((x + y * 3) % 11 == 0):
					c = c.lerp(Color(0.42, 0.68, 0.95), 0.5)
				image.set_pixel(x, y, c)
	if watered:
		for p in [Vector2i(14, 16), Vector2i(30, 22), Vector2i(20, 34), Vector2i(34, 12)]:
			_disc(image, p.x, p.y, 2, Color(0.55, 0.82, 1.0, 0.55))
	return image

func create_water_overlay() -> Image:
	var image := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in 48:
		for x in 48:
			if (x + y * 3 + int(sin(x * 0.4) * 2.0)) % 9 == 0:
				_px(image, x, y, Color(0.45, 0.72, 0.98, 0.28))
			elif (x * 2 + y) % 11 == 0:
				_px(image, x, y, Color(0.72, 0.90, 1.0, 0.18))
	return image

func create_locked_plot_sprite() -> Image:
	var image := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	for y in 48:
		for x in 48:
			var n := sin(x * 0.4) * 0.04 + cos(y * 0.35) * 0.03
			var edge := mini(mini(x, y), mini(47 - x, 47 - y))
			if edge < 3:
				image.set_pixel(x, y, Color(0.22, 0.14, 0.08))
			else:
				var grass := Color(0.36 + n, 0.66 + n * 0.35, 0.30 + n * 0.15)
				if (x + y * 2) % 7 == 0:
					grass = grass.darkened(0.08)
				image.set_pixel(x, y, grass)
	_rect(image, 18, 22, 12, 12, Color(0.90, 0.72, 0.24))
	_rect(image, 20, 24, 8, 8, Color(0.62, 0.42, 0.10))
	for a in range(0, 360, 18):
		var rad := deg_to_rad(float(a))
		_px(image, 24 + int(cos(rad) * 5.0), 20 + int(sin(rad) * 4.0), Color(0.95, 0.80, 0.30))
	_px(image, 24, 28, Color(0.18, 0.10, 0.04))
	return image

func create_wood_panel_tile(size: int = 64, highlight: bool = false) -> Image:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var edge := Color(0.08, 0.04, 0.02)
	var dark := Color(0.16, 0.09, 0.04)
	var mid := Color(0.34, 0.20, 0.10)
	var lite := Color(0.55, 0.36, 0.16)
	var fill := Color(0.26, 0.15, 0.08)
	var gold := Color(0.94, 0.74, 0.24)
	for y in size:
		for x in size:
			var edge_d := mini(mini(x, y), mini(size - 1 - x, size - 1 - y))
			var c := fill
			if edge_d < 2:
				c = edge
			elif edge_d < 4:
				c = dark
			elif edge_d < 7:
				c = lite if (x < size / 2 or y < size / 2) else mid
			elif edge_d < 10:
				c = mid
			else:
				c = fill.lightened(0.015) if ((x / 3 + y / 5) % 4 == 0) else fill
			if highlight and edge_d >= 2 and edge_d < 5:
				c = c.lerp(gold, 0.6)
			image.set_pixel(x, y, c)
	for p in [Vector2i(5, 5), Vector2i(size - 6, 5), Vector2i(5, size - 6), Vector2i(size - 6, size - 6)]:
		_px(image, p.x, p.y, gold if highlight else lite)
		_px(image, p.x + 1, p.y, gold if highlight else lite)
	return image

func _sprite_looks_usable(sheet: Image) -> bool:
	# Reject mostly-transparent or tiny content sprites.
	var opaque := 0
	var w := sheet.get_width()
	var h := sheet.get_height()
	if w < 8 or h < 8:
		return false
	for y in range(0, h, 2):
		for x in range(0, w, 2):
			if sheet.get_pixel(x, y).a > 0.2:
				opaque += 1
	return opaque > (w * h) / 16

func create_chip_tile(selected: bool, ready: bool = false) -> Image:
	# Match wood panels: clean frame, no muddy AI chip tiles.
	var image := Image.create(40, 40, false, Image.FORMAT_RGBA8)
	var bg := Color(0.26, 0.15, 0.08)
	var border := Color(0.14, 0.08, 0.04)
	var lite := Color(0.55, 0.36, 0.16)
	if selected:
		bg = Color(0.36, 0.22, 0.10)
		border = Color(0.94, 0.74, 0.24)
		lite = Color(0.98, 0.86, 0.42)
	elif ready:
		bg = Color(0.32, 0.20, 0.10)
		border = Color(0.78, 0.58, 0.18)
	for y in 40:
		for x in 40:
			var edge := mini(mini(x, y), mini(39 - x, 39 - y))
			var c := bg
			if edge < 2:
				c = border
			elif edge < 4:
				c = lite if selected else bg.lightened(0.08)
			image.set_pixel(x, y, c)
	return image

func create_farm_fence_frame(inner_w: int, inner_h: int, border: int = 12) -> Image:
	var w := inner_w + border * 2
	var h := inner_h + border * 2
	var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var post := Color(0.52, 0.32, 0.14)
	var post_d := Color(0.28, 0.16, 0.08)
	var rail := Color(0.62, 0.40, 0.18)
	var grass := Color(0.32, 0.58, 0.28, 0.35)
	# Soft grass under fence
	for y in h:
		for x in w:
			if x < border or x >= w - border or y < border or y >= h - border:
				if (x + y) % 5 == 0:
					_px(image, x, y, grass)
	# Rails
	for y in [border / 3, border - 3, h - border + 2, h - border / 3]:
		for x in range(2, w - 2):
			_px(image, x, int(y), rail)
			_px(image, x, int(y) + 1, post_d)
	for x in [border / 3, border - 3, w - border + 2, w - border / 3]:
		for y in range(2, h - 2):
			_px(image, int(x), y, rail)
			_px(image, int(x) + 1, y, post_d)
	# Corner posts
	for cx in [2, w - 8]:
		for cy in [2, h - 8]:
			_rect(image, cx, cy, 6, 6, post)
			_rect(image, cx + 1, cy + 1, 4, 4, post.lightened(0.1))
	return image

func create_background(width: int, height: int) -> Image:
	var sheet := SpriteBank.get_image("background")
	if sheet != null and _sprite_looks_usable(sheet):
		var scaled: Image = _copy_image(sheet)
		if scaled.get_width() != width or scaled.get_height() != height:
			scaled.resize(width, height, Image.INTERPOLATE_NEAREST)
		return scaled
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var horizon := int(height * 0.32)
	for y in height:
		var color: Color
		if y < horizon:
			var sky_t := float(y) / float(maxi(1, horizon))
			color = Color(0.38, 0.68, 0.92).lerp(Color(0.72, 0.88, 0.98), sky_t)
			if y % 3 == 0:
				color = color.darkened(0.015)
		else:
			var g := (float(y) - horizon) / float(maxi(1, height - horizon))
			color = Color(0.44, 0.72, 0.36).lerp(Color(0.20, 0.42, 0.20), g)
		for x in width:
			var n := sin((x + y) * 0.05) * 0.025 if y >= horizon else 0.0
			image.set_pixel(x, y, Color(color.r + n, color.g + n, color.b + n * 0.4))
	_disc(image, width - 26, 20, 11, Color(1.0, 0.90, 0.50))
	_disc(image, width - 26, 20, 7, Color(1.0, 0.97, 0.78))
	_cloud(image, 24, 24, 14)
	_cloud(image, int(width * 0.38), 16, 11)
	_cloud(image, int(width * 0.62), 28, 9)
	for x in width:
		var h1 := horizon - 22 - int(sin(x * 0.03) * 12 + cos(x * 0.018) * 7)
		for y in range(maxi(0, h1), horizon):
			image.set_pixel(x, y, Color(0.26, 0.52, 0.28))
		var h2 := horizon - 10 - int(sin(x * 0.045 + 1.0) * 7)
		for y in range(maxi(0, h2), horizon):
			image.set_pixel(x, y, Color(0.34, 0.62, 0.32))
	_stamp_sprite(image, "barn", int(width * 0.70), horizon - 4, 56, 48)
	_stamp_sprite(image, "windmill", int(width * 0.12), horizon - 10, 40, 56)
	_stamp_sprite(image, "grass", int(width * 0.28), horizon + 18, 18, 18)
	_stamp_sprite(image, "grass", int(width * 0.55), horizon + 28, 16, 16)
	return image

func _stamp_sprite(target: Image, sprite_id: String, x: int, y: int, w: int, h: int) -> void:
	var sheet := SpriteBank.get_image(sprite_id)
	if sheet == null:
		return
	var scaled: Image = _copy_image(sheet)
	scaled.resize(w, h, Image.INTERPOLATE_NEAREST)
	for sy in h:
		for sx in w:
			var c: Color = scaled.get_pixel(sx, sy)
			if c.a < 0.15:
				continue
			var tx := x + sx
			var ty := y + sy
			if tx < 0 or ty < 0 or tx >= target.get_width() or ty >= target.get_height():
				continue
			var base: Color = target.get_pixel(tx, ty)
			target.set_pixel(tx, ty, base.lerp(c, c.a))

func _copy_image(source: Image) -> Image:
	return source.duplicate() as Image

func create_tab_icon(tab_id: String) -> Image:
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	match tab_id:
		"market":
			_rect(image, 5, 8, 14, 10, Color(0.82, 0.52, 0.22))
			_rect(image, 7, 4, 10, 4, Color(0.62, 0.38, 0.16))
			_px(image, 9, 10, Color(0.32, 0.72, 0.28))
			_px(image, 12, 11, Color(0.92, 0.22, 0.18))
			_px(image, 15, 10, Color(0.96, 0.78, 0.18))
		"bots":
			return create_robot_sprite()
		"upgrades":
			_disc(image, 12, 12, 8, Color(0.92, 0.76, 0.22))
			_disc(image, 12, 12, 4, Color(0.72, 0.48, 0.10))
			for i in 6:
				var a := float(i) * 1.047
				_px(image, 12 + int(cos(a) * 6.0), 12 + int(sin(a) * 6.0), Color(0.98, 0.92, 0.62))
		"progress":
			_rect(image, 5, 5, 14, 14, Color(0.92, 0.86, 0.72))
			_rect(image, 8, 8, 8, 8, Color(0.32, 0.62, 0.34))
			_px(image, 12, 10, Color(0.98, 0.92, 0.62))
		"farm":
			_vline(image, 12, 14, 22, Color(0.38, 0.62, 0.24))
			_disc(image, 12, 10, 5, Color(0.42, 0.72, 0.32))
			_disc(image, 10, 9, 2, Color(0.58, 0.86, 0.42))
	_add_outline(image, OUTLINE)
	return image

func create_water_icon() -> Image:
	var sheet := SpriteBank.get_image("water")
	if sheet != null:
		var scaled: Image = _copy_image(sheet)
		scaled.resize(16, 16, Image.INTERPOLATE_NEAREST)
		return scaled
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_disc(image, 8, 10, 5, Color(0.28, 0.62, 0.96))
	_disc(image, 7, 9, 2, Color(0.62, 0.86, 1.0))
	_px(image, 8, 4, Color(0.42, 0.72, 0.98))
	_px(image, 7, 5, Color(0.42, 0.72, 0.98))
	_px(image, 9, 5, Color(0.42, 0.72, 0.98))
	return image

func create_energy_icon() -> Image:
	var sheet := SpriteBank.get_image("energy")
	if sheet != null:
		var scaled: Image = _copy_image(sheet)
		scaled.resize(16, 16, Image.INTERPOLATE_NEAREST)
		return scaled
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_rect(image, 4, 5, 8, 9, Color(0.74, 0.80, 0.86))
	_rect(image, 6, 7, 2, 2, Color(0.25, 0.95, 0.55))
	_rect(image, 9, 7, 2, 2, Color(0.25, 0.95, 0.55))
	_px(image, 8, 3, Color(0.95, 0.28, 0.28))
	return image

func _create_crop_stage_sprite(crop_type: String, color: Color, stage: int, max_stages: int) -> Image:
	if stage >= max_stages - 1:
		return create_crop_sprite(crop_type, color)
	var stage_id := SpriteBank.growth_stage_id(crop_type, stage, max_stages)
	var sheet := SpriteBank.get_image(stage_id)
	if sheet != null:
		return _copy_image(sheet)
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var stem := Color(0.32, 0.58, 0.22)
	var leaf := Color(0.42, 0.72, 0.30)
	var t := float(stage + 1) / float(max_stages + 1)
	if stage <= 0:
		_vline(image, 15, 22, 28, stem)
		_vline(image, 16, 22, 28, stem)
		_disc(image, 16, 24, 2, leaf)
		_px(image, 13, 23, leaf)
		_px(image, 19, 23, leaf)
	elif stage < max_stages - 1:
		_vline(image, 15, 18, 29, stem)
		_vline(image, 16, 18, 29, stem)
		for i in 3:
			_disc(image, 16, 16 - i * 3, 2 + i, leaf.darkened(0.05 * float(i)))
		var mini := create_crop_sprite(crop_type, color)
		var scale := 0.45 + t * 0.35
		var offset := int(16.0 - 16.0 * scale)
		var size := int(32.0 * scale)
		for y in size:
			for x in size:
				var sx := int(float(x) / scale)
				var sy := int(float(y) / scale)
				if sx >= 32 or sy >= 32:
					continue
				var c := mini.get_pixel(sx, sy)
				if c.a > 0.1:
					_px(image, offset + x, offset + y - 2, c)
	else:
		return create_crop_sprite(crop_type, color)
	_add_outline(image, OUTLINE)
	return image

func create_coin_icon() -> Image:
	# Always draw a clean G-coin; atlas slices were often wrong.
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_disc(image, 12, 12, 9, Color(0.38, 0.24, 0.05))
	_disc(image, 12, 12, 8, Color(0.96, 0.76, 0.22))
	_disc(image, 10, 10, 3, Color(1.0, 0.93, 0.58))
	_px(image, 11, 9, Color(0.45, 0.30, 0.06))
	_px(image, 12, 9, Color(0.45, 0.30, 0.06))
	_px(image, 11, 10, Color(0.45, 0.30, 0.06))
	_px(image, 12, 10, Color(0.45, 0.30, 0.06))
	_px(image, 11, 11, Color(0.45, 0.30, 0.06))
	_px(image, 12, 11, Color(0.45, 0.30, 0.06))
	_px(image, 11, 12, Color(0.45, 0.30, 0.06))
	_px(image, 12, 12, Color(0.45, 0.30, 0.06))
	_px(image, 13, 12, Color(0.45, 0.30, 0.06))
	_px(image, 11, 13, Color(0.45, 0.30, 0.06))
	_px(image, 12, 13, Color(0.45, 0.30, 0.06))
	_px(image, 11, 14, Color(0.45, 0.30, 0.06))
	_px(image, 12, 14, Color(0.45, 0.30, 0.06))
	_px(image, 13, 9, Color(0.45, 0.30, 0.06))
	_px(image, 14, 9, Color(0.45, 0.30, 0.06))
	_px(image, 13, 15, Color(0.45, 0.30, 0.06))
	_px(image, 14, 15, Color(0.45, 0.30, 0.06))
	_add_outline(image, Color(0.28, 0.16, 0.04))
	return image

func create_robot_sprite() -> Image:
	var sheet := SpriteBank.get_image("robot")
	if sheet != null:
		return _copy_image(sheet)
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var metal := Color(0.74, 0.80, 0.86)
	var metal_d := Color(0.52, 0.58, 0.66)
	var visor := Color(0.25, 0.95, 0.55)
	_rect(image, 9, 13, 14, 12, metal)
	_rect(image, 10, 6, 12, 8, metal.lightened(0.08))
	_rect(image, 12, 8, 3, 3, visor)
	_rect(image, 17, 8, 3, 3, visor)
	_px(image, 16, 3, Color(0.95, 0.28, 0.28))
	_px(image, 16, 4, Color(0.95, 0.28, 0.28))
	_px(image, 16, 5, metal_d)
	_rect(image, 7, 16, 3, 3, metal_d)
	_rect(image, 22, 16, 3, 3, metal_d)
	_rect(image, 11, 25, 3, 4, metal_d)
	_rect(image, 18, 25, 3, 4, metal_d)
	_add_outline(image, Color(0.16, 0.14, 0.18))
	return image

func _draw_wheat(image: Image):
	var stalk := Color(0.42, 0.62, 0.20)
	var grain := Color(0.93, 0.78, 0.22)
	var grain_l := Color(1.0, 0.90, 0.42)
	_vline(image, 15, 18, 29, stalk)
	_vline(image, 16, 18, 29, stalk)
	# individual grains, not one fused head
	var grains := [
		Vector2i(16, 6), Vector2i(13, 8), Vector2i(19, 8),
		Vector2i(16, 10), Vector2i(12, 12), Vector2i(20, 12),
		Vector2i(16, 14), Vector2i(13, 16), Vector2i(19, 16)
	]
	for i in grains.size():
		var g: Vector2i = grains[i]
		_px(image, g.x, g.y, grain_l)
		_px(image, g.x + 1, g.y, grain)
		_px(image, g.x, g.y + 1, grain)
		_px(image, g.x + 1, g.y + 1, grain.darkened(0.08))

func _draw_carrot(image: Image):
	var body := Color(0.94, 0.48, 0.10)
	var body_d := Color(0.78, 0.32, 0.06)
	var ring := Color(0.98, 0.62, 0.22)
	var greens := Color(0.28, 0.64, 0.22)
	for y in range(11, 30):
		var w := 1 + int((29 - y) * 0.22)
		for x in range(16 - w, 17 + w):
			var c := ring if (y - 11) % 4 == 0 else body
			if x <= 16 - w + 1:
				c = body_d
			_px(image, x, y, c)
	_px(image, 14, 8, greens)
	_px(image, 15, 7, greens)
	_px(image, 15, 9, greens)
	_px(image, 16, 6, greens)
	_px(image, 16, 8, greens)
	_px(image, 16, 10, greens)
	_px(image, 17, 7, greens)
	_px(image, 17, 9, greens)
	_px(image, 18, 8, greens)

func _draw_tomato(image: Image):
	var red := Color(0.86, 0.14, 0.14)
	var red_l := Color(0.96, 0.38, 0.30)
	var calyx := Color(0.26, 0.56, 0.20)
	_ellipse(image, 16, 18, 9, 8, red)
	_disc(image, 12, 15, 3, red_l)
	_px(image, 16, 10, calyx)
	_px(image, 15, 10, calyx)
	_px(image, 17, 10, calyx)
	_px(image, 14, 11, calyx)
	_px(image, 18, 11, calyx)
	_px(image, 16, 9, calyx)
	_px(image, 13, 12, calyx)
	_px(image, 19, 12, calyx)

func _draw_corn(image: Image):
	var husk := Color(0.30, 0.62, 0.20)
	var husk_d := Color(0.18, 0.42, 0.12)
	var husk_l := Color(0.52, 0.78, 0.28)
	var kernel := Color(0.98, 0.82, 0.14)
	var kernel_l := Color(1.0, 0.93, 0.38)
	var gap := Color(0.70, 0.46, 0.08)
	var silk := Color(0.95, 0.90, 0.62)
	for x in [13, 15, 17, 19]:
		_px(image, x, 3, silk)
		_px(image, x, 4, silk)
	_px(image, 14, 2, silk)
	_px(image, 16, 2, silk)
	_px(image, 18, 2, silk)
	for row in 6:
		var y := 6 + row * 3
		var cols := [16] if row == 0 else [12, 16, 20]
		for x in cols:
			var shade := kernel_l if ((x + row) % 8) == 0 else kernel
			_px(image, x, y, shade)
			_px(image, x + 1, y, shade.lightened(0.1))
			_px(image, x, y + 1, shade.darkened(0.12))
			_px(image, x + 1, y + 1, shade)
			_px(image, x - 1, y, gap)
			_px(image, x + 2, y, gap)
			_px(image, x, y + 2, gap)
	for y in range(10, 24):
		_px(image, 8, y, husk_d)
		_px(image, 9, y, husk)
		_px(image, 10, y, husk_l if y < 17 else husk)
		_px(image, 23, y, husk_l if y < 17 else husk)
		_px(image, 24, y, husk)
		_px(image, 25, y, husk_d)
	_px(image, 6, 18, husk_d)
	_px(image, 6, 19, husk)
	_px(image, 27, 18, husk_d)
	_px(image, 27, 19, husk)
	for x in range(11, 22):
		_px(image, x, 24, husk)
		_px(image, x, 25, husk_d)

func _draw_pumpkin(image: Image):
	var d := Color(0.78, 0.32, 0.06)
	var m := Color(0.92, 0.46, 0.08)
	var l := Color(1.0, 0.62, 0.18)
	var groove := Color(0.52, 0.20, 0.04)
	var stem := Color(0.36, 0.42, 0.16)
	var stem_d := Color(0.24, 0.28, 0.10)
	var vine := Color(0.30, 0.62, 0.24)
	# five overlapping lobes, back to front
	_ellipse(image, 7, 19, 5, 7, d)
	_ellipse(image, 25, 19, 5, 7, d)
	_ellipse(image, 11, 18, 5, 8, m)
	_ellipse(image, 21, 18, 5, 8, m)
	_ellipse(image, 16, 18, 6, 8, l)
	# thin grooves between lobes
	for y in range(13, 25):
		_px(image, 10, y, groove)
		_px(image, 13, y, groove)
		_px(image, 19, y, groove)
		_px(image, 22, y, groove)
	# highlight on the front lobe
	_px(image, 14, 15, l.lightened(0.12))
	_px(image, 15, 14, l.lightened(0.12))
	# short thick stem in the crown
	_px(image, 15, 10, stem)
	_px(image, 16, 10, stem)
	_px(image, 15, 9, stem)
	_px(image, 16, 9, stem_d)
	_px(image, 15, 8, stem_d)
	_px(image, 16, 8, stem)
	_px(image, 16, 7, stem)
	_px(image, 17, 7, stem_d)
	# tiny curling vine
	_px(image, 17, 8, vine)
	_px(image, 18, 8, vine)
	_px(image, 19, 7, vine)

func _draw_cabbage(image: Image):
	var d := Color(0.16, 0.46, 0.20)
	var m := Color(0.34, 0.70, 0.32)
	var l := Color(0.58, 0.86, 0.46)
	_ellipse(image, 16, 18, 11, 9, d)
	_ellipse(image, 16, 18, 8, 7, m)
	_ellipse(image, 15, 17, 5, 4, l)
	# ruffled wrapper leaves
	for y in range(11, 16):
		_px(image, 7 + (y - 11), y, m)
		_px(image, 24 - (y - 11), y, m)
	for y in range(20, 26):
		_px(image, 8, y, d)
		_px(image, 24, y, d)
	_px(image, 6, 18, d)
	_px(image, 26, 18, d)
	_px(image, 12, 12, l)
	_px(image, 20, 13, l)

func _draw_potato(image: Image):
	var skin := Color(0.66, 0.48, 0.26)
	var skin_d := Color(0.44, 0.30, 0.14)
	var eye := Color(0.24, 0.14, 0.08)
	_ellipse(image, 16, 18, 10, 7, skin)
	_ellipse(image, 13, 16, 3, 2, skin_d)
	_px(image, 11, 15, eye)
	_px(image, 18, 14, eye)
	_px(image, 15, 19, eye)
	_px(image, 21, 18, eye)
	_px(image, 12, 21, eye)
	_px(image, 10, 12, Color(0.38, 0.60, 0.22))
	_px(image, 11, 11, Color(0.38, 0.60, 0.22))

func _draw_onion(image: Image):
	var purple := Color(0.56, 0.28, 0.70)
	var purple_l := Color(0.78, 0.58, 0.88)
	var white := Color(0.92, 0.88, 0.90)
	var shoot := Color(0.32, 0.70, 0.28)
	for y in range(12, 29):
		var t := float(y - 12) / 16.0
		var w := 2 + int(sin(t * PI) * 6.0)
		if y > 24:
			w = maxi(2, 5 - (y - 24))
		for x in range(16 - w, 17 + w):
			var c := purple if y < 21 else white
			if y == 20:
				c = purple_l
			_px(image, x, y, c)
	_vline(image, 15, 6, 12, shoot)
	_vline(image, 16, 5, 12, shoot)
	_vline(image, 17, 7, 12, shoot)
	_px(image, 14, 8, shoot)
	_px(image, 18, 9, shoot)

func _draw_strawberry(image: Image):
	var red := Color(0.88, 0.12, 0.18)
	var red_d := Color(0.66, 0.08, 0.12)
	var seed := Color(0.98, 0.86, 0.28)
	var cap := Color(0.28, 0.62, 0.22)
	for y in range(10, 29):
		var t := float(y - 10) / 18.0
		var w := 2 + int(sin(t * PI) * 7.0)
		if y > 25:
			w = maxi(1, 28 - y)
		for x in range(16 - w, 17 + w):
			_px(image, x, y, red if (x + y) % 3 != 0 else red_d)
	for p in [Vector2i(13, 16), Vector2i(18, 15), Vector2i(15, 19), Vector2i(19, 20), Vector2i(12, 21), Vector2i(16, 23)]:
		_px(image, p.x, p.y, seed)
	_px(image, 14, 8, cap)
	_px(image, 16, 7, cap)
	_px(image, 18, 8, cap)
	_px(image, 12, 10, cap)
	_px(image, 16, 9, cap)
	_px(image, 20, 10, cap)
	_px(image, 13, 11, cap)
	_px(image, 19, 11, cap)

func _draw_pepper(image: Image):
	var red := Color(0.86, 0.10, 0.12)
	var red_l := Color(0.96, 0.34, 0.24)
	var stem := Color(0.28, 0.58, 0.20)
	for i in 17:
		var x := 11 + int(pow(float(i) / 16.0, 1.4) * 9.0)
		var y := 8 + i
		var w := 3 if i < 11 else 2 if i < 15 else 1
		for ox in range(-w, w + 1):
			_px(image, x + ox, y, red_l if ox < 0 else red)
	_rect(image, 10, 5, 4, 3, stem)
	_px(image, 12, 4, stem)

func _draw_sunflower(image: Image):
	var petal := Color(0.98, 0.82, 0.10)
	var petal_d := Color(0.86, 0.58, 0.08)
	var center := Color(0.40, 0.22, 0.08)
	var seed := Color(0.20, 0.10, 0.04)
	var stem := Color(0.28, 0.58, 0.22)
	_vline(image, 15, 21, 30, stem)
	_vline(image, 16, 21, 30, stem)
	var angles := [0.0, 0.785, 1.57, 2.356, 3.141, 3.927, 4.712, 5.498]
	for a in angles:
		var px := 16 + int(cos(a) * 7.0)
		var py := 14 + int(sin(a) * 7.0)
		_disc(image, px, py, 3, petal if int(a * 10.0) % 2 == 0 else petal_d)
	_disc(image, 16, 14, 5, center)
	_px(image, 15, 13, seed)
	_px(image, 17, 14, seed)
	_px(image, 16, 16, seed)
	_px(image, 14, 15, seed)

func _draw_grape(image: Image):
	var g := Color(0.44, 0.14, 0.54)
	var gl := Color(0.64, 0.30, 0.72)
	var stem := Color(0.32, 0.56, 0.22)
	_px(image, 16, 3, stem)
	_px(image, 16, 4, stem)
	_px(image, 15, 5, stem)
	_px(image, 17, 5, stem)
	var berries := [
		Vector2i(16, 8), Vector2i(12, 12), Vector2i(20, 12),
		Vector2i(16, 13), Vector2i(10, 17), Vector2i(22, 17),
		Vector2i(14, 18), Vector2i(18, 18), Vector2i(12, 23),
		Vector2i(16, 24), Vector2i(20, 23)
	]
	for i in berries.size():
		var b: Vector2i = berries[i]
		_disc(image, b.x, b.y, 2, gl if i % 2 == 0 else g)
		_px(image, b.x - 1, b.y - 1, gl.lightened(0.12))

func _draw_apple(image: Image):
	var red := Color(0.80, 0.10, 0.12)
	var red_l := Color(0.94, 0.30, 0.26)
	var stem := Color(0.38, 0.24, 0.10)
	var leaf := Color(0.30, 0.64, 0.24)
	_ellipse(image, 16, 19, 9, 8, red)
	# top cleft
	_px(image, 16, 11, Color(0, 0, 0, 0))
	_px(image, 16, 12, Color(0, 0, 0, 0))
	_disc(image, 12, 16, 3, red_l)
	_vline(image, 16, 7, 11, stem)
	_px(image, 17, 6, leaf)
	_px(image, 18, 5, leaf)
	_px(image, 19, 5, leaf)
	_px(image, 18, 6, leaf)
	_px(image, 19, 6, leaf)
	_px(image, 20, 6, leaf)
	_px(image, 20, 7, leaf)

func _draw_watermelon(image: Image):
	var rind := Color(0.16, 0.56, 0.24)
	var rind_d := Color(0.08, 0.36, 0.14)
	var pith := Color(0.94, 0.94, 0.86)
	var flesh := Color(0.90, 0.16, 0.30)
	var seed := Color(0.12, 0.08, 0.06)
	for y in range(8, 29):
		for x in range(4, 28):
			var dx := x - 16
			var dy := y - 8
			var r2 := dx * dx + dy * dy
			if dy < 0 or r2 > 18 * 18:
				continue
			if r2 > 15 * 15:
				_px(image, x, y, rind if int(x / 2) % 2 == 0 else rind_d)
			elif r2 > 13 * 13:
				_px(image, x, y, pith)
			else:
				_px(image, x, y, flesh)
	_px(image, 12, 16, seed)
	_px(image, 16, 18, seed)
	_px(image, 20, 16, seed)
	_px(image, 14, 22, seed)
	_px(image, 18, 22, seed)

func _draw_coffee_cherries(image: Image):
	var branch := Color(0.42, 0.26, 0.12)
	var leaf := Color(0.24, 0.56, 0.22)
	var cherry := Color(0.78, 0.10, 0.12)
	var cherry_l := Color(0.92, 0.28, 0.22)
	_hline(image, 6, 26, 17, branch)
	_hline(image, 6, 26, 18, branch)
	# paired cherries
	_disc(image, 10, 12, 3, cherry)
	_disc(image, 14, 13, 3, cherry_l)
	_disc(image, 20, 12, 3, cherry)
	_disc(image, 24, 13, 3, cherry_l)
	_px(image, 12, 15, branch)
	_px(image, 22, 15, branch)
	_ellipse(image, 8, 22, 5, 3, leaf)
	_ellipse(image, 16, 23, 5, 3, leaf)
	_ellipse(image, 25, 22, 5, 3, leaf)

func _draw_popcorn(image: Image):
	var red := Color(0.84, 0.14, 0.16)
	var red_d := Color(0.58, 0.08, 0.10)
	var white := Color(0.99, 0.98, 0.95)
	var puff := Color(0.99, 0.96, 0.86)
	var puff_d := Color(0.88, 0.80, 0.58)
	var butter := Color(0.98, 0.80, 0.22)
	for y in range(16, 30):
		var inset := 1 if y >= 27 else 0
		for x in range(7 + inset, 25 - inset):
			var stripe_on := int(x / 3) % 2 == 0
			var color := red if stripe_on else white
			if y == 16:
				color = color.lightened(0.15)
			if y >= 28:
				color = red_d if stripe_on else white.darkened(0.08)
			_px(image, x, y, color)
	_pop_kernel(image, 10, 13, puff, butter)
	_pop_kernel(image, 16, 9, puff, butter)
	_pop_kernel(image, 22, 13, puff, puff_d)
	_pop_kernel(image, 13, 15, Color(1, 0.98, 0.9), butter)
	_pop_kernel(image, 19, 15, puff, butter)

func _pop_kernel(image: Image, cx: int, cy: int, body: Color, center: Color):
	for ox in range(-2, 3):
		_px(image, cx + ox, cy, body)
		_px(image, cx, cy + ox, body)
	_px(image, cx - 1, cy - 1, body)
	_px(image, cx + 1, cy - 1, body.lightened(0.08))
	_px(image, cx - 1, cy + 1, body.darkened(0.08))
	_px(image, cx + 1, cy + 1, body)
	_px(image, cx - 2, cy - 1, body)
	_px(image, cx + 2, cy + 1, body)
	_px(image, cx, cy, center)

func _draw_flour(image: Image):
	var bag := Color(0.93, 0.86, 0.70)
	var bag_d := Color(0.76, 0.66, 0.48)
	var fold := Color(0.84, 0.76, 0.58)
	var stamp := Color(0.70, 0.20, 0.16)
	_rect(image, 8, 10, 16, 18, bag)
	_rect(image, 9, 7, 14, 4, fold)
	_hline(image, 8, 23, 10, bag_d)
	_hline(image, 10, 21, 16, stamp)
	_hline(image, 10, 21, 20, stamp)
	_px(image, 15, 18, stamp)
	_px(image, 16, 18, stamp)

func _draw_carrot_cake(image: Image):
	var cake := Color(0.88, 0.52, 0.22)
	var cake_d := Color(0.70, 0.36, 0.12)
	var icing := Color(0.98, 0.94, 0.90)
	var crumb := Color(0.62, 0.30, 0.10)
	# slice: triangle pointing up-left
	for y in range(10, 27):
		var w := int((y - 10) * 0.9)
		for x in range(8, 9 + w):
			if x > 26:
				continue
			var c := icing if y < 13 else cake
			if y == 18:
				c = crumb
			if y > 18 and y < 21:
				c = icing
			if x <= 8:
				c = cake_d
			_px(image, x, y, c)
	_px(image, 12, 8, Color(0.95, 0.45, 0.16))
	_px(image, 13, 7, Color(0.28, 0.62, 0.24))

func _draw_tomato_sauce(image: Image):
	var glass := Color(0.78, 0.88, 0.86)
	var sauce := Color(0.70, 0.10, 0.10)
	var lid := Color(0.78, 0.16, 0.14)
	var label := Color(0.96, 0.90, 0.72)
	_rect(image, 9, 12, 14, 16, sauce)
	_rect(image, 9, 12, 14, 3, glass)
	_rect(image, 10, 8, 12, 4, lid)
	_rect(image, 11, 18, 10, 5, label)
	_disc(image, 16, 20, 2, sauce)

func _draw_pumpkin_pie(image: Image):
	var filling := Color(0.86, 0.40, 0.10)
	var filling_l := Color(0.95, 0.55, 0.20)
	var crust := Color(0.78, 0.52, 0.20)
	var crust_d := Color(0.55, 0.34, 0.12)
	# pie slice
	for y in range(10, 27):
		var w := int((y - 9) * 0.85)
		for x in range(16 - w, 17 + w):
			if y >= 24:
				_px(image, x, y, crust_d)
			elif y >= 22:
				_px(image, x, y, crust)
			else:
				_px(image, x, y, filling_l if (x + y) % 5 == 0 else filling)
	_hline(image, 7, 25, 10, crust)
	_hline(image, 8, 24, 11, crust)

func _draw_slaw(image: Image):
	var bowl := Color(0.88, 0.88, 0.90)
	var bowl_d := Color(0.70, 0.70, 0.74)
	var green := Color(0.42, 0.76, 0.30)
	var pale := Color(0.86, 0.90, 0.52)
	_ellipse(image, 16, 22, 12, 6, bowl_d)
	_ellipse(image, 16, 19, 11, 7, bowl)
	for y in range(13, 21):
		for x in range(8, 24):
			if ((x + y * 3) % 4) == 0:
				_px(image, x, y, green)
			elif ((x + y * 2) % 5) == 0:
				_px(image, x, y, pale)

func _draw_fries(image: Image):
	var carton := Color(0.82, 0.12, 0.16)
	var carton_d := Color(0.58, 0.08, 0.10)
	var fry := Color(0.96, 0.78, 0.22)
	var fry_d := Color(0.82, 0.55, 0.10)
	_rect(image, 8, 16, 16, 12, carton)
	_hline(image, 8, 23, 16, carton_d)
	for i in 5:
		var x := 10 + i * 3
		var top := 5 + (i % 3)
		_rect(image, x, top, 2, 14, fry if i % 2 == 0 else fry_d)

func _draw_onion_rings(image: Image):
	var gold := Color(0.90, 0.68, 0.18)
	var gold_d := Color(0.72, 0.48, 0.10)
	_ring(image, 11, 13, 6, 3, gold)
	_ring(image, 20, 17, 6, 3, gold_d)
	_ring(image, 15, 23, 5, 2, gold)

func _draw_jam(image: Image):
	var jam := Color(0.72, 0.08, 0.18)
	var glass := Color(0.78, 0.88, 0.86)
	var lid := Color(0.80, 0.66, 0.18)
	var label := Color(0.96, 0.90, 0.82)
	_rect(image, 10, 12, 12, 16, jam)
	_rect(image, 10, 12, 12, 3, glass)
	_rect(image, 11, 9, 10, 3, lid)
	_rect(image, 12, 18, 8, 5, label)
	_disc(image, 16, 20, 2, jam)

func _draw_hot_sauce(image: Image):
	var sauce := Color(0.78, 0.08, 0.08)
	var cap := Color(0.18, 0.18, 0.20)
	var label := Color(0.96, 0.84, 0.16)
	_rect(image, 13, 8, 6, 3, cap)
	_rect(image, 14, 11, 4, 4, sauce)
	_rect(image, 12, 15, 8, 13, sauce)
	_rect(image, 13, 19, 6, 4, label)
	_px(image, 16, 6, cap)

func _draw_oil(image: Image):
	var oil := Color(0.96, 0.80, 0.18)
	var glass := Color(0.86, 0.90, 0.72)
	var cap := Color(0.28, 0.28, 0.30)
	_rect(image, 13, 8, 6, 3, cap)
	_rect(image, 12, 11, 8, 4, glass)
	_rect(image, 11, 15, 10, 13, oil)
	_disc(image, 16, 20, 2, Color(0.98, 0.88, 0.30))

func _draw_wine(image: Image):
	var wine := Color(0.38, 0.06, 0.16)
	var glass := Color(0.68, 0.80, 0.76)
	var foil := Color(0.70, 0.54, 0.14)
	_rect(image, 14, 5, 4, 3, foil)
	_rect(image, 14, 8, 4, 6, glass)
	_rect(image, 11, 14, 10, 14, wine)
	_px(image, 13, 14, wine)
	_px(image, 18, 14, wine)

func _draw_cider(image: Image):
	var mug := Color(0.90, 0.90, 0.92)
	var cider := Color(0.80, 0.38, 0.10)
	var foam := Color(0.98, 0.88, 0.52)
	_rect(image, 6, 11, 17, 17, mug)
	_rect(image, 8, 13, 13, 12, cider)
	_rect(image, 8, 13, 13, 3, foam)
	_rect(image, 22, 15, 5, 9, mug)
	_px(image, 10, 14, foam.lightened(0.1))
	_px(image, 14, 14, foam.lightened(0.1))

func _draw_melon_juice(image: Image):
	var juice := Color(0.90, 0.20, 0.34)
	var glass := Color(0.78, 0.88, 0.86)
	var straw := Color(0.20, 0.70, 0.30)
	var rind := Color(0.16, 0.56, 0.24)
	_rect(image, 9, 12, 13, 16, juice)
	_rect(image, 9, 12, 13, 3, glass)
	_vline(image, 20, 4, 16, straw)
	_vline(image, 21, 4, 16, straw)
	# tiny wedge garnish
	_px(image, 22, 10, rind)
	_px(image, 23, 10, rind)
	_px(image, 23, 11, juice)
	_px(image, 24, 11, rind)

func _draw_coffee_cup(image: Image):
	var cup := Color(0.94, 0.94, 0.92)
	var coffee := Color(0.26, 0.14, 0.08)
	var steam := Color(0.84, 0.84, 0.86)
	_rect(image, 7, 14, 16, 13, cup)
	_rect(image, 9, 16, 12, 8, coffee)
	_rect(image, 22, 17, 4, 7, cup)
	_px(image, 12, 7, steam)
	_px(image, 13, 6, steam)
	_px(image, 13, 8, steam)
	_px(image, 17, 6, steam)
	_px(image, 18, 5, steam)
	_px(image, 18, 7, steam)

func _draw_blueberry(image: Image):
	var berry := Color(0.22, 0.28, 0.72)
	var berry_l := Color(0.38, 0.42, 0.88)
	var crown := Color(0.42, 0.72, 0.32)
	var berries := [Vector2i(12, 18), Vector2i(18, 16), Vector2i(16, 22), Vector2i(21, 21)]
	for i in berries.size():
		var b: Vector2i = berries[i]
		_disc(image, b.x, b.y, 3 if i < 3 else 2, berry_l if i % 2 == 0 else berry)
		_px(image, b.x - 1, b.y - 1, berry_l.lightened(0.15))
		_px(image, b.x, b.y - 3, crown)

func _draw_peach(image: Image):
	var flesh := Color(1.0, 0.62, 0.42)
	var blush := Color(0.96, 0.42, 0.36)
	var hi := Color(1.0, 0.78, 0.55)
	var stem := Color(0.42, 0.28, 0.12)
	var leaf := Color(0.32, 0.72, 0.28)
	_ellipse(image, 16, 18, 9, 8, flesh)
	_disc(image, 12, 16, 3, hi)
	_disc(image, 20, 20, 4, blush)
	_vline(image, 16, 8, 11, stem)
	_px(image, 17, 9, leaf)
	_px(image, 18, 8, leaf)
	_px(image, 19, 9, leaf)
	_px(image, 18, 10, leaf)

func _draw_bread(image: Image):
	var crust := Color(0.72, 0.48, 0.22)
	var loaf := Color(0.86, 0.68, 0.38)
	var crumb := Color(0.62, 0.40, 0.18)
	_rect(image, 7, 14, 18, 10, loaf)
	_rect(image, 8, 12, 16, 3, crust)
	_px(image, 11, 16, crumb)
	_px(image, 15, 17, crumb)
	_px(image, 19, 16, crumb)
	_px(image, 13, 19, crumb)

func _draw_blueberry_muffin(image: Image):
	var paper := Color(0.86, 0.78, 0.62)
	var cake := Color(0.82, 0.62, 0.32)
	var top := Color(0.72, 0.48, 0.22)
	var berry := Color(0.28, 0.32, 0.78)
	_rect(image, 10, 16, 12, 10, paper)
	_disc(image, 16, 14, 7, cake)
	_rect(image, 10, 14, 12, 3, top)
	_px(image, 13, 12, berry)
	_px(image, 17, 11, berry)
	_px(image, 19, 14, berry)
	_px(image, 15, 15, berry)

func _draw_peach_preserve(image: Image):
	var jam := Color(1.0, 0.55, 0.32)
	var jam_d := Color(0.92, 0.42, 0.22)
	var glass := Color(0.86, 0.90, 0.82)
	var lid := Color(0.86, 0.82, 0.74)
	_rect(image, 11, 12, 10, 14, jam)
	_rect(image, 11, 12, 10, 3, glass)
	_rect(image, 10, 9, 12, 3, lid)
	_px(image, 14, 17, jam_d)
	_px(image, 16, 19, jam_d)
	_px(image, 18, 17, jam_d)

func _draw_cherry(image: Image):
	var red := Color(0.78, 0.08, 0.18)
	var hi := Color(0.94, 0.28, 0.32)
	var stem := Color(0.28, 0.52, 0.18)
	_disc(image, 12, 20, 5, red)
	_disc(image, 20, 18, 5, red)
	_px(image, 10, 18, hi)
	_px(image, 18, 16, hi)
	_px(image, 16, 8, stem)
	_px(image, 15, 9, stem)
	_px(image, 14, 10, stem)
	_px(image, 17, 9, stem)
	_px(image, 18, 10, stem)
	_px(image, 12, 14, stem)
	_px(image, 20, 13, stem)

func _draw_cocoa(image: Image):
	var pod := Color(0.42, 0.22, 0.12)
	var ridge := Color(0.28, 0.14, 0.08)
	var leaf := Color(0.24, 0.52, 0.20)
	_ellipse(image, 16, 18, 7, 10, pod)
	_vline(image, 16, 10, 26, ridge)
	_px(image, 13, 14, ridge)
	_px(image, 19, 14, ridge)
	_px(image, 13, 20, ridge)
	_px(image, 19, 20, ridge)
	_px(image, 14, 6, leaf)
	_px(image, 15, 5, leaf)
	_px(image, 16, 6, leaf)
	_px(image, 17, 5, leaf)

func _draw_avocado(image: Image):
	var skin := Color(0.28, 0.52, 0.22)
	var flesh := Color(0.72, 0.82, 0.36)
	var pit := Color(0.42, 0.26, 0.12)
	_ellipse(image, 16, 17, 8, 10, skin)
	_ellipse(image, 16, 17, 5, 7, flesh)
	_disc(image, 16, 17, 3, pit)

func _draw_truffle(image: Image):
	var body := Color(0.28, 0.22, 0.18)
	var bump := Color(0.36, 0.28, 0.22)
	var dirt := Color(0.48, 0.36, 0.22)
	_disc(image, 16, 18, 8, body)
	_disc(image, 11, 14, 3, bump)
	_disc(image, 21, 16, 3, bump)
	_disc(image, 14, 22, 2, bump)
	_px(image, 10, 20, dirt)
	_px(image, 22, 22, dirt)
	_px(image, 16, 12, dirt)

func _draw_saffron(image: Image):
	var petal := Color(0.92, 0.42, 0.12)
	var center := Color(0.96, 0.78, 0.18)
	var stem := Color(0.28, 0.52, 0.22)
	_vline(image, 16, 16, 28, stem)
	_px(image, 15, 12, petal)
	_px(image, 16, 10, petal)
	_px(image, 17, 12, petal)
	_px(image, 14, 14, petal)
	_px(image, 18, 14, petal)
	_px(image, 13, 16, petal)
	_px(image, 19, 16, petal)
	_disc(image, 16, 14, 2, center)

func _draw_cherry_syrup(image: Image):
	var syrup := Color(0.72, 0.08, 0.22)
	var glass := Color(0.82, 0.90, 0.88)
	var cap := Color(0.86, 0.82, 0.74)
	_rect(image, 12, 10, 8, 16, syrup)
	_rect(image, 12, 10, 8, 3, glass)
	_rect(image, 11, 7, 10, 3, cap)
	_px(image, 14, 18, Color(0.90, 0.20, 0.30))
	_px(image, 16, 20, Color(0.90, 0.20, 0.30))

func _draw_chocolate(image: Image):
	var bar := Color(0.32, 0.16, 0.08)
	var seam := Color(0.22, 0.10, 0.05)
	var wrap := Color(0.86, 0.72, 0.28)
	_rect(image, 8, 12, 16, 12, bar)
	_hline(image, 8, 23, 18, seam)
	_vline(image, 16, 12, 23, seam)
	_rect(image, 8, 10, 16, 2, wrap)

func _draw_guacamole(image: Image):
	var bowl := Color(0.86, 0.82, 0.74)
	var guac := Color(0.42, 0.68, 0.28)
	var chunk := Color(0.28, 0.52, 0.18)
	_ellipse(image, 16, 20, 10, 6, bowl)
	_disc(image, 16, 16, 8, guac)
	_px(image, 13, 14, chunk)
	_px(image, 18, 15, chunk)
	_px(image, 16, 18, chunk)

func _draw_truffle_oil(image: Image):
	var oil := Color(0.36, 0.30, 0.18)
	var glass := Color(0.78, 0.82, 0.70)
	var cap := Color(0.22, 0.20, 0.18)
	_rect(image, 13, 8, 6, 3, cap)
	_rect(image, 12, 11, 8, 15, oil)
	_rect(image, 12, 11, 8, 3, glass)
	_px(image, 15, 18, Color(0.48, 0.40, 0.24))

func _draw_saffron_tea(image: Image):
	var tea := Color(0.96, 0.62, 0.18)
	var cup := Color(0.94, 0.94, 0.92)
	var steam := Color(0.86, 0.86, 0.88)
	_rect(image, 8, 14, 14, 12, cup)
	_rect(image, 10, 16, 10, 8, tea)
	_rect(image, 22, 17, 4, 6, cup)
	_px(image, 12, 8, steam)
	_px(image, 13, 7, steam)
	_px(image, 17, 7, steam)
	_px(image, 18, 6, steam)

func _cloud(image: Image, cx: int, cy: int, r: int):
	_disc(image, cx, cy, r, Color(1, 1, 1, 0.88))
	_disc(image, cx + r, cy + 2, int(r * 0.7), Color(1, 1, 1, 0.82))
	_disc(image, cx - r + 2, cy + 3, int(r * 0.55), Color(1, 1, 1, 0.8))

func _px(image: Image, x: int, y: int, color: Color):
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)

func _rect(image: Image, x: int, y: int, w: int, h: int, color: Color):
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			_px(image, xx, yy, color)

func _hline(image: Image, x1: int, x2: int, y: int, color: Color):
	for x in range(mini(x1, x2), maxi(x1, x2) + 1):
		_px(image, x, y, color)

func _vline(image: Image, x: int, y1: int, y2: int, color: Color):
	for y in range(mini(y1, y2), maxi(y1, y2) + 1):
		_px(image, x, y, color)

func _disc(image: Image, cx: int, cy: int, r: int, color: Color):
	for y in range(cy - r, cy + r + 1):
		for x in range(cx - r, cx + r + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r:
				_px(image, x, y, color)

func _ellipse(image: Image, cx: int, cy: int, rx: int, ry: int, color: Color):
	for y in range(cy - ry, cy + ry + 1):
		for x in range(cx - rx, cx + rx + 1):
			var dx := float(x - cx) / float(rx)
			var dy := float(y - cy) / float(ry)
			if dx * dx + dy * dy <= 1.0:
				_px(image, x, y, color)

func _ring(image: Image, cx: int, cy: int, outer_r: int, inner_r: int, color: Color):
	for y in range(cy - outer_r, cy + outer_r + 1):
		for x in range(cx - outer_r, cx + outer_r + 1):
			var d2 := (x - cx) * (x - cx) + (y - cy) * (y - cy)
			if d2 <= outer_r * outer_r and d2 >= inner_r * inner_r:
				_px(image, x, y, color)

func _add_outline(image: Image, outline: Color):
	var w := image.get_width()
	var h := image.get_height()
	var copy := image.duplicate()
	for y in h:
		for x in w:
			if copy.get_pixel(x, y).a < 0.1:
				continue
			for oy in range(-1, 2):
				for ox in range(-1, 2):
					var nx := x + ox
					var ny := y + oy
					if nx < 0 or ny < 0 or nx >= w or ny >= h:
						continue
					if copy.get_pixel(nx, ny).a < 0.1:
						image.set_pixel(nx, ny, outline)
