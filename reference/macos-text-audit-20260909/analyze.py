"""Analyze actual Factor/Core Text/GL3 captures; Pillow only makes the contact sheet."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
records = [json.loads(line) for line in (ROOT / "probe.jsonl").read_text().splitlines()
           if line.startswith("[")]
records = {row[0]: row[1:] for row in records}
results = {}
for label in ("1x", "2x"):
    (w, h), *_ = records[label]
    source = (ROOT / f"{label}-source.bgra").read_bytes()
    captures = {variant: (ROOT / f"{label}-{variant}.rgba").read_bytes()
                for variant in ("current", "reference", "half-pixel", "native-phase")}
    current, reference = captures["current"], captures["reference"]
    def changed(a, b):
        return sum(a[i:i+3] != b[i:i+3] for i in range(0, len(a), 4))
    results[label] = {
        "dimensions": [w, h],
        "intermediate_alpha_pixels": sum(0 < a < 255 for a in source[3::4]),
        "unequal_rgb_pixels": sum(len(set(source[i:i+3])) != 1
                                  for i in range(0, len(source), 4)),
        "blend_changed_rgb_pixels": changed(current, reference),
        "blend_max_rgb_error": max(abs(current[i] - reference[i])
                                   for i in range(len(source)) if i % 4 != 3),
        "reference_source_max_error": max(
            abs(source[((h-1-y)*w+x)*4] - reference[(y*w+x)*4])
            for y in range(h) for x in range(w)),
        "half_pixel_changed_rgb_pixels": changed(captures["half-pixel"], reference),
        "filtered_vs_native_phase_changed_rgb_pixels": changed(
            captures["half-pixel"], captures["native-phase"]),
    }

for label in ("bounds-italic-2x", "bounds-emoji-2x"):
    (w, h), *_ = records[label]
    source = (ROOT / f"{label}-source.bgra").read_bytes()
    padded = (ROOT / f"{label}-padded.bgra").read_bytes()
    pw, ph = w+32, h+32
    results[label] = {
        "clipped_pixels": [
            {"x": x-16, "y": y-16, "alpha": padded[(y*pw+x)*4+3]}
            for y in range(ph) for x in range(pw)
            if not (16 <= x < w+16 and 16 <= y < h+16)
            and padded[(y*pw+x)*4+3]],
        "interior_mismatches": sum(
            source[(y*w+x)*4:(y*w+x)*4+4] !=
            padded[((y+16)*pw+x+16)*4:((y+16)*pw+x+16)*4+4]
            for y in range(h) for x in range(w)),
    }
results["spaces-selection"] = records["spaces-selection"]
results["long-line"] = records["long-line"]
(ROOT / "results.json").write_text(json.dumps(results, indent=2) + "\n")
print(json.dumps(results, indent=2))

from PIL import Image, ImageDraw
height = sum(4 * (records[label][0][1]*3+12) for label in ("1x", "2x")) + 20
sheet = Image.new("RGB", (1300, height), (28, 28, 28))
draw = ImageDraw.Draw(sheet)
y = 10
for label in ("1x", "2x"):
    w, h = records[label][0]
    for variant in ("current", "reference", "half-pixel", "native-phase"):
        draw.text((8, y), f"{label} {variant}", fill="white")
        im = Image.frombytes("RGBA", (w, h), (ROOT / f"{label}-{variant}.rgba").read_bytes())
        im = im.transpose(Image.Transpose.FLIP_TOP_BOTTOM).convert("RGB")
        sheet.paste(im.resize((w*3, h*3), Image.Resampling.NEAREST), (175, y))
        y += h*3+12
sheet.save(ROOT / "comparison.png")
