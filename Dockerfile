# Multi-stage Dockerfile for MyKMoments with SSR

# Stage 1: Build the C++ REST API
FROM ubuntu:22.04 as backend-builder

# Avoid prompts from apt during build
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libpq-dev \
    libssl-dev \
    zlib1g-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the entire project (includes submodules)
COPY . .

# Create a modified version of db_utils.cpp that uses environment variables
RUN sed -i 's/pqxx::connection c("dbname=mkm_db user=mkm_user password=<DBPASSWORD>");/std::string conn_str = std::getenv("DB_CONNECTION_STRING") ? std::getenv("DB_CONNECTION_STRING") : "dbname=mkm_db user=mkm_user password=<DBPASSWORD>"; pqxx::connection c(conn_str);/g' restapi/src/db_utils.cpp

# Build the REST API
WORKDIR /app/restapi
RUN mkdir -p build && cd build && \
    cmake .. && \
    make -j$(nproc)

# Stage 2: Build the Svelte SSR frontend
FROM node:18-alpine as frontend-builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code and config files
COPY src ./src
COPY static ./static
COPY svelte.config.js vite.config.js ./

# Set environment variable for SvelteKit frontend
ENV PUBLIC_API_URL=http://localhost:8080/api

# Build the frontend
RUN npm run build

# Stage 3: Runtime image with Node.js
FROM node:18-slim as runtime

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    nginx \
    gettext-base \
    bash \
    libpq5 \
    libssl3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy package files and install ALL dependencies (SSR needs dev deps too)
COPY package*.json ./
RUN npm ci

# Copy built frontend from builder stage (adapter-node creates build/ directory)
COPY --from=frontend-builder /app/build ./build
COPY --from=frontend-builder /app/static ./static
COPY --from=frontend-builder /app/package*.json ./
COPY --from=frontend-builder /app/svelte.config.js ./
COPY --from=frontend-builder /app/vite.config.js ./

# Copy built backend from builder stage
COPY --from=backend-builder /app/restapi/build/MyKMomentsRestAPI ./backend/
COPY --from=backend-builder /app/restapi/mkm_db.sql ./backend/

# Copy configuration files
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/start.sh ./
COPY docker/entrypoint.sh ./

# Make scripts executable
RUN chmod +x start.sh entrypoint.sh

# Expose ports
EXPOSE 80

# Set environment variables
ENV NODE_ENV=production \
    PUBLIC_API_URL=/api \
    DB_HOST=localhost \
    DB_PORT=5432 \
    DB_NAME=mkm_db \
    DB_USER=mkm_user \
    DB_PASSWORD=mkm_password

# Start the application
CMD ["./entrypoint.sh"]