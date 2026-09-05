from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class Receipt(Base):
    __tablename__ = "receipts"

    id = Column(Integer, primary_key=True, index=True)
    image_path = Column(String, nullable=False)
    raw_ocr_text = Column(String, nullable=True)

    expense_id = Column(Integer, ForeignKey("expenses.id"), unique=True, nullable=False)

    expense = relationship("Expense", back_populates="receipt")