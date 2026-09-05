from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.expense import Expense
from app.schemas.expense import ExpenseCreate, ExpenseOut

router = APIRouter(prefix="/expenses", tags=["expenses"])

@router.post("/", response_model=ExpenseOut)
def create_expense(expense_in: ExpenseCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    expense = Expense(**expense_in.model_dump(), user_id=current_user.id)
    db.add(expense)
    db.commit()
    db.refresh(expense)
    return expense

@router.get("/", response_model=List[ExpenseOut])
def list_expenses(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(Expense).filter(Expense.user_id == current_user.id).all()

@router.get("/{expense_id}", response_model=ExpenseOut)
def get_expense(expense_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    expense = db.query(Expense).filter(Expense.id == expense_id, Expense.user_id == current_user.id).first()
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    return expense

@router.put("/{expense_id}", response_model=ExpenseOut)
def update_expense(expense_id: int, expense_in: ExpenseCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    expense = db.query(Expense).filter(Expense.id == expense_id, Expense.user_id == current_user.id).first()
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    for key, value in expense_in.model_dump().items():
        setattr(expense, key, value)
    db.commit()
    db.refresh(expense)
    return expense

@router.delete("/{expense_id}")
def delete_expense(expense_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    expense = db.query(Expense).filter(Expense.id == expense_id, Expense.user_id == current_user.id).first()
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    db.delete(expense)
    db.commit()
    return {"detail": "Expense deleted"}