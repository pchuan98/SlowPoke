# Authentication API Testing Guide

This document describes how to test the authentication system implemented in SlowPoke.API.

## Prerequisites

- .NET 10.0 SDK installed
- bash shell (for running test script)
- curl installed

## Running the API

```bash
cd api/SlowPoke.API
dotnet run
```

The API will start on `http://localhost:5000` (or `https://localhost:5001` for HTTPS).

## Manual Testing with curl

### 1. Login with Correct Password

```bash
curl -c cookies.txt -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"password":"admin123"}'
```

Expected Response:
```json
{"success":true}
```

### 2. Login with Wrong Password

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"password":"wrongpassword"}'
```

Expected Response (401):
```json
{"error":"Invalid password"}
```

### 3. Access Protected Endpoint (Todos)

After successful login:
```bash
curl -b cookies.txt http://localhost:5000/todos
```

Without authentication:
```bash
curl http://localhost:5000/todos
```
Expected: 401 Unauthorized

### 4. Logout

```bash
curl -b cookies.txt -c cookies.txt -X POST http://localhost:5000/api/auth/logout
```

Expected Response:
```json
{"success":true}
```

## Automated Testing

Run the test script:

```bash
cd api
chmod +x test-auth-api.sh
./test-auth-api.sh
```

The script will:
1. Try to access todos without authentication (should fail with 401)
2. Try to login with wrong password (should fail with 401)
3. Login with correct password (should succeed)
4. Access todos with authentication (should succeed)
5. Logout (should succeed)
6. Try to access todos after logout (should fail with 401)

## Configuration

Default password is configured in `appsettings.json`:

```json
{
  "Auth": {
    "Password": "admin123",
    "DefaultPassword": "admin"
  }
}
```

You can override this via environment variable:
```bash
export Auth__Password="your-password"
dotnet run
```

## Cookie Settings

The authentication cookie has the following properties:

- **Name**: `SlowPoke.Auth`
- **HttpOnly**: `true` (prevents XSS attacks)
- **Secure**: `SameAsRequest` (HTTPS in production)
- **SameSite**: `Strict` (prevents CSRF attacks)
- **Expiration**: 7 days
- **Sliding Expiration**: Enabled

## API Endpoints

### POST /api/auth/login
- **Access**: Anonymous
- **Request Body**: `{"password": "string"}`
- **Success Response**: 200 + `{"success": true}` + Cookie set
- **Failure Response**: 401 + `{"error": "Invalid password"}`

### POST /api/auth/logout
- **Access**: Requires authentication
- **Success Response**: 200 + `{"success": true}` + Cookie cleared

### GET /todos
- **Access**: Requires authentication
- **Success Response**: 200 + Todo array
- **Failure Response**: 401 Unauthorized

## Troubleshooting

### Issue: 401 after login
- Check if cookies are being sent with requests
- Verify cookie is not expired
- Check browser/client cookie settings

### Issue: Login returns 500
- Check `appsettings.json` has Auth:Password configured
- Check application logs for errors

### Issue: CORS errors
- If testing from browser, may need to configure CORS in Program.cs
