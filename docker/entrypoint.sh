#!/bin/bash

# Start nginx in the background
echo "Starting nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Wait for database and start the application services
echo "Starting application services..."
./start.sh &
APP_PID=$!

# Function to handle shutdown
shutdown() {
    echo "Shutting down services..."
    kill $NGINX_PID $APP_PID 2>/dev/null
    wait $NGINX_PID $APP_PID 2>/dev/null
    exit 0
}

# Trap signals
trap shutdown SIGTERM SIGINT

# Wait for both processes
wait
