def test_signup_and_login(client):
    signup_res = client.post("/auth/signup", json={
        "email": "test@example.com",
        "password": "testpass123",
        "full_name": "Test User"
    })
    assert signup_res.status_code == 200
    assert signup_res.json()["email"] == "test@example.com"

    login_res = client.post("/auth/login", data={
        "username": "test@example.com",
        "password": "testpass123"
    })
    assert login_res.status_code == 200
    assert "access_token" in login_res.json()