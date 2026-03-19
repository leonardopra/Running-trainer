#!/usr/bin/env python3
"""
Generates the Running Trainer app icon as a 1024x1024 PNG.
Output: assets/icon/icon.png

Design:
  - Dark background (#0A0A0F)
  - Filled cyan circle (#00E5FF) centered, radius ~460px
  - White running figure silhouette drawn from geometric shapes
"""

import struct, zlib, math, os

SIZE = 1024

# ─── colour helpers ──────────────────────────────────────────────────────────
BG  = (10,  10,  15)   # #0A0A0F
CYN = (0,  229, 255)   # #00E5FF
WHT = (255, 255, 255)

def lerp_color(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

# ─── pixel canvas ────────────────────────────────────────────────────────────
pixels = [bytearray(BG * SIZE) for _ in range(SIZE)]

def set_px(x, y, r, g, b):
    if 0 <= x < SIZE and 0 <= y < SIZE:
        off = x * 3
        pixels[y][off]   = r
        pixels[y][off+1] = g
        pixels[y][off+2] = b

def blend_px(x, y, fr, fg, fb, alpha):
    if not (0 <= x < SIZE and 0 <= y < SIZE): return
    off = x * 3
    br, bg, bb = pixels[y][off], pixels[y][off+1], pixels[y][off+2]
    pixels[y][off]   = int(br + (fr - br) * alpha)
    pixels[y][off+1] = int(bg + (fg - bg) * alpha)
    pixels[y][off+2] = int(bb + (fb - bb) * alpha)

# ─── drawing primitives ──────────────────────────────────────────────────────
def fill_circle(cx, cy, radius, r, g, b):
    """Filled circle with anti-aliased edge."""
    for dy in range(-radius - 1, radius + 2):
        for dx in range(-radius - 1, radius + 2):
            d = math.sqrt(dx*dx + dy*dy)
            if d < radius - 0.5:
                set_px(cx + dx, cy + dy, r, g, b)
            elif d < radius + 0.5:
                a = 1.0 - (d - (radius - 0.5))
                blend_px(cx + dx, cy + dy, r, g, b, a)

def fill_ellipse(cx, cy, rx, ry, r, g, b, angle_deg=0):
    """Filled ellipse, optionally rotated."""
    a = math.radians(angle_deg)
    cos_a, sin_a = math.cos(a), math.sin(a)
    for dy in range(-ry - 2, ry + 3):
        for dx in range(-rx - 2, rx + 3):
            # rotate back
            lx =  dx * cos_a + dy * sin_a
            ly = -dx * sin_a + dy * cos_a
            d = math.sqrt((lx/rx)**2 + (ly/ry)**2)
            if d < 0.9:
                set_px(cx + dx, cy + dy, r, g, b)
            elif d < 1.1:
                alpha = 1.0 - (d - 0.9) / 0.2
                blend_px(cx + dx, cy + dy, r, g, b, alpha)

def thick_line(x0, y0, x1, y1, thickness, r, g, b):
    """Draw a thick line using filled circles along Bresenham steps."""
    dx, dy = x1 - x0, y1 - y0
    length = math.sqrt(dx*dx + dy*dy)
    if length == 0: return
    steps = int(length) + 1
    for i in range(steps + 1):
        t = i / steps
        fill_circle(int(x0 + dx*t), int(y0 + dy*t), thickness, r, g, b)

# ─── draw the background cyan circle ─────────────────────────────────────────
print("Drawing background circle …")
fill_circle(512, 512, 460, *CYN)

# ─── draw the running figure (white silhouette) ───────────────────────────────
# Coordinates tuned so the figure sits centered and fills the circle nicely.
# The runner faces right, arms/legs pumping mid-stride.

print("Drawing running figure …")
cx, cy = 512, 512   # canvas center

# Scale factor — figure height ~550px
S = 1.0

def sp(x, y):
    """Scaled point relative to canvas centre."""
    return (int(cx + x * S), int(cy + y * S))

T = 20   # limb thickness
HT = 28  # head radius

# Head
fill_circle(*sp(20, -200), HT, *WHT)

# Torso (slightly leaned forward)
thick_line(*sp(20, -168), *sp(-10, -60), T, *WHT)

# Neck
thick_line(*sp(20, -168), *sp(20, -172), 12, *WHT)

# Right arm (swings back-down)
thick_line(*sp(-5, -130), *sp(-80, -60), T, *WHT)   # upper arm
thick_line(*sp(-80, -60), *sp(-120, -100), T-4, *WHT) # forearm

# Left arm (swings forward-up)
thick_line(*sp(-5, -130), *sp(60, -90), T, *WHT)
thick_line(*sp(60, -90), *sp(100, -40), T-4, *WHT)

# Right leg (forward / push-off)
thick_line(*sp(-10, -60), *sp(40, 50), T+2, *WHT)   # upper leg
thick_line(*sp(40, 50), *sp(80, 140), T+2, *WHT)    # lower leg
# foot
fill_ellipse(*sp(95, 155), 28, 12, *WHT, angle_deg=-20)

# Left leg (back / recovery)
thick_line(*sp(-10, -60), *sp(-60, 30), T+2, *WHT)
thick_line(*sp(-60, 30), *sp(-30, 130), T+2, *WHT)
# foot
fill_ellipse(*sp(-15, 140), 22, 10, *WHT, angle_deg=10)

# ─── write PNG ───────────────────────────────────────────────────────────────
def write_png(path, width, height, pixel_rows):
    def chunk(ctype, data):
        raw = ctype + data
        return struct.pack('>I', len(data)) + raw + struct.pack('>I', zlib.crc32(raw) & 0xffffffff)

    ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    raw_data = b''.join(b'\x00' + bytes(row) for row in pixel_rows)
    idat = zlib.compress(raw_data, 6)

    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(chunk(b'IHDR', ihdr))
        f.write(chunk(b'IDAT', idat))
        f.write(chunk(b'IEND', b''))

print("Encoding PNG …")
out = os.path.join(os.path.dirname(__file__), '..', 'assets', 'icon', 'icon.png')
write_png(os.path.normpath(out), SIZE, SIZE, pixels)
print(f"Icon written to {os.path.normpath(out)}")
