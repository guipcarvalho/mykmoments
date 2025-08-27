#!/bin/bash

# Wait for database to be ready
echo "Waiting for database to be ready..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
    echo "Database is unavailable - sleeping"
    sleep 2
done
echo "Database is ready!"

# Check if database schema is already initialized
TABLES_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null || echo "0")

if [ "$TABLES_COUNT" -eq "0" ] || [ "$TABLES_COUNT" = "" ]; then
    echo "Database appears to be empty, initializing schema..."
    PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f backend/mkm_db.sql
    if [ $? -eq 0 ]; then
        echo "Database schema initialized successfully"
    else
        echo "Failed to initialize database schema"
        exit 1
    fi
else
    echo "Database schema already exists, skipping initialization."
fi

# Configure database connection string for the C++ backend
export DB_CONNECTION_STRING="dbname=$DB_NAME user=$DB_USER password=$DB_PASSWORD host=$DB_HOST port=$DB_PORT"

echo "Configuring database connection..."
echo "Starting MyKMoments REST API with database connection: $DB_CONNECTION_STRING"

# Start the C++ backend in the background
cd backend
./MyKMomentsRestAPI &
BACKEND_PID=$!

# Go back to app directory for frontend
cd /app

# Start the Node.js SSR frontend in the background
echo "Starting SvelteKit SSR frontend..."
export PORT=3000
export HOST=0.0.0.0
node build/index.js &
FRONTEND_PID=$!

# Wait for both processes
wait $BACKEND_PID $FRONTEND_PID
