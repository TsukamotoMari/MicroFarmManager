# Mockup Art Pipeline (v1.1)

## Goal
Replace procedural-only art with Premium 16-bit Retro sprites from the mockup.

## Folders
- `assets/art/` — mockup references + source atlases
- `assets/sprites/` — sliced runtime PNGs (nearest-neighbor)

## Tools
```powershell
python tools/slice_atlas.py
python tools/slice_soil_tiles.py
```

## Runtime
`SpriteBank` loads `res://assets/sprites/<id>.png`.
`PixelArtGenerator` prefers sheet sprites, then falls back to procedural drawing.

## Next passes
1. Replace wood UI panels / crop chips with cleaner dedicated tiles
2. Per-crop growth stage sheets (not shared sprout/plant/tall)
3. Parallax farm background baked from the mockup
4. Tab icons matching Market / Farm / Robots / Upgrades mockup
