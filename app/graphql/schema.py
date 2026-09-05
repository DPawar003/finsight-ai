import strawberry
from typing import List, Optional
from app.graphql.types import ExpenseType, CategoryType, UserType, ExpenseInput, CategoryInput
from app.graphql.context import GraphQLContext
from app.models.expense import Expense
from app.models.category import Category


@strawberry.type
class Query:
    @strawberry.field
    def me(self, info: strawberry.Info[GraphQLContext]) -> UserType:
        return info.context.current_user

    @strawberry.field
    def expenses(self, info: strawberry.Info[GraphQLContext]) -> List[ExpenseType]:
        db = info.context.db
        user = info.context.current_user
        return db.query(Expense).filter(Expense.user_id == user.id).all()

    @strawberry.field
    def expense(self, info: strawberry.Info[GraphQLContext], id: int) -> Optional[ExpenseType]:
        db = info.context.db
        user = info.context.current_user
        return db.query(Expense).filter(Expense.id == id, Expense.user_id == user.id).first()

    @strawberry.field
    def categories(self, info: strawberry.Info[GraphQLContext]) -> List[CategoryType]:
        db = info.context.db
        return db.query(Category).all()


@strawberry.type
class Mutation:
    @strawberry.mutation
    def add_expense(self, info: strawberry.Info[GraphQLContext], input: ExpenseInput) -> ExpenseType:
        db = info.context.db
        user = info.context.current_user
        expense = Expense(
            amount=input.amount,
            description=input.description,
            category_id=input.category_id,
            user_id=user.id,
        )
        db.add(expense)
        db.commit()
        db.refresh(expense)
        return expense

    @strawberry.mutation
    def update_expense(self, info: strawberry.Info[GraphQLContext], id: int, input: ExpenseInput) -> Optional[ExpenseType]:
        db = info.context.db
        user = info.context.current_user
        expense = db.query(Expense).filter(Expense.id == id, Expense.user_id == user.id).first()
        if not expense:
            return None
        expense.amount = input.amount
        expense.description = input.description
        expense.category_id = input.category_id
        db.commit()
        db.refresh(expense)
        return expense

    @strawberry.mutation
    def delete_expense(self, info: strawberry.Info[GraphQLContext], id: int) -> bool:
        db = info.context.db
        user = info.context.current_user
        expense = db.query(Expense).filter(Expense.id == id, Expense.user_id == user.id).first()
        if not expense:
            return False
        db.delete(expense)
        db.commit()
        return True

    @strawberry.mutation
    def add_category(self, info: strawberry.Info[GraphQLContext], input: CategoryInput) -> CategoryType:
        db = info.context.db
        category = Category(name=input.name)
        db.add(category)
        db.commit()
        db.refresh(category)
        return category


schema = strawberry.Schema(query=Query, mutation=Mutation)