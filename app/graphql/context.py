from fastapi import Depends
from sqlalchemy.orm import Session
from strawberry.fastapi import BaseContext
from app.core.database import get_db
from app.core.deps import get_current_user_optional
from app.models.user import User

class GraphQLContext(BaseContext):
    def __init__(self, db: Session, current_user: User):
        self.db = db
        self.current_user = current_user

async def get_context(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_optional),
) -> GraphQLContext:
    return GraphQLContext(db=db, current_user=current_user)