import os
import shutil
import uuid
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from app.core.deps import get_current_user
from app.models.user import User
from app.services.ocr import extract_text_from_image, parse_receipt_text

router = APIRouter(prefix="/receipts", tags=["receipts"])

UPLOAD_DIR = "uploads/receipts"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/scan")
async def scan_receipt(file: UploadFile = File(...), current_user: User = Depends(get_current_user)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    filename = f"{uuid.uuid4().hex}_{file.filename}"
    filepath = os.path.join(UPLOAD_DIR, filename)

    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    try:
        text = extract_text_from_image(filepath)
        parsed = parse_receipt_text(text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OCR failed: {str(e)}")

    return parsed