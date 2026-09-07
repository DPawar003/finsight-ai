from pydantic import BaseModel, ConfigDict
from datetime import datetime

class ExpenseCreate(BaseModel):
    amount: float
    description: str | None = None
    category_id: int | None = None

class ExpenseOut(BaseModel):
    id: int
    amount: float
    description: str | None
    date: datetime
    category_id: int | None

    model_config = ConfigDict(from_attributes=True)