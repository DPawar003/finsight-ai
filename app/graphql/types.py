import strawberry
from datetime import datetime
from typing import Optional

@strawberry.type
class UserType:
    id: int
    email: str
    full_name: Optional[str]

@strawberry.type
class CategoryType:
    id: int
    name: str

@strawberry.type
class ExpenseType:
    id: int
    amount: float
    description: Optional[str]
    date: datetime
    category_id: Optional[int]

@strawberry.input
class ExpenseInput:
    amount: float
    description: Optional[str] = None
    category_id: Optional[int] = None

@strawberry.input
class CategoryInput:
    name: str