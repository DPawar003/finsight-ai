import pytesseract
from PIL import Image
import numpy as np
import cv2
import re


def _preprocess_image(image_path: str) -> Image.Image:
    img = cv2.imread(image_path)

    # Flatten any transparency onto a white background (fixes checkered/transparent PNGs)
    if img is None:
        pil_img = Image.open(image_path).convert("RGBA")
        background = Image.new("RGBA", pil_img.size, (255, 255, 255, 255))
        flattened = Image.alpha_composite(background, pil_img).convert("RGB")
        img = cv2.cvtColor(np.array(flattened), cv2.COLOR_RGB2BGR)

    # Upscale small images — OCR accuracy improves significantly on low-res receipts
    height, width = img.shape[:2]
    if width < 1200:
        scale = 1200 / width
        img = cv2.resize(img, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Adaptive threshold — handles uneven lighting/receipt paper texture better than a flat threshold
    thresh = cv2.adaptiveThreshold(
        gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 31, 15
    )

    denoised = cv2.medianBlur(thresh, 3)

    return Image.fromarray(denoised)


def extract_text_from_image(image_path: str) -> str:
    processed = _preprocess_image(image_path)
    # PSM 6 = "assume a single uniform block of text" — works better than default for receipts
    config = "--psm 6"
    return pytesseract.image_to_string(processed, config=config)


def parse_receipt_text(text: str) -> dict:
    return {
        "amount": _extract_amount(text),
        "description": _extract_merchant(text),
        "raw_text": text,
    }


def _extract_amount(text: str) -> float | None:
    lines = text.strip().split("\n")

    # Priority 1: a line explicitly containing TOTAL (not SUBTOTAL/CASH/CHANGE)
    for line in lines:
        if re.search(r"\btotal\b", line, re.IGNORECASE) and not re.search(r"sub\s*total", line, re.IGNORECASE):
            match = re.search(r"(\d+[.,]\d{2})", line)
            if match:
                return float(match.group(1).replace(",", "."))

    # Priority 2: largest decimal number found anywhere (fallback)
    all_numbers = re.findall(r"(\d+[.,]\d{2})\b", text)
    if not all_numbers:
        return None
    try:
        return max(float(n.replace(",", ".")) for n in all_numbers)
    except ValueError:
        return None


def _extract_merchant(text: str) -> str | None:
    lines = [l.strip() for l in text.strip().split("\n") if l.strip()]

    # Try to find a clean header line first (no price, looks like real text)
    for line in lines[:5]:
        if re.search(r"\d+\.\d{2}", line):
            continue
        cleaned = _clean_ocr_noise(line)
        if _looks_like_real_text(cleaned):
            return cleaned[:100]

    # Fallback: build a description from item names instead of leaving it blank
    item_summary = _build_summary_from_items(text)
    if item_summary:
        return item_summary

    return None


def _build_summary_from_items(text: str) -> str | None:
    lines = text.strip().split("\n")
    item_names = []

    for line in lines:
        # Match lines like "2 APPLE 1.00" - a quantity, an item name, a price
        match = re.match(r"^\D*(\d+)?\s*([A-Za-z][A-Za-z\s]{2,20}?)\s+\d+[.,]\d{2}", line)
        if match:
            name = match.group(2).strip().title()
            if name and name.upper() not in ("TOTAL", "CASH", "CHANGE", "SUBTOTAL"):
                item_names.append(name)

    if not item_names:
        return None

    if len(item_names) <= 3:
        return ", ".join(item_names)
    else:
        remaining = len(item_names) - 2
        return f"{item_names[0]}, {item_names[1]} +{remaining} more"


def _clean_ocr_noise(line: str) -> str:
    words = line.split()
    real_words = [w for w in words if len(w) > 2 or w.isdigit()]
    return " ".join(real_words).strip()


def _looks_like_real_text(line: str) -> bool:
    letters = sum(c.isalpha() for c in line)
    if len(line) < 3:
        return False
    return letters / len(line) >= 0.6


def _clean_ocr_noise(line: str) -> str:
    # Strip short junk tokens (1-2 char noise like "oe", "re", "Bt") often glued on by OCR
    words = line.split()
    real_words = [w for w in words if len(w) > 2 or w.isdigit()]
    return " ".join(real_words).strip()


def _looks_like_real_text(line: str) -> bool:
    letters = sum(c.isalpha() for c in line)
    if len(line) < 3:
        return False
    return letters / len(line) >= 0.6