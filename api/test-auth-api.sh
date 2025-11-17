#!/bin/bash

# SlowPoke Authentication API Test Script
# This script tests the authentication endpoints

BASE_URL="http://localhost:5000"
COOKIE_JAR="cookies.txt"

echo "========================================="
echo "SlowPoke Authentication API Test"
echo "========================================="
echo ""

# Clean up cookies file
rm -f $COOKIE_JAR

# Test 1: Access todos without authentication (should return 401)
echo "Test 1: Access /todos without authentication (should fail with 401)"
response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/todos")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 401 ]; then
    echo "✓ PASS: Got 401 Unauthorized as expected"
else
    echo "✗ FAIL: Expected 401, got $http_code"
fi
echo ""

# Test 2: Login with wrong password (should return 401)
echo "Test 2: Login with wrong password (should fail with 401)"
response=$(curl -s -w "\n%{http_code}" -c $COOKIE_JAR -X POST "$BASE_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"password":"wrongpassword"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 401 ]; then
    echo "✓ PASS: Got 401 Unauthorized as expected"
    echo "Response: $body"
else
    echo "✗ FAIL: Expected 401, got $http_code"
fi
echo ""

# Test 3: Login with correct password (should return 200 and set cookie)
echo "Test 3: Login with correct password (should succeed)"
response=$(curl -s -w "\n%{http_code}" -c $COOKIE_JAR -X POST "$BASE_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"password":"admin123"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo "✓ PASS: Login successful"
    echo "Response: $body"
    echo "Cookie saved to $COOKIE_JAR"
else
    echo "✗ FAIL: Expected 200, got $http_code"
    echo "Response: $body"
fi
echo ""

# Test 4: Access todos with authentication (should return 200)
echo "Test 4: Access /todos with authentication (should succeed)"
response=$(curl -s -w "\n%{http_code}" -b $COOKIE_JAR -X GET "$BASE_URL/todos")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo "✓ PASS: Successfully accessed todos"
    echo "Response: $body"
else
    echo "✗ FAIL: Expected 200, got $http_code"
    echo "Response: $body"
fi
echo ""

# Test 5: Logout (should return 200 and clear cookie)
echo "Test 5: Logout (should succeed)"
response=$(curl -s -w "\n%{http_code}" -b $COOKIE_JAR -c $COOKIE_JAR -X POST "$BASE_URL/api/auth/logout")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo "✓ PASS: Logout successful"
    echo "Response: $body"
else
    echo "✗ FAIL: Expected 200, got $http_code"
    echo "Response: $body"
fi
echo ""

# Test 6: Access todos after logout (should return 401)
echo "Test 6: Access /todos after logout (should fail with 401)"
response=$(curl -s -w "\n%{http_code}" -b $COOKIE_JAR -X GET "$BASE_URL/todos")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 401 ]; then
    echo "✓ PASS: Got 401 Unauthorized as expected"
else
    echo "✗ FAIL: Expected 401, got $http_code"
fi
echo ""

# Clean up
rm -f $COOKIE_JAR

echo "========================================="
echo "All tests completed!"
echo "========================================="
