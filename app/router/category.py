from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.category import Category
from app.schemas.category import CategoryCreate, CategoryOut

router = APIRouter(prefix="/categories", tags=["categories"])

@router.post("/", response_model=CategoryOut)
def create_category(category_in: CategoryCreate, db: Session = Depends(get_db)):
    category = Category(name=category_in.name)
    db.add(category)
    db.commit()
    db.refresh(category)
    return category

@router.get("/", response_model=List[CategoryOut])
def list_categories(db: Session = Depends(get_db)):
    return db.query(Category).all()