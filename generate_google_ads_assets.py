import os
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT_PATH = r"d:\StudioProject\RESUMER\fonts\Outfit.ttf"
ICON_PATH = r"d:\StudioProject\RESUMER\mobile\assets\icons\app_icon_512.png"

DIR_ID_RAW = r"d:\StudioProject\RESUMER\Screenshoots\INDONESIA"
DIR_EN_RAW = r"d:\StudioProject\RESUMER\Screenshoots\INGGRIS"

OUT_DIR = r"d:\StudioProject\RESUMER\Playstore_Assets\INDONESIA\Google_Ads"
os.makedirs(OUT_DIR, exist_ok=True)


def get_font(size, weight=400):
    f = ImageFont.truetype(FONT_PATH, size)
    f.set_variation_by_axes([weight])
    return f


def create_gradient_bg(width, height, c_top, c_bottom, glow_pos=None, glow_radius=500, glow_color=(30, 58, 138, 75)):
    arr = np.zeros((height, width, 4), dtype=np.uint8)
    for y in range(height):
        ratio = y / float(height - 1)
        r = int(c_top[0] * (1 - ratio) + c_bottom[0] * ratio)
        g = int(c_top[1] * (1 - ratio) + c_bottom[1] * ratio)
        b = int(c_top[2] * (1 - ratio) + c_bottom[2] * ratio)
        arr[y, :, 0] = r
        arr[y, :, 1] = g
        arr[y, :, 2] = b
        arr[y, :, 3] = 255

    img = Image.fromarray(arr, 'RGBA')

    if glow_pos and glow_color:
        gx, gy = glow_pos
        y_indices, x_indices = np.ogrid[:height, :width]
        dist = np.sqrt((x_indices - gx) ** 2 + (y_indices - gy) ** 2)
        factor = np.clip(1.0 - dist / float(glow_radius), 0, 1)
        factor = 0.5 * (1.0 + np.cos(np.pi * (1.0 - factor)))
        glow_arr = np.zeros((height, width, 4), dtype=np.uint8)
        glow_arr[:, :, 0] = glow_color[0]
        glow_arr[:, :, 1] = glow_color[1]
        glow_arr[:, :, 2] = glow_color[2]
        glow_arr[:, :, 3] = (factor * glow_color[3]).astype(np.uint8)
        glow_layer = Image.fromarray(glow_arr, 'RGBA')
        img = Image.alpha_composite(img, glow_layer)

    return img


def draw_vector_check(draw, cx, cy, size=14, color=(52, 211, 153), stroke=2):
    p1 = (cx - size * 0.4, cy)
    p2 = (cx - size * 0.1, cy + size * 0.35)
    p3 = (cx + size * 0.45, cy - size * 0.35)
    draw.line([p1, p2, p3], fill=color, width=stroke, joint="curve")


def draw_clean_statusbar(screen, font_path, bg_color=(255, 255, 255)):
    w, h = screen.size
    bar_h = int(w * 0.084)
    sb = Image.new('RGBA', (w, bar_h), (bg_color[0], bg_color[1], bg_color[2], 255))
    dsb = ImageDraw.Draw(sb)

    f_time = ImageFont.truetype(font_path, max(11, int(w * 0.023)))
    f_time.set_variation_by_axes([600])
    dsb.text((int(w * 0.042), int(bar_h * 0.3)), '09:41', font=f_time, fill=(15, 23, 42))

    cx = w // 2
    cy = bar_h // 2
    r_out = max(4, int(w * 0.01))
    dsb.ellipse([(cx - r_out, cy - r_out), (cx + r_out, cy + r_out)], fill=(15, 23, 42))

    bx = w - int(w * 0.075)
    by1 = int(bar_h * 0.38)
    by2 = int(bar_h * 0.62)
    bw = int(w * 0.035)
    dsb.rounded_rectangle([(bx, by1), (bx + bw, by2)], radius=2, outline=(15, 23, 42), width=2)
    dsb.rounded_rectangle([(bx + 2, by1 + 2), (bx + bw - 4, by2 - 2)], radius=1, fill=(16, 185, 129))

    screen.paste(sb, (0, 0), sb)
    return screen


def create_document_card(doc_img, target_w, target_h, radius=14):
    resized = doc_img.resize((target_w, target_h), Image.Resampling.LANCZOS).convert('RGBA')
    mask = Image.new('L', (target_w, target_h), 0)
    dmask = ImageDraw.Draw(mask)
    dmask.rounded_rectangle([(0, 0), (target_w - 1, target_h - 1)], radius=radius, fill=255)

    card = Image.new('RGBA', (target_w, target_h), (0, 0, 0, 0))
    card.paste(resized, (0, 0), mask)

    dcard = ImageDraw.Draw(card)
    dcard.rounded_rectangle([(0, 0), (target_w - 1, target_h - 1)], radius=radius, outline=(226, 232, 240, 220), width=1)
    return card


def add_card_shadow(card, pad=60, offset_y=18, blur=26, shadow_alpha=150):
    w, h = card.size
    full_w = w + pad * 2
    full_h = h + pad * 2

    shadow_img = Image.new('RGBA', (full_w, full_h), (0, 0, 0, 0))
    dshadow = ImageDraw.Draw(shadow_img)
    sx = pad
    sy = pad + offset_y
    dshadow.rounded_rectangle([(sx, sy), (sx + w, sy + h)], radius=16, fill=(0, 0, 0, shadow_alpha))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(blur))
    shadow_img.paste(card, (pad, pad), card)
    return shadow_img, pad


def create_phone_mockup(screen_img, target_screen_w=540, target_screen_h=1180, bezel=14, radius_outer=38, radius_inner=28):
    orig_w, orig_h = screen_img.size
    scale = target_screen_w / float(orig_w)
    new_h = int(orig_h * scale)
    scaled_screen = screen_img.resize((target_screen_w, new_h), Image.Resampling.LANCZOS).convert('RGBA')
    scaled_screen = draw_clean_statusbar(scaled_screen, FONT_PATH)

    if new_h > target_screen_h:
        cropped_screen = scaled_screen.crop((0, 0, target_screen_w, target_screen_h))
    else:
        cropped_screen = Image.new('RGBA', (target_screen_w, target_screen_h), (255, 255, 255, 255))
        cropped_screen.paste(scaled_screen, (0, 0))

    screen_mask = Image.new('L', (target_screen_w, target_screen_h), 0)
    dscreen_mask = ImageDraw.Draw(screen_mask)
    dscreen_mask.rounded_rectangle([(0, 0), (target_screen_w - 1, target_screen_h - 1)], radius=radius_inner, fill=255)

    screen_surface = Image.new('RGBA', (target_screen_w, target_screen_h), (0, 0, 0, 0))
    screen_surface.paste(cropped_screen, (0, 0), screen_mask)

    frame_w = target_screen_w + bezel * 2
    frame_h = target_screen_h + bezel * 2

    phone = Image.new('RGBA', (frame_w, frame_h), (0, 0, 0, 0))
    dphone = ImageDraw.Draw(phone)
    dphone.rounded_rectangle([(0, 0), (frame_w - 1, frame_h - 1)], radius=radius_outer, fill=(22, 31, 48, 255))
    dphone.rounded_rectangle([(0, 0), (frame_w - 1, frame_h - 1)], radius=radius_outer, outline=(51, 65, 85, 255), width=2)
    dphone.rounded_rectangle([(bezel - 2, bezel - 2), (frame_w - bezel + 1, frame_h - bezel + 1)], radius=radius_inner + 2, outline=(15, 23, 42, 255), width=2)
    phone.paste(screen_surface, (bezel, bezel), screen_surface)

    pad = 70
    shadow_w = frame_w + pad * 2
    shadow_h = frame_h + pad * 2

    shadow_layer = Image.new('RGBA', (shadow_w, shadow_h), (0, 0, 0, 0))
    dshadow = ImageDraw.Draw(shadow_layer)
    sx = pad
    sy = pad + 26
    dshadow.rounded_rectangle([(sx, sy), (sx + frame_w, sy + frame_h)], radius=radius_outer, fill=(0, 0, 0, 145))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(32))
    shadow_layer.paste(phone, (pad, pad), phone)

    return shadow_layer, pad, frame_w, frame_h


def get_patched_asian_ats_indonesia():
    cv_id = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-102908.jpg.jpeg"))
    cv_en = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101827.jpg.jpeg")).copy()
    top_bar = cv_id.crop((0, 0, 720, 180))
    cv_en.paste(top_bar, (0, 0))
    bottom_bar = cv_id.crop((0, 1460, 720, 1612))
    cv_en.paste(bottom_bar, (0, 1460))
    return cv_en


def paste_brand_header(canvas, x, y, icon_size=84):
    draw = ImageDraw.Draw(canvas)
    icon_raw = Image.open(ICON_PATH).convert('RGBA').resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    icon_mask = Image.new('L', (icon_size, icon_size), 0)
    dicon_mask = ImageDraw.Draw(icon_mask)
    rad = int(icon_size * 0.24)
    dicon_mask.rounded_rectangle([(0, 0), (icon_size - 1, icon_size - 1)], radius=rad, fill=255)

    icon_box = Image.new('RGBA', (icon_size + 40, icon_size + 40), (0, 0, 0, 0))
    dicon_box = ImageDraw.Draw(icon_box)
    dicon_box.rounded_rectangle([(20, 22), (20 + icon_size, 22 + icon_size)], radius=rad, fill=(0, 0, 0, 110))
    icon_box = icon_box.filter(ImageFilter.GaussianBlur(10))
    icon_box.paste(icon_raw, (20, 20), icon_mask)
    dicon_bdr = ImageDraw.Draw(icon_box)
    dicon_bdr.rounded_rectangle([(20, 20), (19 + icon_size, 19 + icon_size)], radius=rad, outline=(255, 255, 255, 90), width=1)

    canvas.paste(icon_box, (x - 20, y - 20), icon_box)

    tx = x + icon_size + 20
    f_brand = get_font(int(icon_size * 0.45), weight=800)
    draw.text((tx, y + 4), "RESUMER", font=f_brand, fill=(255, 255, 255))

    f_cat = get_font(max(12, int(icon_size * 0.15)), weight=700)
    cat_txt = "AI ATS CV MAKER & JOB MATCHER"
    bbox = f_cat.getbbox(cat_txt)
    cw = bbox[2] - bbox[0] + 24
    ch = bbox[3] - bbox[1] + 12
    cy = y + int(icon_size * 0.58)
    draw.rounded_rectangle([(tx, cy), (tx + cw, cy + ch)], radius=6, fill=(30, 41, 59, 200), outline=(56, 189, 248, 130), width=1)
    draw.text((tx + 12, cy + 4), cat_txt, font=f_cat, fill=(56, 189, 248))


# ==============================================================================
# 1. LANDSCAPE 1200 x 628 (1.91:1) - Banner Utama Dual CV
# ==============================================================================
def build_landscape_1():
    width, height = 1200, 628
    canvas = create_gradient_bg(width, height, (9, 15, 34), (17, 26, 50), (890, 310), 540, (37, 99, 235, 80))
    left_glow = create_gradient_bg(width, height, (0, 0, 0), (0, 0, 0), (160, 130), 340, (16, 185, 129, 35))
    canvas = Image.alpha_composite(canvas, left_glow)
    draw = ImageDraw.Draw(canvas)

    im_ats = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101827.jpg.jpeg"))
    crop_ats = im_ats.crop((40, 203, 680, 1100))

    im_crt = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-102908.jpg.jpeg"))
    crop_crt = im_crt.crop((35, 195, 685, 1305))

    card_h = 465
    card_w = int(card_h * 0.70)  # 325px
    card_ats = create_document_card(crop_ats, card_w, card_h, radius=14)
    card_crt = create_document_card(crop_crt, card_w, card_h, radius=14)

    shadow_ats, pad_ats = add_card_shadow(card_ats, pad=55, offset_y=18, blur=24, shadow_alpha=150)
    shadow_crt, pad_crt = add_card_shadow(card_crt, pad=55, offset_y=20, blur=26, shadow_alpha=170)

    rot_ats = shadow_ats.rotate(3.5, resample=Image.Resampling.BICUBIC, expand=True)
    rot_crt = shadow_crt.rotate(-2.5, resample=Image.Resampling.BICUBIC, expand=True)

    canvas.paste(rot_ats, (615 - pad_ats, 55 - pad_ats), rot_ats)
    canvas.paste(rot_crt, (825 - pad_crt, 70 - pad_crt), rot_crt)

    # Top labels
    f_lbl = get_font(13, weight=600)
    for lx, ly, ltxt in [(630, 28, "Standar ATS Resmi"), (915, 30, "14+ Desain Kreatif")]:
        tb = f_lbl.getbbox(ltxt)
        lw = tb[2] - tb[0] + 32
        lh = 32
        lbl = Image.new('RGBA', (lw, lh), (15, 23, 42, 235))
        dl = ImageDraw.Draw(lbl)
        dl.rounded_rectangle([(0, 0), (lw - 1, lh - 1)], radius=16, outline=(255, 255, 255, 65), width=1)
        dl.text((16, 7), ltxt, font=f_lbl, fill=(226, 232, 240))
        canvas.paste(lbl, (lx, ly), lbl)

    # Floating Score Badge
    bw, bh = 310, 56
    badge_img = Image.new('RGBA', (bw + 30, bh + 30), (0, 0, 0, 0))
    db = ImageDraw.Draw(badge_img)
    db.rounded_rectangle([(15, 18), (15 + bw, 18 + bh)], radius=28, fill=(0, 0, 0, 140))
    badge_img = badge_img.filter(ImageFilter.GaussianBlur(8))
    db = ImageDraw.Draw(badge_img)
    db.rounded_rectangle([(15, 15), (15 + bw, 15 + bh)], radius=28, fill=(6, 95, 70, 248), outline=(52, 211, 153, 230), width=2)
    draw_vector_check(db, 38, 43, size=18, color=(52, 211, 153), stroke=3)
    db.text((58, 22), "Skor ATS: 96 / 100", font=get_font(18, weight=800), fill=(255, 255, 255))
    db.text((58, 45), "Top 5% ATS Ready • Lolos Seleksi", font=get_font(13, weight=500), fill=(167, 243, 208))
    canvas.paste(badge_img, (745, 505), badge_img)

    # Left Column
    paste_brand_header(canvas, 70, 58, icon_size=88)

    f_head = get_font(38, weight=800)
    draw.text((70, 182), "Buat CV ATS Lolos Seleksi", font=f_head, fill=(255, 255, 255))
    draw.text((70, 230), "& Cocokkan Loker AI", font=f_head, fill=(255, 255, 255))

    f_sub = get_font(16, weight=400)
    draw.text((70, 294), "Format standar HRD ramah mesin ATS dengan jaminan skor 90+,", font=f_sub, fill=(148, 163, 184))
    draw.text((70, 320), "cek kecocokan poster loker via screenshot, & auto-fix 1-klik.", font=f_sub, fill=(148, 163, 184))

    bullets = [
        "Standar Asian & Western ATS (Skor 90 - 98+)",
        "14+ Pilihan Desain ATS & Portofolio Kreatif",
        "Pencocok Loker AI dari Screenshot Poster",
        "Surat Lamaran Kerja AI & Tanda Tangan Digital"
    ]
    f_bullet = get_font(16, weight=600)
    start_y = 378
    for i, btxt in enumerate(bullets):
        by = start_y + i * 46
        draw.rounded_rectangle([(70, by), (94, by + 24)], radius=12, fill=(6, 95, 70, 210), outline=(52, 211, 153, 190), width=1)
        draw_vector_check(draw, 82, by + 12, size=12, color=(52, 211, 153), stroke=2)
        draw.text((108, by + 2), btxt, font=f_bullet, fill=(241, 245, 249))

    dest = os.path.join(OUT_DIR, "01_landscape_1200x628_utama.png")
    canvas.convert('RGB').save(dest, "PNG", optimize=True)
    print("Saved:", dest)


# ==============================================================================
# 2. LANDSCAPE 1200 x 628 (1.91:1) - 3 Mockup Fitur AI
# ==============================================================================
def build_landscape_2():
    width, height = 1200, 628
    canvas = create_gradient_bg(width, height, (11, 19, 43), (17, 26, 50), (850, 320), 520, (16, 185, 129, 65))
    left_glow = create_gradient_bg(width, height, (0, 0, 0), (0, 0, 0), (250, 200), 380, (37, 99, 235, 55))
    canvas = Image.alpha_composite(canvas, left_glow)
    draw = ImageDraw.Draw(canvas)

    paste_brand_header(canvas, 65, 52, icon_size=82)

    f_head = get_font(36, weight=800)
    draw.text((65, 168), "Solusi Lengkap Pelamar", font=f_head, fill=(255, 255, 255))
    draw.text((65, 214), "Kerja di Indonesia", font=f_head, fill=(52, 211, 153))

    f_sub = get_font(16, weight=400)
    draw.text((65, 275), "Semua alat bantu melamar kerja profesional dalam 1 aplikasi:", font=f_sub, fill=(148, 163, 184))

    bullets = [
        "Cek Skor ATS (0-100) & 1-Klik Auto-Fix AI",
        "Scan Poster Loker via Screenshot (AI OCR)",
        "Buat Surat Lamaran Kerja & TTD Digital Instan",
        "Download PDF Rapi Tanpa Watermark"
    ]
    f_bullet = get_font(15, weight=600)
    for i, btxt in enumerate(bullets):
        by = 322 + i * 44
        draw.rounded_rectangle([(65, by), (89, by + 24)], radius=12, fill=(6, 95, 70, 210), outline=(52, 211, 153, 190), width=1)
        draw_vector_check(draw, 77, by + 12, size=11, color=(52, 211, 153), stroke=2)
        draw.text((102, by + 2), btxt, font=f_bullet, fill=(241, 245, 249))

    # CTA Pill
    draw.rounded_rectangle([(65, 515), (355, 568)], radius=26, fill=(16, 185, 129), outline=(110, 231, 183), width=1)
    draw.text((98, 529), "Download Gratis Sekarang", font=get_font(18, weight=800), fill=(7, 12, 26))

    # Right side: 2 Overlapping Phone Mockups (ATS Score & Job Matcher)
    im_skor = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-100633.jpg.jpeg"))
    im_match = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-100745.jpg.jpeg"))

    p1, pad1, fw1, fh1 = create_phone_mockup(im_match, target_screen_w=250, target_screen_h=520, bezel=8, radius_outer=24, radius_inner=18)
    p2, pad2, fw2, fh2 = create_phone_mockup(im_skor, target_screen_w=268, target_screen_h=550, bezel=9, radius_outer=26, radius_inner=20)

    p1_rot = p1.rotate(-5, resample=Image.Resampling.BICUBIC, expand=True)
    canvas.paste(p1_rot, (590 - pad1, 65 - pad1), p1_rot)
    canvas.paste(p2, (835 - pad2, 42 - pad2), p2)

    dest = os.path.join(OUT_DIR, "02_landscape_1200x628_fitur_ai.png")
    canvas.convert('RGB').save(dest, "PNG", optimize=True)
    print("Saved:", dest)


# ==============================================================================
# 3. SQUARE 1200 x 1200 (1:1) - Generator Slide
# ==============================================================================
def build_square_slide(tag, headline_lines, subtitle, screen_img, filename, accent=(52, 211, 153), glow=(16, 185, 129, 65)):
    w, h = 1200, 1200
    canvas = create_gradient_bg(w, h, (11, 19, 43), (17, 25, 48), (600, 760), 540, glow)
    draw = ImageDraw.Draw(canvas)

    # Top pill tag
    f_tag = get_font(20, weight=700)
    tb = f_tag.getbbox(tag)
    tw = tb[2] - tb[0] + 66
    th = 42
    tx = (w - tw) // 2
    ty = 48
    draw.rounded_rectangle([(tx, ty), (tx + tw, ty + th)], radius=21, fill=(28, 38, 59, 235), outline=(255, 255, 255, 50), width=1)
    draw.ellipse([(tx + 22, ty + 16), (tx + 32, ty + 26)], fill=accent)
    draw.text((tx + 42, ty + 9), tag, font=f_tag, fill=accent)

    # Headline
    f_head = get_font(52, weight=800)
    cur_y = 108
    for line in headline_lines:
        lb = f_head.getbbox(line)
        lw = lb[2] - lb[0]
        draw.text(((w - lw) // 2, cur_y), line, font=f_head, fill=(255, 255, 255))
        cur_y += 62

    # Subtitle
    f_sub = get_font(24, weight=400)
    cur_y += 6
    sb = f_sub.getbbox(subtitle)
    sw = sb[2] - sb[0]
    draw.text(((w - sw) // 2, cur_y), subtitle, font=f_sub, fill=(148, 163, 184))

    # Phone Mockup centered in bottom area
    phone, pad, fw, fh = create_phone_mockup(screen_img, target_screen_w=540, target_screen_h=1100, bezel=14, radius_outer=38, radius_inner=28)
    px = (w - fw) // 2
    py = 310
    canvas.paste(phone, (px - pad, py - pad), phone)

    dest = os.path.join(OUT_DIR, filename)
    canvas.convert('RGB').save(dest, "PNG", optimize=True)
    print("Saved:", dest)


# ==============================================================================
# 4. PORTRAIT 1200 x 1500 (4:5) - Generator Slide
# ==============================================================================
def build_portrait_slide(tag, headline_lines, subtitle, screen_img, filename, accent=(52, 211, 153), glow=(16, 185, 129, 65)):
    w, h = 1200, 1500
    canvas = create_gradient_bg(w, h, (11, 19, 43), (17, 25, 48), (600, 880), 560, glow)
    draw = ImageDraw.Draw(canvas)

    # Top pill tag
    f_tag = get_font(20, weight=700)
    tb = f_tag.getbbox(tag)
    tw = tb[2] - tb[0] + 68
    th = 42
    tx = (w - tw) // 2
    ty = 52
    draw.rounded_rectangle([(tx, ty), (tx + tw, ty + th)], radius=21, fill=(28, 38, 59, 235), outline=(255, 255, 255, 50), width=1)
    draw.ellipse([(tx + 24, ty + 16), (tx + 34, ty + 26)], fill=accent)
    draw.text((tx + 44, ty + 9), tag, font=f_tag, fill=accent)

    # Headline
    f_head = get_font(52, weight=800)
    cur_y = 110
    for line in headline_lines:
        lb = f_head.getbbox(line)
        lw = lb[2] - lb[0]
        draw.text(((w - lw) // 2, cur_y), line, font=f_head, fill=(255, 255, 255))
        cur_y += 62

    # Subtitle
    f_sub = get_font(24, weight=400)
    cur_y += 8
    sb = f_sub.getbbox(subtitle)
    sw = sb[2] - sb[0]
    draw.text(((w - sw) // 2, cur_y), subtitle, font=f_sub, fill=(148, 163, 184))

    # Phone Mockup (Full phone fits cleanly inside 1500px height!)
    phone, pad, fw, fh = create_phone_mockup(screen_img, target_screen_w=500, target_screen_h=1118, bezel=14, radius_outer=38, radius_inner=28)
    px = (w - fw) // 2
    py = 310
    canvas.paste(phone, (px - pad, py - pad), phone)

    dest = os.path.join(OUT_DIR, filename)
    canvas.convert('RGB').save(dest, "PNG", optimize=True)
    print("Saved:", dest)


def main():
    build_landscape_1()
    build_landscape_2()

    im_ats_id = get_patched_asian_ats_indonesia()
    im_skor = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-100633.jpg.jpeg"))
    im_matcher = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-100745.jpg.jpeg"))

    # Square 1200x1200 (1:1)
    build_square_slide(
        tag="STANDAR ATS RESMI",
        headline_lines=["Buat CV ATS Standar Global", "Lolos Seleksi Robot HRD"],
        subtitle="Format baku ramah parser ATS dengan jaminan skor tinggi 90-98+",
        screen_img=im_ats_id,
        filename="03_square_1200x1200_cv_ats.png",
        accent=(52, 211, 153),
        glow=(16, 185, 129, 60)
    )
    build_square_slide(
        tag="ATS QUALITY SCORE CHECKER",
        headline_lines=["Cek Skor Kualitas ATS", "& 1-Click Auto-Fix AI"],
        subtitle="Analisis 4 parameter kunci untuk maksimalkan panggilan wawancara",
        screen_img=im_skor,
        filename="04_square_1200x1200_skor_ats.png",
        accent=(52, 211, 153),
        glow=(16, 185, 129, 65)
    )
    build_square_slide(
        tag="AI JOB MATCHER",
        headline_lines=["Cocokkan CV dengan Loker", "Cukup Unggah Screenshot"],
        subtitle="AI OCR membaca poster lowongan kerja otomatis tanpa salin link",
        screen_img=im_matcher,
        filename="05_square_1200x1200_job_matcher.png",
        accent=(56, 189, 248),
        glow=(37, 99, 235, 65)
    )

    # Portrait 1200x1500 (4:5)
    build_portrait_slide(
        tag="STANDAR ATS RESMI",
        headline_lines=["Buat CV ATS Standar Global", "Lolos Seleksi Robot HRD"],
        subtitle="Format baku ramah parser ATS dengan jaminan skor tinggi 90-98+",
        screen_img=im_ats_id,
        filename="06_portrait_1200x1500_cv_ats.png",
        accent=(52, 211, 153),
        glow=(16, 185, 129, 60)
    )
    build_portrait_slide(
        tag="ATS QUALITY SCORE CHECKER",
        headline_lines=["Cek Skor Kualitas ATS", "& 1-Click Auto-Fix AI"],
        subtitle="Analisis 4 parameter kunci untuk maksimalkan panggilan wawancara",
        screen_img=im_skor,
        filename="07_portrait_1200x1500_skor_ats.png",
        accent=(52, 211, 153),
        glow=(16, 185, 129, 65)
    )
    build_portrait_slide(
        tag="AI JOB MATCHER",
        headline_lines=["Cocokkan CV dengan Loker", "Cukup Unggah Screenshot"],
        subtitle="AI OCR membaca poster lowongan kerja otomatis tanpa salin link",
        screen_img=im_matcher,
        filename="08_portrait_1200x1500_job_matcher.png",
        accent=(56, 189, 248),
        glow=(37, 99, 235, 65)
    )


if __name__ == "__main__":
    main()
