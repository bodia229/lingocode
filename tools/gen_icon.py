"""Generate LingoCode launcher icons.

Produces three PNGs in assets/icon/:
- icon.png             — full 1024x1024 icon (used everywhere except Android adaptive)
- icon_foreground.png  — 1024x1024 transparent-bg version with ~25% safe area (Android adaptive)
- icon_background.png  — 1024x1024 solid-color background (Android adaptive)

Design: target/bullseye in white on a purple→pink diagonal gradient with a small
"Lc" wordmark — easy to recognise at any size, no font/emoji dependency.
"""
from __future__ import annotations
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "assets" / "icon"
OUT.mkdir(parents=True, exist_ok=True)

SIZE = 1024
RADIUS = 220  # corner radius for full icon

PURPLE = (103, 80, 164)   # #6750A4 - app seed color
PINK   = (255, 107, 157)  # #FF6B9D
CYAN   = (76, 201, 240)   # accent

def _gradient_bg(size: int) -> Image.Image:
    """Diagonal linear gradient PURPLE → PINK."""
    grad = Image.new("RGB", (size, size), PURPLE)
    px = grad.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size)
            r = int(PURPLE[0] * (1 - t) + PINK[0] * t)
            g = int(PURPLE[1] * (1 - t) + PINK[1] * t)
            b = int(PURPLE[2] * (1 - t) + PINK[2] * t)
            px[x, y] = (r, g, b)
    return grad

def _rounded_mask(size: int, radius: int) -> Image.Image:
    m = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    return m

def _draw_target(im: Image.Image, cx: int, cy: int, radius: int, *, ring_color=(255, 255, 255, 255)):
    """Draw a concentric-rings target."""
    d = ImageDraw.Draw(im, mode="RGBA")
    # Outer ring (largest), then alternate rings to create bullseye effect.
    ring_width = radius // 6
    for i, r in enumerate(range(radius, 0, -ring_width)):
        alpha = 255
        color = ring_color if i % 2 == 0 else (PURPLE[0], PURPLE[1], PURPLE[2], 0)
        if i % 2 == 0:
            d.ellipse((cx - r, cy - r, cx + r, cy + r),
                      outline=(ring_color[0], ring_color[1], ring_color[2], alpha),
                      width=ring_width)
        # last (center) — solid dot
    # Center bullseye dot
    dot = radius // 4
    d.ellipse((cx - dot, cy - dot, cx + dot, cy + dot),
              fill=(ring_color[0], ring_color[1], ring_color[2], 255))

def _wordmark(im: Image.Image, cx: int, baseline_y: int, *, text="Lc"):
    """Draw a tiny wordmark below the target."""
    font = None
    for candidate in (
        r"C:\Windows\Fonts\segoeuib.ttf",
        r"C:\Windows\Fonts\segoeui.ttf",
        r"C:\Windows\Fonts\arialbd.ttf",
    ):
        try:
            font = ImageFont.truetype(candidate, size=140)
            break
        except OSError:
            continue
    if font is None:
        font = ImageFont.load_default()
    d = ImageDraw.Draw(im, mode="RGBA")
    bbox = d.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    d.text((cx - w // 2, baseline_y - h // 2), text, fill=(255, 255, 255, 255), font=font)


def build_full() -> Image.Image:
    """Full icon: rounded gradient + target + wordmark."""
    bg = _gradient_bg(SIZE)
    icon = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    icon.paste(bg.convert("RGBA"), (0, 0), _rounded_mask(SIZE, RADIUS))
    _draw_target(icon, SIZE // 2, int(SIZE * 0.42), int(SIZE * 0.30))
    _wordmark(icon, SIZE // 2, int(SIZE * 0.82))
    return icon


def build_foreground() -> Image.Image:
    """Adaptive icon foreground: 1024 canvas, target sized inside the safe area (~66%)."""
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    _draw_target(fg, SIZE // 2, int(SIZE * 0.45), int(SIZE * 0.22))
    _wordmark(fg, SIZE // 2, int(SIZE * 0.74))
    return fg


def build_background() -> Image.Image:
    """Adaptive icon background: full-bleed gradient (no rounding — Android masks it)."""
    return _gradient_bg(SIZE).convert("RGBA")


def main() -> None:
    full = build_full()
    full.save(OUT / "icon.png", "PNG", optimize=True)
    build_foreground().save(OUT / "icon_foreground.png", "PNG", optimize=True)
    build_background().save(OUT / "icon_background.png", "PNG", optimize=True)
    print(f"Wrote {OUT/'icon.png'}, icon_foreground.png, icon_background.png")


if __name__ == "__main__":
    main()
