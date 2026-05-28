"""Generate LingoCode launcher icons matching the splash design.

Produces three PNGs in assets/icon/:
- icon.png             — full 1024x1024 icon (purple→pink gradient + 🎯 emoji)
- icon_foreground.png  — 1024x1024 transparent-bg version (🎯 in safe area)
- icon_background.png  — 1024x1024 solid-color background (Android adaptive)

Renders the real 🎯 color emoji via Segoe UI Emoji on Windows (Pillow 9.5+
supports color-emoji bitmaps natively).
"""
from __future__ import annotations
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import sys

OUT = Path(__file__).resolve().parent.parent / "assets" / "icon"
OUT.mkdir(parents=True, exist_ok=True)

SIZE = 1024
RADIUS = 220  # corner radius for full icon

PURPLE = (103, 80, 164)   # #6750A4
PINK   = (255, 107, 157)  # #FF6B9D

# Path to a color-emoji TTF. seguiemj.ttf is Windows-bundled.
EMOJI_FONT_CANDIDATES = [
    r"C:\Windows\Fonts\seguiemj.ttf",
    r"/System/Library/Fonts/Apple Color Emoji.ttc",
    r"/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf",
]


def _gradient_bg(size: int) -> Image.Image:
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
    ImageDraw.Draw(m).rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    return m


def _emoji_font(point: int) -> ImageFont.FreeTypeFont:
    for path in EMOJI_FONT_CANDIDATES:
        try:
            return ImageFont.truetype(path, size=point)
        except OSError:
            continue
    print("ERROR: no color-emoji font available on this system.", file=sys.stderr)
    sys.exit(1)


def _draw_emoji(im: Image.Image, *, point: int, dy: int = 0) -> None:
    """Draw 🎯 centered in `im`."""
    font = _emoji_font(point)
    d = ImageDraw.Draw(im, mode="RGBA")
    w, h = im.size
    d.text((w // 2, h // 2 + dy), "🎯",
           font=font, anchor="mm", embedded_color=True)


def build_full() -> Image.Image:
    """Full icon: rounded gradient + emoji."""
    bg = _gradient_bg(SIZE)
    icon = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    icon.paste(bg.convert("RGBA"), (0, 0), _rounded_mask(SIZE, RADIUS))
    # Emoji a bit smaller than the canvas so it doesn't kiss the rounded edges.
    _draw_emoji(icon, point=720)
    return icon


def build_foreground() -> Image.Image:
    """Adaptive icon foreground: 🎯 sized for Android safe area (~66%)."""
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    _draw_emoji(fg, point=560)
    return fg


def build_background() -> Image.Image:
    """Adaptive icon background: full-bleed gradient (Android masks the shape)."""
    return _gradient_bg(SIZE).convert("RGBA")


def main() -> None:
    build_full().save(OUT / "icon.png", "PNG", optimize=True)
    build_foreground().save(OUT / "icon_foreground.png", "PNG", optimize=True)
    build_background().save(OUT / "icon_background.png", "PNG", optimize=True)
    # remove the test scratch file if it lingered
    test = OUT / "_test_emoji.png"
    if test.exists():
        test.unlink()
    print(f"Wrote {OUT/'icon.png'} + foreground/background.")


if __name__ == "__main__":
    main()
