extends RefCounted
class_name PixelArtGenerator

const OUTLINE := Color(0.14, 0.08, 0.05, 0.95)

func create_crop_sprite(crop_type: String, color: Color) -> Image:
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
		"watermelon":
			_draw_watermelon(image)
		"coffee":
			_draw_coffee_cherries(image)
		_:
			_disc(image, 16, 16, 7, color)
	_add_outline(image, OUTLINE)
	return image

func create_product_sprite(product_id: String, fallback_color: Color = Color.WHITE) -> Image:
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
		_:
			_disc(image, 16, 16, 7, fallback_color)
	_add_outline(image, OUTLINE)
	return image

func create_plot_sprite() -> Image:
	var image := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	for y in 48:
		for x in 48:
			var n := sin(x * 0.35) * 0.04 + cos(y * 0.28) * 0.03
			var edge := mini(mini(x, y), mini(47 - x, 47 - y))
			if edge < 5:
				image.set_pixel(x, y, Color(0.32 + n, 0.58 + n, 0.26 + n))
			else:
				var furrow := -0.07 if y % 6 < 2 else 0.0
				image.set_pixel(x, y, Color(0.50 + n + furrow, 0.32 + n * 0.5, 0.16 + n * 0.3))
	for i in 4:
		image.set_pixel(3 + i, 3, Color(0.28, 0.16, 0.08))
		image.set_pixel(3, 3 + i, Color(0.28, 0.16, 0.08))
		image.set_pixel(44 - i, 3, Color(0.28, 0.16, 0.08))
		image.set_pixel(44, 3 + i, Color(0.28, 0.16, 0.08))
	for p in [Vector2i(8, 2), Vector2i(22, 1), Vector2i(36, 2), Vector2i(2, 20), Vector2i(45, 18)]:
		_px(image, p.x, p.y, Color(0.28, 0.62, 0.24))
		_px(image, p.x, p.y - 1, Color(0.40, 0.72, 0.30))
	return image

func create_locked_plot_sprite() -> Image:
	var image := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	for y in 48:
		for x in 48:
			var n := sin(x * 0.22 + y * 0.18) * 0.04
			var tuft := 0.05 if int(x * 3 + y * 5) % 11 == 0 else 0.0
			image.set_pixel(x, y, Color(0.28 + n, 0.46 + n + tuft, 0.22 + n))
	for i in 48:
		if i % 4 < 2:
			_px(image, i, 0, Color(0.20, 0.34, 0.16))
			_px(image, i, 47, Color(0.20, 0.34, 0.16))
			_px(image, 0, i, Color(0.20, 0.34, 0.16))
			_px(image, 47, i, Color(0.20, 0.34, 0.16))
	for p in [Vector2i(12, 18), Vector2i(30, 14), Vector2i(22, 28), Vector2i(36, 32)]:
		_px(image, p.x, p.y, Color(0.42, 0.36, 0.24))
		_px(image, p.x + 1, p.y, Color(0.50, 0.44, 0.30))
	return image

func create_background(width: int, height: int) -> Image:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var horizon := int(height * 0.34)
	for y in height:
		var t := float(y) / float(height)
		var color: Color
		if y < horizon:
			color = Color(0.45, 0.74, 0.93).lerp(Color(0.78, 0.90, 0.98), float(y) / horizon)
		else:
			var g := (t - 0.34) / 0.66
			color = Color(0.40, 0.68, 0.34).lerp(Color(0.22, 0.46, 0.22), g)
			if int(y + sin(y * 0.2) * 2) % 9 == 0:
				color = color.darkened(0.06)
		for x in width:
			var n := 0.0
			if y >= horizon:
				n = sin((x + y) * 0.07) * 0.03
			image.set_pixel(x, y, Color(color.r + n, color.g + n, color.b + n * 0.5))
	_disc(image, width - 28, 22, 10, Color(1.0, 0.92, 0.55))
	_disc(image, width - 28, 22, 6, Color(1.0, 0.97, 0.78))
	_cloud(image, 28, 26, 16)
	_cloud(image, int(width * 0.42), 18, 12)
	for x in width:
		var h1 := horizon - 18 - int(sin(x * 0.035) * 10 + cos(x * 0.02) * 6)
		for y in range(h1, horizon):
			image.set_pixel(x, y, Color(0.30, 0.55, 0.32))
		var h2 := horizon - 8 - int(sin(x * 0.05 + 1.2) * 6)
		for y in range(h2, horizon):
			image.set_pixel(x, y, Color(0.36, 0.62, 0.34))
	return image

func create_coin_icon() -> Image:
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_disc(image, 12, 12, 9, Color(0.62, 0.40, 0.08))
	_disc(image, 12, 12, 8, Color(0.96, 0.76, 0.22))
	_disc(image, 10, 10, 3, Color(1.0, 0.93, 0.58))
	_px(image, 12, 9, Color(0.72, 0.48, 0.10))
	_px(image, 12, 10, Color(0.72, 0.48, 0.10))
	_px(image, 12, 14, Color(0.72, 0.48, 0.10))
	_px(image, 12, 15, Color(0.72, 0.48, 0.10))
	_add_outline(image, Color(0.35, 0.22, 0.05))
	return image

func create_robot_sprite() -> Image:
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
