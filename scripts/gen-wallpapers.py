"""Generate a wallpaper per theme from its palette (theme.env).

Night sky glow + moon + layered ridgelines + faint dot grid, all in the theme's colors.
Run:  uv run --with pillow --with numpy scripts/gen-wallpapers.py
"""

import math
import pathlib
import random
import zlib

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

W, H = 3840, 2160
THEMES = pathlib.Path(__file__).resolve().parent.parent / "home/dot_config/omachy/themes"


def palette(env: pathlib.Path) -> dict[str, np.ndarray]:
    colors = {}
    for line in env.read_text().splitlines():
        key, _, value = line.partition("=")
        value = value.strip().strip('"')
        if len(value) == 6 and all(c in "0123456789abcdefABCDEF" for c in value):
            colors[key] = np.array([int(value[i : i + 2], 16) for i in (0, 2, 4)], dtype=np.float32)
    return colors


def glow(canvas: np.ndarray, cx: float, cy: float, radius: float, color: np.ndarray, strength: float) -> None:
    yy, xx = np.ogrid[:H, :W]
    d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / radius
    a = (np.clip(1 - d, 0, 1) ** 2.2 * strength)[..., None]
    canvas[:] = canvas * (1 - a) + color * a


def ridge(seed: int, base: float, amp: float) -> list[tuple[float, float]]:
    rnd = random.Random(seed)
    waves = [(rnd.uniform(0.5, 3.5), rnd.uniform(0, math.tau), rnd.uniform(0.3, 1.0)) for _ in range(5)]
    waves += [(rnd.uniform(6, 18), rnd.uniform(0, math.tau), rnd.uniform(0.05, 0.15)) for _ in range(6)]
    norm = sum(w[2] for w in waves)
    pts = []
    for x in range(0, W + 16, 16):
        t = x / W
        y = sum(a * math.sin(f * math.tau * t + p) for f, p, a in waves) / norm
        pts.append((x, H * base - y * H * amp))
    return [(0, H)] + pts + [(W, H)]


def render(name: str, c: dict[str, np.ndarray]) -> Image.Image:
    yy, xx = np.mgrid[:H, :W].astype(np.float32)
    t = ((xx / W) * 0.35 + (yy / H) * 0.65)[..., None]
    img = c["BG"] * (1 - t) + c["BG_DARK"] * t

    glow(img, W * 0.78, H * 0.30, W * 0.55, c["ACCENT"], 0.22)
    glow(img, W * 0.15, H * 0.10, W * 0.45, c["ACCENT2"], 0.18)
    glow(img, W * 0.55, H * 0.85, W * 0.40, c["CYAN"], 0.08)

    # Moon with halo.
    mx, my, mr = W * 0.74, H * 0.24, H * 0.06
    glow(img, mx, my, mr * 5, c["FG"], 0.09)
    d = np.sqrt((xx - mx) ** 2 + (yy - my) ** 2)
    moon = np.clip((mr - d) / 3, 0, 1)[..., None]
    lit = np.clip(1 - np.sqrt((xx - (mx - mr * 0.45)) ** 2 + (yy - (my - mr * 0.45)) ** 2) / (mr * 2.2), 0, 1)[..., None]
    moon_col = c["FG"] * (0.72 + 0.28 * lit) + c["ACCENT"] * (1 - lit) * 0.12
    img = img * (1 - moon * 0.8) + moon_col * moon * 0.8

    out = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8))

    # Faint stars / dot grid in the sky.
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    rnd = random.Random(name)
    muted = tuple(int(v) for v in c["FG"])
    for _ in range(420):
        x, y = rnd.uniform(0, W), rnd.uniform(0, H * 0.6)
        r = rnd.choice([1.5, 2, 2.5, 3.5])
        if math.hypot(x - mx, y - my) < mr * 1.15:
            continue
        draw.ellipse((x - r, y - r, x + r, y + r), fill=muted + (rnd.randint(40, 140),))
    out = Image.alpha_composite(out.convert("RGBA"), layer)

    # Three ridgelines, far → near, fading into the dark base.
    for i, (base, amp, mix) in enumerate([(0.66, 0.11, 0.60), (0.77, 0.08, 0.30), (0.89, 0.05, 0.0)]):
        col = c["BG_HL"] * mix + c["BG_DARK"] * (1 - mix)
        col = col * (1 - mix * 0.35) + c["ACCENT"] * mix * 0.35 * 0.45 + col * mix * 0.35 * 0.55  # blue haze far away
        ridge_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(ridge_layer).polygon(ridge(zlib.crc32(f"{name}{i}".encode()), base, amp), fill=tuple(int(v) for v in col) + (255,))
        ridge_layer = ridge_layer.filter(ImageFilter.GaussianBlur(1.2))
        out = Image.alpha_composite(out, ridge_layer)

    # Fine grain prevents gradient banding.
    arr = np.asarray(out.convert("RGB")).astype(np.float32)
    arr += np.random.default_rng(7).normal(0, 2.2, arr.shape[:2])[..., None]
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))


def main() -> None:
    for env in sorted(THEMES.glob("*/theme.env")):
        img = render(env.parent.name, palette(env))
        dest = env.parent / "wallpaper.jpg"
        img.save(dest, quality=92, optimize=True, progressive=True)
        print(f"{dest.relative_to(THEMES.parent.parent.parent.parent)}  {dest.stat().st_size // 1024} KiB")


if __name__ == "__main__":
    main()
