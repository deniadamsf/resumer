import os
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT_PATH = r"d:\StudioProject\RESUMER\fonts\Outfit.ttf"
ICON_PATH = r"d:\StudioProject\RESUMER\mobile\assets\icons\app_icon_512.png"

DIR_ID_RAW = r"d:\StudioProject\RESUMER\Screenshoots\INDONESIA"
DIR_EN_RAW = r"d:\StudioProject\RESUMER\Screenshoots\INGGRIS"

OUTPUT_DIR_ID = r"d:\StudioProject\RESUMER\Playstore_Assets\INDONESIA"
OUTPUT_DIR_EN = r"d:\StudioProject\RESUMER\Playstore_Assets\INGGRIS"

os.makedirs(OUTPUT_DIR_ID, exist_ok=True)
os.makedirs(OUTPUT_DIR_EN, exist_ok=True)

def get_font(size, weight=400):
    f = ImageFont.truetype(FONT_PATH, size)
    f.set_variation_by_axes([weight])
    return f

def create_gradient_bg(width, height, c_top, c_bottom, glow_pos=None, glow_radius=500, glow_color=(30, 58, 138, 70)):
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
        dist = np.sqrt((x_indices - gx)**2 + (y_indices - gy)**2)
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
    p1 = (cx - size*0.4, cy)
    p2 = (cx - size*0.1, cy + size*0.35)
    p3 = (cx + size*0.45, cy - size*0.35)
    draw.line([p1, p2, p3], fill=color, width=stroke, joint="curve")

def draw_clean_statusbar(screen, font_path, bg_color=(255, 255, 255)):
    w, h = screen.size
    bar_h = 56
    sb = Image.new('RGBA', (w, bar_h), (bg_color[0], bg_color[1], bg_color[2], 255))
    dsb = ImageDraw.Draw(sb)
    
    # Font for time
    f_time = ImageFont.truetype(font_path, 15)
    f_time.set_variation_by_axes([600])
    dsb.text((28, 17), '09:41', font=f_time, fill=(15, 23, 42))
    
    # Center camera punch hole
    cx = w // 2
    cy = 28
    dsb.ellipse([(cx - 7, cy - 7), (cx + 7, cy + 7)], fill=(15, 23, 42))
    dsb.ellipse([(cx - 3, cy - 3), (cx + 3, cy + 3)], fill=(30, 41, 59))
    
    # Right side: Signal bars
    sx = w - 105
    for i in range(4):
        bx = sx + (i * 5)
        bht = 4 + (i * 3)
        by = 34 - bht
        dsb.rounded_rectangle([(bx, by), (bx + 3, 34)], radius=1, fill=(15, 23, 42))
        
    # Wi-Fi icon
    wx = w - 74
    dsb.arc([(wx - 9, 21), (wx + 9, 39)], start=215, end=325, fill=(15, 23, 42), width=2)
    dsb.arc([(wx - 5, 25), (wx + 5, 35)], start=215, end=325, fill=(15, 23, 42), width=2)
    dsb.ellipse([(wx - 1.5, 32), (wx + 1.5, 35)], fill=(15, 23, 42))
    
    # Battery pill
    bx = w - 48
    dsb.rounded_rectangle([(bx, 22), (bx + 23, 34)], radius=3, outline=(15, 23, 42), width=2)
    dsb.rounded_rectangle([(bx + 2, 24), (bx + 17, 32)], radius=1, fill=(16, 185, 129)) # full green
    dsb.rounded_rectangle([(bx + 24, 25), (bx + 25, 31)], radius=1, fill=(15, 23, 42)) # terminal
    
    screen.paste(sb, (0, 0), sb)
    return screen


# ==========================================
# 1. FEATURED GRAPHIC (1024 x 500 px)
# ==========================================
def create_document_card(doc_img, target_w, target_h, radius=12):
    resized = doc_img.resize((target_w, target_h), Image.Resampling.LANCZOS).convert('RGBA')
    mask = Image.new('L', (target_w, target_h), 0)
    dmask = ImageDraw.Draw(mask)
    dmask.rounded_rectangle([(0, 0), (target_w - 1, target_h - 1)], radius=radius, fill=255)
    
    card = Image.new('RGBA', (target_w, target_h), (0, 0, 0, 0))
    card.paste(resized, (0, 0), mask)
    
    dcard = ImageDraw.Draw(card)
    dcard.rounded_rectangle([(0, 0), (target_w - 1, target_h - 1)], radius=radius, outline=(226, 232, 240, 220), width=1)
    return card

def add_card_shadow(card, pad=60, offset_y=16, blur=24, shadow_alpha=140):
    w, h = card.size
    full_w = w + pad * 2
    full_h = h + pad * 2
    
    shadow_img = Image.new('RGBA', (full_w, full_h), (0, 0, 0, 0))
    dshadow = ImageDraw.Draw(shadow_img)
    sx = pad
    sy = pad + offset_y
    dshadow.rounded_rectangle([(sx, sy), (sx + w, sy + h)], radius=14, fill=(0, 0, 0, shadow_alpha))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(blur))
    shadow_img.paste(card, (pad, pad), card)
    return shadow_img, pad

def build_featured_graphic(lang="ID"):
    width = 1024
    height = 500
    
    c_top = (11, 19, 43)      # #0B132B Midnight Oxford Navy
    c_bottom = (17, 26, 50)   # #111A32
    glow_pos = (750, 240)     # Glow centered behind CV showcase
    glow_color = (37, 99, 235, 75)
    canvas = create_gradient_bg(width, height, c_top, c_bottom, glow_pos, 460, glow_color)
    
    left_glow = create_gradient_bg(width, height, (0,0,0), (0,0,0), (140, 100), 280, (16, 185, 129, 30))
    canvas = Image.alpha_composite(canvas, left_glow)
    
    draw = ImageDraw.Draw(canvas)
    
    # 2 CV crops: Asian ATS & Modern Creative
    im_ats = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101827.jpg.jpeg"))
    crop_ats = im_ats.crop((40, 203, 680, 1100))
    
    im_crt = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-102908.jpg.jpeg"))
    crop_crt = im_crt.crop((35, 195, 685, 1305))
    
    card_h = 375
    card_w = int(card_h * 0.70) # 262px
    
    card_ats = create_document_card(crop_ats, card_w, card_h, radius=12)
    card_crt = create_document_card(crop_crt, card_w, card_h, radius=12)
    
    shadow_ats, pad_ats = add_card_shadow(card_ats, pad=50, offset_y=16, blur=22, shadow_alpha=140)
    shadow_crt, pad_crt = add_card_shadow(card_crt, pad=50, offset_y=18, blur=24, shadow_alpha=160)
    
    rotated_ats = shadow_ats.rotate(3.5, resample=Image.Resampling.BICUBIC, expand=True)
    rotated_crt = shadow_crt.rotate(-2.5, resample=Image.Resampling.BICUBIC, expand=True)
    
    pos_ats_x = 525
    pos_ats_y = 40
    canvas.paste(rotated_ats, (pos_ats_x - pad_ats, pos_ats_y - pad_ats), rotated_ats)
    
    pos_crt_x = 705
    pos_crt_y = 52
    canvas.paste(rotated_crt, (pos_crt_x - pad_crt, pos_crt_y - pad_crt), rotated_crt)
    
    # Top tags for the 2 CVs
    lbl1_w = 146
    lbl1_h = 28
    lbl1 = Image.new('RGBA', (lbl1_w, lbl1_h), (15, 23, 42, 230))
    dlbl1 = ImageDraw.Draw(lbl1)
    dlbl1.rounded_rectangle([(0,0),(lbl1_w-1, lbl1_h-1)], radius=14, outline=(255,255,255,60), width=1)
    f_lbl = get_font(11, weight=600)
    txt_lbl1 = "Standar ATS Resmi" if lang == "ID" else "Official ATS Format"
    dlbl1.text((14, 7), txt_lbl1, font=f_lbl, fill=(226, 232, 240))
    canvas.paste(lbl1, (535, 22), lbl1)
    
    lbl2_w = 148
    lbl2_h = 28
    lbl2 = Image.new('RGBA', (lbl2_w, lbl2_h), (15, 23, 42, 230))
    dlbl2 = ImageDraw.Draw(lbl2)
    dlbl2.rounded_rectangle([(0,0),(lbl2_w-1, lbl2_h-1)], radius=14, outline=(255,255,255,60), width=1)
    txt_lbl2 = "14+ Desain Kreatif" if lang == "ID" else "14+ Modern Layouts"
    dlbl2.text((14, 7), txt_lbl2, font=f_lbl, fill=(226, 232, 240))
    canvas.paste(lbl2, (785, 24), lbl2)

    # Floating Badge: Skor ATS 96
    badge_w = 265
    badge_h = 46
    badge_img = Image.new('RGBA', (badge_w + 30, badge_h + 30), (0, 0, 0, 0))
    dbadge = ImageDraw.Draw(badge_img)
    dbadge.rounded_rectangle([(15, 18), (15 + badge_w, 18 + badge_h)], radius=23, fill=(0, 0, 0, 130))
    badge_img = badge_img.filter(ImageFilter.GaussianBlur(8))
    dbadge = ImageDraw.Draw(badge_img)
    dbadge.rounded_rectangle([(15, 15), (15 + badge_w, 15 + badge_h)], radius=23, fill=(6, 95, 70, 245), outline=(52, 211, 153, 220), width=1)
    
    draw_vector_check(dbadge, 34, 38, size=16, color=(52, 211, 153), stroke=2)
    
    f_badge = get_font(15, weight=800)
    f_badge_sub = get_font(12, weight=500)
    if lang == "ID":
        badge_txt = "Skor ATS: 96 / 100"
        badge_sub = "Top 5% ATS Ready • Lolos Seleksi"
    else:
        badge_txt = "ATS Score: 96 / 100"
        badge_sub = "Top 5% ATS Ready • HR Compliant"
        
    dbadge.text((50, 22), badge_txt, font=f_badge, fill=(255, 255, 255))
    dbadge.text((50, 40), badge_sub, font=f_badge_sub, fill=(167, 243, 208))
    
    canvas.paste(badge_img, (640, 400), badge_img)

    # Left Section: Brand & Bullets
    icon_raw = Image.open(ICON_PATH).convert('RGBA').resize((76, 76), Image.Resampling.LANCZOS)
    icon_mask = Image.new('L', (76, 76), 0)
    dicon_mask = ImageDraw.Draw(icon_mask)
    dicon_mask.rounded_rectangle([(0, 0), (75, 75)], radius=18, fill=255)
    
    icon_box = Image.new('RGBA', (116, 116), (0, 0, 0, 0))
    dicon_box = ImageDraw.Draw(icon_box)
    dicon_box.rounded_rectangle([(20, 22), (96, 98)], radius=18, fill=(0, 0, 0, 100))
    icon_box = icon_box.filter(ImageFilter.GaussianBlur(10))
    icon_box.paste(icon_raw, (20, 20), icon_mask)
    dicon_bdr = ImageDraw.Draw(icon_box)
    dicon_bdr.rounded_rectangle([(20, 20), (95, 95)], radius=18, outline=(255, 255, 255, 80), width=1)
    
    canvas.paste(icon_box, (45, 36), icon_box)
    
    f_brand = get_font(34, weight=800)
    draw.text((155, 50), "RESUMER", font=f_brand, fill=(255, 255, 255))
    
    f_cat = get_font(11, weight=700)
    cat_txt = "AI ATS CV MAKER & JOB MATCHER"
    draw.rounded_rectangle([(155, 92), (375, 115)], radius=6, fill=(30, 41, 59, 180), outline=(56, 189, 248, 120), width=1)
    draw.text((165, 96), cat_txt, font=f_cat, fill=(56, 189, 248))
    
    f_head = get_font(30, weight=800)
    if lang == "ID":
        head_line1 = "Buat CV ATS Lolos Seleksi"
        head_line2 = "& Cocokkan Loker AI"
    else:
        head_line1 = "Build ATS-Ready Resumes"
        head_line2 = "& Match Jobs with AI"
        
    draw.text((65, 150), head_line1, font=f_head, fill=(255, 255, 255))
    draw.text((65, 189), head_line2, font=f_head, fill=(255, 255, 255))
    
    f_sub = get_font(14, weight=400)
    if lang == "ID":
        sub_txt1 = "Format standar HRD ramah mesin ATS dengan jaminan skor 90+,"
        sub_txt2 = "cek kecocokan poster loker via screenshot, & auto-fix 1-klik."
    else:
        sub_txt1 = "HR-approved ATS layouts with guaranteed 90+ score,"
        sub_txt2 = "smart job vacancy matching, and 1-click AI auto-fix."
        
    draw.text((65, 242), sub_txt1, font=f_sub, fill=(148, 163, 184))
    draw.text((65, 265), sub_txt2, font=f_sub, fill=(148, 163, 184))
    
    bullets = [
        ("Standar Asian & Western ATS (Skor 90 - 98+)", "Asian & Western ATS Standard (90 - 98+ Score)"),
        ("14+ Pilihan Desain ATS & Portofolio Kreatif", "14+ Professional ATS & Creative Layouts"),
        ("Pencocok Loker AI dari Screenshot Poster", "AI Job Matcher via Vacancy Screenshot"),
        ("100% Gratis • 1-Klik Login Google OAuth", "100% Free • 1-Tap Google OAuth Login")
    ]
    
    f_bullet = get_font(13, weight=600)
    
    start_y = 312
    for i, (b_id, b_en) in enumerate(bullets):
        by = start_y + (i * 38)
        draw.rounded_rectangle([(65, by), (85, by + 20)], radius=10, fill=(6, 95, 70, 200), outline=(52, 211, 153, 180), width=1)
        draw_vector_check(draw, 75, by + 10, size=11, color=(52, 211, 153), stroke=2)
        btxt = b_id if lang == "ID" else b_en
        draw.text((95, by + 2), btxt, font=f_bullet, fill=(241, 245, 249))

    rgb_canvas = canvas.convert('RGB')
    out_dir = OUTPUT_DIR_ID if lang == "ID" else OUTPUT_DIR_EN
    filename = "featured_graphic_1024x500.png"
    dest_path = os.path.join(out_dir, filename)
    rgb_canvas.save(dest_path, "PNG", optimize=True)
    print(f"[{lang}] Featured Graphic saved: {dest_path}")
    return dest_path


# ==========================================
# 2. 9:16 APP SCREENSHOT GENERATOR (1080 x 1920 px)
# ==========================================
def create_phone_mockup(screen_img, target_screen_w=660, target_screen_h=1477, bezel=16, radius_outer=44, radius_inner=32):
    orig_w, orig_h = screen_img.size
    scale = target_screen_w / float(orig_w)
    new_h = int(orig_h * scale)
    scaled_screen = screen_img.resize((target_screen_w, new_h), Image.Resampling.LANCZOS).convert('RGBA')
    
    # Overlay clean executive status bar
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
    
    # Outer titanium frame (#161F30)
    dphone.rounded_rectangle([(0, 0), (frame_w - 1, frame_h - 1)], radius=radius_outer, fill=(22, 31, 48, 255))
    # Hairline metallic rim stroke (#334155)
    dphone.rounded_rectangle([(0, 0), (frame_w - 1, frame_h - 1)], radius=radius_outer, outline=(51, 65, 85, 255), width=2)
    # Inner bezel border
    dphone.rounded_rectangle([(bezel - 2, bezel - 2), (frame_w - bezel + 1, frame_h - bezel + 1)], radius=radius_inner + 2, outline=(15, 23, 42, 255), width=2)
    
    phone.paste(screen_surface, (bezel, bezel), screen_surface)
    
    # Multi-layered smooth shadow
    pad = 80
    shadow_w = frame_w + pad * 2
    shadow_h = frame_h + pad * 2
    
    shadow_layer = Image.new('RGBA', (shadow_w, shadow_h), (0, 0, 0, 0))
    dshadow = ImageDraw.Draw(shadow_layer)
    
    sx = pad
    sy = pad + 32
    dshadow.rounded_rectangle([(sx, sy), (sx + frame_w, sy + frame_h)], radius=radius_outer, fill=(0, 0, 0, 140))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(38))
    
    contact = Image.new('RGBA', (shadow_w, shadow_h), (0, 0, 0, 0))
    dcontact = ImageDraw.Draw(contact)
    sy2 = pad + 14
    dcontact.rounded_rectangle([(sx, sy2), (sx + frame_w, sy2 + frame_h)], radius=radius_outer, fill=(0, 0, 0, 90))
    contact = contact.filter(ImageFilter.GaussianBlur(16))
    
    shadow_layer = Image.alpha_composite(shadow_layer, contact)
    shadow_layer.paste(phone, (pad, pad), phone)
    
    return shadow_layer, pad, frame_w, frame_h

def build_screenshot_slide(
    slide_index,
    category_tag,
    headline_lines,
    subtitle_text,
    screen_img,
    out_dir,
    filename,
    accent_color=(56, 189, 248),
    glow_color=(37, 99, 235, 65)
):
    w = 1080
    h = 1920
    
    c_top = (11, 19, 43)      # #0B132B
    c_bottom = (17, 25, 48)   # #111930
    glow_pos = (540, 1150)
    canvas = create_gradient_bg(w, h, c_top, c_bottom, glow_pos, 520, glow_color)
    
    draw = ImageDraw.Draw(canvas)
    
    # 1. Category Pill Badge with clean vector indicator dot
    f_tag = get_font(19, weight=700)
    tag_bbox = f_tag.getbbox(category_tag)
    tag_text_w = tag_bbox[2] - tag_bbox[0]
    
    pill_pad_x = 24
    dot_size = 7
    dot_gap = 10
    tag_w = tag_text_w + (pill_pad_x * 2) + dot_size + dot_gap
    tag_h = 38
    tag_x = (w - tag_w) // 2
    tag_y = 70
    
    draw.rounded_rectangle([(tag_x, tag_y), (tag_x + tag_w, tag_y + tag_h)], radius=19, fill=(28, 38, 59, 230), outline=(255, 255, 255, 45), width=1)
    
    # Draw indicator dot
    dot_cx = tag_x + pill_pad_x + (dot_size // 2)
    dot_cy = tag_y + (tag_h // 2)
    draw.ellipse([(dot_cx - 4, dot_cy - 4), (dot_cx + 4, dot_cy + 4)], fill=accent_color)
    
    # Draw text
    draw.text((dot_cx + 10, tag_y + 8), category_tag, font=f_tag, fill=accent_color)
    
    # 2. Main Headline
    f_head = get_font(48, weight=800)
    line_spacing = 60
    cur_y = 126
    for line in headline_lines:
        l_bbox = f_head.getbbox(line)
        lw = l_bbox[2] - l_bbox[0]
        lx = (w - lw) // 2
        draw.text((lx, cur_y), line, font=f_head, fill=(255, 255, 255))
        cur_y += line_spacing
        
    # 3. Subtitle
    f_sub = get_font(23, weight=400)
    cur_y += 8
    sub_lines = []
    words = subtitle_text.split()
    cur_line = ""
    for word in words:
        test_line = f"{cur_line} {word}".strip()
        bbox = f_sub.getbbox(test_line)
        if (bbox[2] - bbox[0]) > 900:
            sub_lines.append(cur_line)
            cur_line = word
        else:
            cur_line = test_line
    if cur_line:
        sub_lines.append(cur_line)
        
    for sline in sub_lines:
        s_bbox = f_sub.getbbox(sline)
        sw = s_bbox[2] - s_bbox[0]
        sx = (w - sw) // 2
        draw.text((sx, cur_y), sline, font=f_sub, fill=(148, 163, 184))
        cur_y += 34
        
    # 4. Device Mockup (scaled to fit full UI perfectly)
    phone_mockup, pad, frame_w, frame_h = create_phone_mockup(
        screen_img,
        target_screen_w=660,
        target_screen_h=1477,
        bezel=16,
        radius_outer=44,
        radius_inner=32
    )
    
    phone_x = (w - frame_w) // 2
    phone_y = 390
    canvas.paste(phone_mockup, (phone_x - pad, phone_y - pad), phone_mockup)
    
    rgb_canvas = canvas.convert('RGB')
    dest_path = os.path.join(out_dir, filename)
    rgb_canvas.save(dest_path, "PNG", optimize=True)
    print(f"Saved: {filename}")
    return dest_path


# ==========================================
# PREPARE PATCHED INDONESIAN CV SCREENSHOT
# ==========================================
def get_patched_asian_ats_indonesia():
    cv_id = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-102908.jpg.jpeg"))
    cv_en = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101827.jpg.jpeg")).copy()
    
    # Paste top bar (Pratinjau PDF)
    top_bar = cv_id.crop((0, 0, 720, 180))
    cv_en.paste(top_bar, (0, 0))
    
    # Paste bottom buttons (Simpan PDF / Bagikan)
    bottom_bar = cv_id.crop((0, 1460, 720, 1612))
    cv_en.paste(bottom_bar, (0, 1460))
    
    return cv_en

# ==========================================
# MAIN EXECUTION
# ==========================================
def generate_all():
    print("--- 1. Generating Featured Graphics (1024x500) ---")
    build_featured_graphic("ID")
    build_featured_graphic("EN")
    
    print("\n--- 2. Generating Indonesian Screenshots (9:16 - 1080x1920) ---")
    # Screen 1: Asian ATS Template (CV 1)
    im_ats_id = get_patched_asian_ats_indonesia()
    build_screenshot_slide(
        slide_index=1,
        category_tag="STANDAR ATS RESMI",
        headline_lines=["Buat CV ATS Standar Global", "Lolos Seleksi Robot HRD"],
        subtitle_text="Format baku ramah parser ATS dengan jaminan skor tinggi 90-98+",
        screen_img=im_ats_id,
        out_dir=OUTPUT_DIR_ID,
        filename="01_cv_standar_ats.png",
        accent_color=(52, 211, 153),
        glow_color=(16, 185, 129, 50)
    )
    
    # Screen 2: Modern Creative Template (CV 2 - Memenuhi 'gunakan screenshoot CV ada 2')
    im_kreatif = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-102908.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=2,
        category_tag="14+ DESAIN EKSEKUTIF",
        headline_lines=["Pilihan Template Modern", "Untuk Portofolio & C-Level"],
        subtitle_text="Format visual profesional untuk melamar langsung ke HRD dan direksi",
        screen_img=im_kreatif,
        out_dir=OUTPUT_DIR_ID,
        filename="02_cv_desain_kreatif.png",
        accent_color=(56, 189, 248),
        glow_color=(37, 99, 235, 60)
    )
    
    # Screen 3: ATS Score Quality Checker
    im_skor = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-100633.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=3,
        category_tag="ATS QUALITY SCORE CHECKER",
        headline_lines=["Cek Skor Kualitas ATS", "& 1-Click Auto-Fix AI"],
        subtitle_text="Analisis mendalam 4 parameter kunci untuk maksimalkan panggilan wawancara",
        screen_img=im_skor,
        out_dir=OUTPUT_DIR_ID,
        filename="03_cek_skor_ats.png",
        accent_color=(52, 211, 153),
        glow_color=(16, 185, 129, 65)
    )
    
    # Screen 4: AI Job Matcher (Upload Screenshot)
    im_matcher = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-100745.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=4,
        category_tag="AI JOB MATCHER",
        headline_lines=["Cocokkan CV dengan Loker", "Cukup Unggah Screenshot"],
        subtitle_text="AI OCR membaca poster lowongan kerja otomatis tanpa repot salin link",
        screen_img=im_matcher,
        out_dir=OUTPUT_DIR_ID,
        filename="04_job_matcher_screenshot.png",
        accent_color=(56, 189, 248),
        glow_color=(37, 99, 235, 60)
    )
    
    # Screen 5: Rekomendasi Penyesuaian CV
    im_rekomendasi = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-100806.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=5,
        category_tag="REKOMENDASI PENYESUAIAN AI",
        headline_lines=["Evaluasi Kata Kunci Loker", "& Auto-Tailor 1-Klik"],
        subtitle_text="AI otomatis menyelaraskan kata kunci lowongan ke dalam keahlian CV Anda",
        screen_img=im_rekomendasi,
        out_dir=OUTPUT_DIR_ID,
        filename="05_rekomendasi_loker.png",
        accent_color=(56, 189, 248),
        glow_color=(37, 99, 235, 60)
    )
    
    # Screen 6: Generator Surat Lamaran AI
    im_lamaran = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-101150.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=6,
        category_tag="GENERATOR SURAT LAMARAN",
        headline_lines=["Surat Lamaran Kerja Instan", "Disesuaikan dengan Target"],
        subtitle_text="Surat pengantar profesional yang dipersonalisasi sesuai perusahaan tujuan",
        screen_img=im_lamaran,
        out_dir=OUTPUT_DIR_ID,
        filename="06_surat_lamaran_ai.png",
        accent_color=(56, 189, 248),
        glow_color=(37, 99, 235, 60)
    )
    
    # Screen 7: Editor Formulir & Pas Foto Privat
    im_editor = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-100617.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=7,
        category_tag="PENGISIAN MUDAH & PRIVAT",
        headline_lines=["Isi Data Mandiri Cepat", "Pas Foto 100% Privat di HP"],
        subtitle_text="Foto diproses di penyimpanan lokal smartphone tanpa beban ke server",
        screen_img=im_editor,
        out_dir=OUTPUT_DIR_ID,
        filename="07_editor_pasfoto_privat.png",
        accent_color=(52, 211, 153),
        glow_color=(16, 185, 129, 50)
    )
    
    # Screen 8: Profil & Multi-CV
    im_profil = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-101202.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=8,
        category_tag="100% GRATIS & AMAN",
        headline_lines=["Kelola Hingga 3 Variasi CV", "5 Kuota AI Harian Gratis"],
        subtitle_text="Login 1-klik Google OAuth, draf CV tersinkronisasi aman di cloud",
        screen_img=im_profil,
        out_dir=OUTPUT_DIR_ID,
        filename="08_profil_multi_cv.png",
        accent_color=(52, 211, 153),
        glow_color=(16, 185, 129, 50)
    )

    print("\n--- 3. Generating English Screenshots (9:16 - 1080x1920) ---")
    # EN Screen 1: Asian ATS Resume
    im_ats_en = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101827.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=1,
        category_tag="OFFICIAL ATS STANDARD",
        headline_lines=["Build ATS-Compliant Resumes", "Pass HR Screening Easily"],
        subtitle_text="HR-approved parsing layouts with guaranteed 90-98+ ATS score",
        screen_img=im_ats_en,
        out_dir=OUTPUT_DIR_EN,
        filename="01_ats_resume_standard.png",
        accent_color=(52, 211, 153),
        glow_color=(16, 185, 129, 50)
    )
    
    # EN Screen 2: Creative Resume
    im_crt_en = Image.open(os.path.join(DIR_ID_RAW, "Screenshot_20260918-102908.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=2,
        category_tag="14+ EXECUTIVE LAYOUTS",
        headline_lines=["Modern & Creative Layouts", "Stand Out to Recruiters"],
        subtitle_text="Bespoke typography and clean layouts for executive & portfolio roles",
        screen_img=im_crt_en,
        out_dir=OUTPUT_DIR_EN,
        filename="02_modern_creative_resume.png",
        accent_color=(56, 189, 248),
        glow_color=(37, 99, 235, 60)
    )
    
    # EN Screen 3: ATS Score Quality Checker
    im_skor_en = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101511.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=3,
        category_tag="ATS QUALITY SCORE CHECKER",
        headline_lines=["Instant ATS Score Checker", "& 1-Click AI Auto-Fix"],
        subtitle_text="Deep 4-metric evaluation to maximize your interview callbacks",
        screen_img=im_skor_en,
        out_dir=OUTPUT_DIR_EN,
        filename="03_ats_score_checker.png",
        accent_color=(52, 211, 153),
        glow_color=(16, 185, 129, 65)
    )
    
    # EN Screen 4: AI Job Matcher
    im_matcher_en = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101443.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=4,
        category_tag="AI JOB MATCHER",
        headline_lines=["Match Resume Against Jobs", "Simply Upload Screenshot"],
        subtitle_text="Multimodal AI OCR reads job poster requirements with zero hassle",
        screen_img=im_matcher_en,
        out_dir=OUTPUT_DIR_EN,
        filename="04_job_matcher_screenshot.png",
        accent_color=(56, 189, 248),
        glow_color=(37, 99, 235, 60)
    )
    
    # EN Screen 5: Tailoring Recommendations
    im_tailor_en = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101426.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=5,
        category_tag="KEYWORD OPTIMIZATION",
        headline_lines=["Tailor Resume to Vacancy", "Instant AI Recommendations"],
        subtitle_text="Automatically inject missing keywords and calibrate work experience",
        screen_img=im_tailor_en,
        out_dir=OUTPUT_DIR_EN,
        filename="05_tailoring_recommendations.png",
        accent_color=(56, 189, 248),
        glow_color=(37, 99, 235, 60)
    )
    
    # EN Screen 6: Cover Letter Generator
    im_letter_en = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101251.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=6,
        category_tag="COVER LETTER GENERATOR",
        headline_lines=["Generate Cover Letters", "Customized for Any Role"],
        subtitle_text="Compelling, professional application letters crafted in seconds",
        screen_img=im_letter_en,
        out_dir=OUTPUT_DIR_EN,
        filename="06_cover_letter_generator.png",
        accent_color=(56, 189, 248),
        glow_color=(37, 99, 235, 60)
    )
    
    # EN Screen 7: Resume Editor & Private Local Photo
    im_editor_en = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101722.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=7,
        category_tag="EFFORTLESS & PRIVATE",
        headline_lines=["Effortless Resume Editing", "100% Private Local Photos"],
        subtitle_text="Headshots stay securely on your device with 0 byte server load",
        screen_img=im_editor_en,
        out_dir=OUTPUT_DIR_EN,
        filename="07_resume_editor_private_photo.png",
        accent_color=(52, 211, 153),
        glow_color=(16, 185, 129, 50)
    )
    
    # EN Screen 8: Profile & Multi-Resume
    im_profile_en = Image.open(os.path.join(DIR_EN_RAW, "Screenshot_20260918-101212.jpg.jpeg"))
    build_screenshot_slide(
        slide_index=8,
        category_tag="100% FREE & SECURE",
        headline_lines=["Manage Up to 3 Resumes", "5 Free Daily AI Generations"],
        subtitle_text="1-Tap Google Sign-In with auto-reset quota and cloud sync",
        screen_img=im_profile_en,
        out_dir=OUTPUT_DIR_EN,
        filename="08_profile_multi_resume.png",
        accent_color=(52, 211, 153),
        glow_color=(16, 185, 129, 50)
    )

    print("\n[SUCCESS] ALL PLAY STORE ASSETS REGENERATED WITH FLAWLESS QUALITY!")

if __name__ == "__main__":
    generate_all()
