from pydantic import BaseModel, ConfigDict

class UserCreate(BaseModel):
    email: str
    full_name: str | None = None
    password: str


class UserOut(BaseModel):
    id: int
    email: str
    full_name: str | None = None

    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    access_token: str
    token_type: str