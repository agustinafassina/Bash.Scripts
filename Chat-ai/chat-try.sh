#!/bin/bash
API_KEY="sk-1234"
API_URL="http://localhost:4000/v1/chat/completions"

curl $API_URL \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "model": "llama3-local",
    "messages": [
      {"role": "user", "content": "Explícame qué es Docker"}
    ],
    "temperature": 0.7,
    "max_tokens": 500
  }'
