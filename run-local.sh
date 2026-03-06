#!/bin/bash
# Run FastAPI backend locally (no Docker) - useful for debugging
cd "$(dirname "$0")"
export FIREBASE_CREDENTIALS="${FIREBASE_CREDENTIALS:-./screen2green-tuankietbuv-firebase-adminsdk-fbsvc-af53272395.json}"
cd backend
echo "Starting backend at http://localhost:8000"
echo "Docs: http://localhost:8000/docs"
echo "Health: http://localhost:8000/health"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
