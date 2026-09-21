from PIL import Image
import os

SRC = r"C:\Users\clubn\.cursor\projects\f-devinaigames-MicroFarmManager\assets\mfm-soil-tiles.png"
OUT = r"F:\devinaigames\MicroFarmManager\assets\sprites"
REF = r"F:\devinaigames\MicroFarmManager\assets\art"


def clear_magenta(im: Image.Image) -> Image.Image:
	c = im.convert("RGBA")
	px = c.load()
	w, h = c.size
	for y in range(h):
		for x in range(w):
			r, g, b, a = px[x, y]
			# Magenta or hot-pink chroma key
			if (r > 180 and g < 100 and b > 180) or (r > 180 and g < 60 and 80 < b < 180 and r > g + 80):
				px[x, y] = (0, 0, 0, 0)
	return c


def main() -> None:
	os.makedirs(OUT, exist_ok=True)
	os.makedirs(REF, exist_ok=True)
	im = Image.open(SRC).convert("RGBA")
	im.save(os.path.join(REF, "mfm-soil-tiles.png"))
	im = clear_magenta(im)
	w, h = im.size
	# Detect content bbox then split 2x2
	bbox = im.getbbox()
	crop = im.crop(bbox)
	cw, ch = crop.size[0] // 2, crop.size[1] // 2
	names = [
		("dry_soil", 0, 0),
		("wet_soil", 1, 0),
		("locked_plot", 0, 1),
		("empty_dirt", 1, 1),
	]
	for name, col, row in names:
		cell = crop.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
		# trim leftover magenta/transparent edges
		px = cell.load()
		for y in range(cell.size[1]):
			for x in range(cell.size[0]):
				r, g, b, a = px[x, y]
				if r > 200 and g < 100 and b > 200:
					px[x, y] = (0, 0, 0, 0)
		bb = cell.getbbox()
		if bb:
			cell = cell.crop(bb)
		out = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
		scaled = cell.resize((48, 48), Image.NEAREST)
		out.paste(scaled, (0, 0), scaled)
		path = os.path.join(OUT, f"{name}.png")
		out.save(path)
		print("wrote", path, out.size)


if __name__ == "__main__":
	main()
