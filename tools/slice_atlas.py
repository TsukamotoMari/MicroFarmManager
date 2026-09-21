from PIL import Image
import os

SRC = r"C:\Users\clubn\.cursor\projects\f-devinaigames-MicroFarmManager\assets\mfm-atlas-clean.png"
OUT = r"F:\devinaigames\MicroFarmManager\assets\sprites"
REF_OUT = r"F:\devinaigames\MicroFarmManager\assets\art"

NAMES = [
	"dry_soil", "wet_soil", "locked_plot", "empty_dirt", "wood_panel", "wood_panel_hi", "chip", "chip_selected",
	"fence_post", "fence_rail", "barn", "windmill", "grass", "stone", "wood_frame", "rivet",
	"wheat", "cabbage", "potato", "carrot", "onion", "strawberry", "corn", "tomato",
	"pumpkin", "pepper", "sunflower", "grape", "apple", "watermelon", "watermelon_slice", "coffee",
	"sprout", "plant", "tall", "ready_wheat", "coin", "water", "energy", "robot",
	"flour", "popcorn", "carrot_cake", "tomato_sauce", "pumpkin_pie", "fries", "jam", "wine",
]

SIZE_OVERRIDES = {
	"dry_soil": (48, 48),
	"wet_soil": (48, 48),
	"locked_plot": (48, 48),
	"empty_dirt": (48, 48),
	"wood_panel": (64, 64),
	"wood_panel_hi": (64, 64),
	"chip": (48, 48),
	"chip_selected": (48, 48),
	"coin": (24, 24),
	"water": (24, 24),
	"energy": (24, 24),
	"robot": (32, 32),
}


def is_magenta(r: int, g: int, b: int) -> bool:
	return r > 200 and g < 90 and b > 200


def is_pure_black(r: int, g: int, b: int) -> bool:
	return r <= 8 and g <= 8 and b <= 8


def clear_bg(cell: Image.Image) -> Image.Image:
	c = cell.convert("RGBA")
	px = c.load()
	w, h = c.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			if is_magenta(r, g, b) or is_pure_black(r, g, b):
				px[x, y] = (0, 0, 0, 0)
	bbox = c.getbbox()
	return c.crop(bbox) if bbox else c


def fit_nearest(src: Image.Image, tw: int, th: int) -> Image.Image:
	out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
	if src.size[0] == 0 or src.size[1] == 0:
		return out
	scale = min(tw / src.size[0], th / src.size[1])
	nw = max(1, int(round(src.size[0] * scale)))
	nh = max(1, int(round(src.size[1] * scale)))
	resized = src.resize((nw, nh), Image.NEAREST)
	ox = (tw - nw) // 2
	oy = (th - nh) // 2
	out.paste(resized, (ox, oy), resized)
	return out


def main() -> None:
	os.makedirs(OUT, exist_ok=True)
	os.makedirs(REF_OUT, exist_ok=True)
	im = Image.open(SRC).convert("RGBA")
	im.save(os.path.join(REF_OUT, "mfm-atlas-clean.png"))
	w, h = im.size
	cols, rows = 8, 6
	cw, ch = w // cols, h // rows
	# Inset past magenta gutters if present.
	inset = 4
	print(f"atlas {w}x{h} cell {cw}x{ch} inset {inset}")
	assert len(NAMES) == 48
	for i, name in enumerate(NAMES):
		col, row = i % 8, i // 8
		x0 = col * cw + inset
		y0 = row * ch + inset
		x1 = (col + 1) * cw - inset
		y1 = (row + 1) * ch - inset
		cell = im.crop((x0, y0, x1, y1))
		cell = clear_bg(cell)
		tw, th = SIZE_OVERRIDES.get(name, (32, 32))
		cell = fit_nearest(cell, tw, th)
		path = os.path.join(OUT, f"{name}.png")
		cell.save(path)
		print(name, cell.size, "opaque%", round(100 * sum(1 for p in cell.getdata() if p[3] > 0) / (tw * th), 1))
	print("wrote", OUT)


if __name__ == "__main__":
	main()
