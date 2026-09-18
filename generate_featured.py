import os
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT_PATH = r"d:\StudioProject\RESUMER\fonts\Outfit.ttf"
ICON_PATH = r"d:\StudioProject\RESUMER\mobile\assets\icons\app_icon_512.png"
OUTPUT_DIR_ID = r"d:\StudioProject\RESUMER\Playstore_Assets\INDONESIA"
OUTPUT_DIR_EN = r"d:\StudioProject\RESUMER\Playstore_Assets\INGGRIS"

CV_ID_RAW = r"d:\StudioProject\RESUMER\Screenshoots\INDONESIA\Screenshot_20260918-102908.jpg.jpeg"
CV_EN_RAW = r"d:\StudioProject\RESUMER\Screenshoots\INGGRIS\Screenshot_20260918-101827.jpg.jpeg"

def get_font(size, weight=400):
    f = ImageFont.truetype(FONT_PATH, size)
    f.set_variation_by_axes([weight])
    return f

def create_gradient_bg(width, height, c_top, c_bottom, glow_pos=None, glow_radius=400, glow_color=(30, 58, 138, 60)):
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
        glow_layer = Image.new('RGBA', (width, height), (0, 0, 0, 0))
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

def create_document_card(doc_img, target_w, target_h, radius=12):
    resized = doc_img.resize((target_w, target_h), Image.Resampling.LANCZOS).convert('RGBA')
    mask = Image.new('L', (target_w, target_h), 0)
    dmask = ImageDraw.Draw(mask)
    dmask.rounded_rectangle([(0, 0), (target_w - 1, target_h - 1)], radius=radius, fill=255)
    
    card = Image.new('RGBA', (target_w, target_h), (0, 0, 0, 0))
    card.paste(resized, (0, 0), mask)
    
    dcard = ImageDraw.Draw(card)
    dcard.rounded_rectangle([(0, 0), (target_w - 1, target_h - 1)], radius=radius, outline=(226, 232, 240, 200), width=1)
    return card

def add_shadow_to_card(card, pad=60, offset_y=16, blur=24, shadow_alpha=130):
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
    
    c_top = (7, 12, 26)       # #070C1A Midnight Oxford Navy
    c_bottom = (15, 23, 42)   # #0F172A
    glow_pos = (780, 250)     # Glow centered behind CV showcase
    glow_color = (30, 58, 138, 90) # Subtle deep sapphire
    canvas = create_gradient_bg(width, height, c_top, c_bottom, glow_pos, 460, glow_color)
    
    left_glow = create_gradient_bg(width, height, (0,0,0), (0,0,0), (120, 100), 280, (16, 185, 129, 35))
    canvas = Image.alpha_composite(canvas, left_glow)
    
    draw = ImageDraw.Draw(canvas)
    
    # 2. Extract CV crops
    im_ats = Image.open(CV_EN_RAW)
    crop_ats = im_ats.crop((40, 203, 680, 1100))
    
    im_crt = Image.open(CV_ID_RAW)
    crop_crt = im_crt.crop((35, 195, 685, 1305))
    
    # 3. Create document cards (Height ~ 395px, ratio ~ 0.70)
    card_h = 395
    card_w = int(card_h * 0.70) # ~ 276px
    
    card_ats = create_document_card(crop_ats, card_w, card_h, radius=12)
    card_crt = create_document_card(crop_crt, card_w, card_h, radius=12)
    
    shadow_ats, pad_ats = add_shadow_to_card(card_ats, pad=50, offset_y=16, blur=22, shadow_alpha=140)
    shadow_crt, pad_crt = add_shadow_to_card(card_crt, pad=50, offset_y=18, blur=24, shadow_alpha=160)
    
    # Slight luxury rotation
    rotated_ats = shadow_ats.rotate(3.5, resample=Image.Resampling.BICUBIC, expand=True)
    rotated_crt = shadow_crt.rotate(-2.5, resample=Image.Resampling.BICUBIC, expand=True)
    
    # Coordinates on canvas (Right half: X: 520 to 1024)
    pos_ats_x = 545
    pos_ats_y = 35
    canvas.paste(rotated_ats, (pos_ats_x - pad_ats, pos_ats_y - pad_ats), rotated_ats)
    
    pos_crt_x = 735
    pos_crt_y = 48
    canvas.paste(rotated_crt, (pos_crt_x - pad_crt, pos_crt_y - pad_crt), rotated_crt)
    
    # 4. Floating Badge over CVs: Skor ATS 96
    badge_w = 265
    badge_h = 46
    badge_img = Image.new('RGBA', (badge_w + 30, badge_h + 30), (0, 0, 0, 0))
    dbadge = ImageDraw.Draw(badge_img)
    dbadge.rounded_rectangle([(15, 18), (15 + badge_w, 18 + badge_h)], radius=23, fill=(0, 0, 0, 120))
    badge_img = badge_img.filter(ImageFilter.GaussianBlur(8))
    dbadge = ImageDraw.Draw(badge_img)
    dbadge.rounded_rectangle([(15, 15), (15 + badge_w, 15 + badge_h)], radius=23, fill=(6, 95, 70, 245), outline=(52, 211, 153, 220), width=1)
    
    f_badge = get_font(15, weight=800)
    f_badge_sub = get_font(12, weight=500)
    if lang == "ID":
        badge_txt = "★ Skor ATS: 96 / 100"
        badge_sub = "Top 5% ATS Ready • Lolos Seleksi"
    else:
        badge_txt = "★ ATS Score: 96 / 100"
        badge_sub = "Top 5% ATS Ready • HR Compliant"
        
    dbadge.text((32, 22), badge_txt, font=f_badge, fill=(255, 255, 255))
    dbadge.text((32, 40), badge_sub, font=f_badge_sub, fill=(167, 243, 208))
    
    canvas.paste(badge_img, (670, 405), badge_img)
    
    # 5. Label badges on top of CVs
    lbl1_w = 146
    lbl1_h = 28
    lbl1 = Image.new('RGBA', (lbl1_w, lbl1_h), (15, 23, 42, 220))
    dlbl1 = ImageDraw.Draw(lbl1)
    dlbl1.rounded_rectangle([(0,0),(lbl1_w-1, lbl1_h-1)], radius=14, outline=(255,255,255,50), width=1)
    f_lbl = get_font(11, weight=600)
    txt_lbl1 = "Standar ATS Resmi" if lang == "ID" else "Official ATS Format"
    dlbl1.text((14, 7), txt_lbl1, font=f_lbl, fill=(226, 232, 240))
    canvas.paste(lbl1, (555, 18), lbl1)
    
    lbl2_w = 148
    lbl2_h = 28
    lbl2 = Image.new('RGBA', (lbl2_w, lbl2_h), (15, 23, 42, 220))
    dlbl2 = ImageDraw.Draw(lbl2)
    dlbl2.rounded_rectangle([(0,0),(lbl2_w-1, lbl2_h-1)], radius=14, outline=(255,255,255,50), width=1)
    txt_lbl2 = "14+ Desain Kreatif" if lang == "ID" else "14+ Modern Layouts"
    dlbl2.text((14, 7), txt_lbl2, font=f_lbl, fill=(226, 232, 240))
    canvas.paste(lbl2, (815, 18), lbl2)

    # 6. Left Side: Brand, Title, Tagline, & Bullets
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
    f_check = get_font(13, weight=700)
    
    start_y = 312
    for i, (b_id, b_en) in enumerate(bullets):
        by = start_y + (i * 38)
        draw.rounded_rectangle([(65, by), (85, by + 20)], radius=10, fill=(6, 95, 70, 200), outline=(52, 211, 153, 180), width=1)
        draw.text((69, by + 3), "✓", font=f_check, fill=(52, 211, 153))
        btxt = b_id if lang == "ID" else b_en
        draw.text((95, by + 2), btxt, font=f_bullet, fill=(241, 245, 249))

    rgb_canvas = canvas.convert('RGB')
    out_dir = OUTPUT_DIR_ID if lang == "ID" else OUTPUT_DIR_EN
    filename = "featured_graphic_1024x500.png"
    dest_path = os.path.join(out_dir, filename)
    rgb_canvas.save(dest_path, "PNG", optimize=True)
    print(f"[{lang}] Featured Graphic saved to: {dest_path}")
    return dest_path

if __name__ == "__main__":
    build_featured_graphic("ID")
    build_featured_graphic("EN")
