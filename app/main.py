from fastapi import FastAPI
from app.router import auth, expenses
from app.router import category

app = FastAPI(title="FinSight AI API")

app.include_router(auth.router)
app.include_router(expenses.router)
app.include_router(category.router)

@app.get("/health")
def health_check():
    return {"status": "ok"}