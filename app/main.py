from fastapi import FastAPI
from strawberry.fastapi import GraphQLRouter
from app.router import auth, receipts
from app.graphql.schema import schema
from app.graphql.context import get_context

app = FastAPI(title="FinSight AI API")

app.include_router(auth.router)
app.include_router(receipts.router)

graphql_app = GraphQLRouter(schema, context_getter=get_context)
app.include_router(graphql_app, prefix="/graphql")

@app.get("/health")
def health_check():
    return {"status": "ok"}