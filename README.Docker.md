# Docker Setup for MyKMoments

This guide provides instructions for running MyKMoments using Docker, which simplifies the setup process and ensures consistency across different development environments.

## Prerequisites

- Docker (v20.10+)
- Docker Compose (v2.0+)
- Git with submodule support

## Quick Start

1. **Clone the repository with submodules:**
   ```bash
   git clone --recurse-submodules https://github.com/Shriram-Vatturkar/mykmoments.git
   cd mykmoments
   ```

   If you already cloned without submodules:
   ```bash
   git submodule init
   git submodule update --init --depth 3 --recursive --jobs 4
   ```

2. **Start the application:**
   ```bash
   docker-compose up --build
   ```

3. **Access the application:**
   - Frontend: http://localhost:8080
   - Backend API: http://localhost:18080
   - Database: localhost:5432 (for direct access)

## Services

The Docker setup includes three main services:

### Database (PostgreSQL 14)
- **Container**: `mykmoments_db`
- **Port**: 5432
- **Database**: `mkm_db`
- **User**: `mkm_user`
- **Password**: `mkm_password` (configurable)

### Application (Backend + Frontend)
- **Container**: `mykmoments_app`
- **Ports**: 
  - 8080 (Frontend served by Nginx)
  - 18080 (Backend REST API)
- **Features**:
  - Multi-stage build for optimized image size
  - C++ backend with Crow framework
  - Svelte frontend with Vite
  - Nginx reverse proxy for API routing

## Configuration

### Environment Variables

You can customize the database configuration by modifying the environment variables in `docker-compose.yml`:

```yaml
environment:
  DB_HOST: db
  DB_PORT: 5432
  DB_NAME: mkm_db
  DB_USER: mkm_user
  DB_PASSWORD: your_secure_password
```

### Database Password

1. Update the password in `docker-compose.yml` for both `db` and `app` services
2. Rebuild the containers: `docker-compose up --build`

## Database Management

### Accessing the Database

```bash
# Using docker-compose
docker-compose exec db psql -U mkm_user -d mkm_db

# Or directly with docker
docker exec -it mykmoments_db psql -U mkm_user -d mkm_db
```

### Database Initialization

The database schema is automatically initialized on first startup using the SQL file at `restapi/mkm_db.sql`. The schema includes:
- User management tables
- Moments storage with image support
- PostgreSQL extensions (pgcrypto for password hashing)

### Backup and Restore

```bash
# Backup
docker-compose exec db pg_dump -U mkm_user -d mkm_db > backup.sql

# Restore
docker-compose exec -T db psql -U mkm_user -d mkm_db < backup.sql
```

## Development

### Building Images

```bash
# Build only the application image
docker-compose build app

# Build with no cache (clean build)
docker-compose build --no-cache
```

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app
docker-compose logs -f db
```

### Development Mode

For development, you can mount local directories to enable live reloading:

```yaml
# Add to docker-compose.yml under app service
volumes:
  - ./src:/app/frontend-src:ro
  - ./restapi/src:/app/backend-src:ro
```

## Architecture

The Docker setup uses a multi-stage build approach:

1. **Backend Builder Stage**: Compiles the C++ REST API with all dependencies
2. **Frontend Builder Stage**: Builds the Svelte application using Node.js
3. **Runtime Stage**: Combines both applications in a lightweight Ubuntu runtime

### Key Features

- **Multi-stage builds** for optimized image size
- **Health checks** ensure database readiness before starting the application
- **Automatic schema initialization** on first run
- **Nginx reverse proxy** for serving frontend and proxying API calls
- **Environment-based configuration** for different deployment scenarios

## Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   # Change ports in docker-compose.yml
   ports:
     - "8081:80"      # Frontend on port 8081
     - "18081:18080"  # Backend on port 18081
   ```

2. **Database connection issues:**
   ```bash
   # Check if database is running
   docker-compose ps db
   
   # Check database logs
   docker-compose logs db
   ```

3. **Build failures:**
   ```bash
   # Clean build with no cache
   docker-compose build --no-cache
   
   # Remove all containers and volumes
   docker-compose down -v
   ```

### Cleaning Up

```bash
# Stop and remove containers
docker-compose down

# Remove containers and volumes (destroys database data)
docker-compose down -v

# Remove images
docker-compose down --rmi all
```

## Support

For issues related to the Docker setup, please check:
1. Docker and Docker Compose versions
2. Available disk space and memory
3. Network connectivity
4. Logs from all services

For application-specific issues, refer to the main [README.md](README.md) file. 