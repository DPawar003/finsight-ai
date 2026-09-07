def get_token(client, email="graphql_test@example.com", password="testpass123"):
    client.post("/auth/signup", json={"email": email, "password": password})
    res = client.post("/auth/login", data={"username": email, "password": password})
    return res.json()["access_token"]

def test_me_query(client):
    token = get_token(client)
    response = client.post(
        "/graphql",
        json={"query": "{ me { email } }"},
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    assert response.json()["data"]["me"]["email"] == "graphql_test@example.com"

def test_add_expense_mutation(client):
    token = get_token(client, email="expense_test@example.com")
    mutation = """
    mutation {
      addExpense(input: { amount: 50.0, description: "Coffee" }) {
        id
        amount
        description
      }
    }
    """
    response = client.post(
        "/graphql",
        json={"query": mutation},
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()["data"]["addExpense"]
    assert data["amount"] == 50.0
    assert data["description"] == "Coffee"