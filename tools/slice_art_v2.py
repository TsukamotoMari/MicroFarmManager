from PIL import Image
import os

SPRITES = r"F:\devinaigames\MicroFarmManager\assets\sprites"
ART = r"F:\devinaigames\MicroFarmManager\assets\art"
os.makedirs(SPRITES, exist_ok=True)
os.makedirs(ART, exist_ok=True)


def key_out(im: Image.Image) -> Image.Image:
	c = im.convert("RGBA")
	px = c.load()
	w, h = c.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			# magenta / hot pink chroma keys
			if (r > 180 and g < 100 and b > 180) or (r > 180 and g < 70 and 70 < b < 190 and r > g + 70):
				px[x, y] = (0, 0, 0, 0)
			elif r < 12 and g < 12 and b < 12:
				px[x, y] = (0, 0, 0, 0)
	return c


def fit(src: Image.Image, tw: int, th: int) -> Image.Image:
	out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
	if src.getbbox() is None:
		return out
	src = src.crop(src.getbbox())
	scale = min(tw / src.size[0], th / src.size[1])
	nw = max(1, int(round(src.size[0] * scale)))
	nh = max(1, int(round(src.size[1] * scale)))
	resized = src.resize((nw, nh), Image.NEAREST)
	out.paste(resized, ((tw - nw) // 2, (th - nh) // 2), resized)
	return out


def split_grid(path: str, cols: int, rows: int, names: list, sizes: dict, save_as: str):
	im = Image.open(path).convert("RGBA")
	im.save(os.path.join(ART, save_as))
	im = key_out(im)
	bbox = im.getbbox()
	if not bbox:
		raise RuntimeError("empty after key: " + path)
	im = im.crop(bbox)
	cw, ch = im.size[0] // cols, im.size[1] // rows
	for i, name in enumerate(names):
		col, row = i % cols, i // cols
		cell = im.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
		cell = key_out(cell)
		tw, th = sizes.get(name, (32, 32))
		out = fit(cell, tw, th)
		out.save(os.path.join(SPRITES, f"{name}.png"))
		print("wrote", name, out.size)


def main():
	split_grid(
		r"C:\Users\clubn\.cursor\projects\f-devinaigames-MicroFarmManager\assets\mfm-soil-v2.png",
		2, 2,
		["dry_soil", "wet_soil", "locked_plot", "empty_dirt"],
		{"dry_soil": (48, 48), "wet_soil": (48, 48), "locked_plot": (48, 48), "empty_dirt": (48, 48)},
		"mfm-soil-v2.png",
	)
	split_grid(
		r"C:\Users\clubn\.cursor\projects\f-devinaigames-MicroFarmManager\assets\mfm-ui-v2.png",
		8, 1,
		["wood_panel", "wood_panel_hi", "chip", "chip_selected", "coin", "water", "energy", "robot"],
		{
			"wood_panel": (64, 64), "wood_panel_hi": (64, 64),
			"chip": (48, 48), "chip_selected": (48, 48),
			"coin": (24, 24), "water": (24, 24), "energy": (24, 24), "robot": (32, 32),
		},
		"mfm-ui-v2.png",
	)
	split_grid(
		r"C:\Users\clubn\.cursor\projects\f-devinaigames-MicroFarmManager\assets\mfm-crops-v2.png",
		16, 1,
		[
			"wheat", "cabbage", "potato", "carrot", "onion", "strawberry", "tomato", "pepper",
			"sunflower", "corn", "grape", "apple", "pumpkin", "watermelon", "coffee", "sprout",
		],
		{},
		"mfm-crops-v2.png",
	)
	# growth aliases
	for src, dst in [("sprout", "plant"), ("sprout", "tall")]:
		# plant/tall: slightly different scales of sprout until dedicated stages exist
		im = Image.open(os.path.join(SPRITES, f"{src}.png")).convert("RGBA")
		if dst == "plant":
			im = fit(im, 28, 28)
			canvas = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
			canvas.paste(im, (2, 4), im)
			im = canvas
		else:
			im = fit(im, 32, 32)
		im.save(os.path.join(SPRITES, f"{dst}.png"))
		print("alias", dst)
	print("done")


if __name__ == "__main__":
	main()
