# MyKMoments
Store all your precious moments at one place.

# Tech stack
* Front-end: Svelte.js powered by [`create-svelte`](https://github.com/sveltejs/kit/tree/master/packages/create-svelte).
* Back-end: C++ 20
* Database: PostgreSQL

# Dependencies
## Front end
* Svelte.js
* Svelte Kit
## Back end
* [Crow](https://github.com/CrowCpp/Crow/) - C++ framework for web app/service
* OpenSSL - for HTTPS
* ZLib - for compression
* Standalone ASIO - required by Crow
* libpq - C library for accessing Postgres databases
* [libpqxx](https://github.com/jtv/libpqxx) - C++ wrapper library for libpq (Postgres)
* [jwt-cpp](https://github.com/Thalhammer/jwt-cpp) - for JSON Web Tokens

# Installating some pre-requisites
```
sudo apt-get update

sudo apt-get install libpq-dev libssl-dev zlib1g-dev

# For installing postgresql server
sudo apt-get install postgresql postgresql-contrib
```

# Cloning repo
```
git clone --recurse-submodules https://github.com/Shriram-Vatturkar/mykmoments.git
cd mykmoments
git submodule init
git submodule update --init --depth 3 --recursive --jobs 4
```

# Database schema
Database schema is present [here](restapi/mkm_db.sql).

## Creating database and user
You need to create a user with all privileges named 'mkm_user' and create a database named 'mkm_db'.
1. Login to `psql`.
    ```
    sudo -u postgres -i
    psql
    ```
2. Inside `psql` terminal, run following commands:
    ```
    create database mkm_db;
    create user mkm_user with encrypted password 'YOUR_PASSWORD';
    grant all privileges on database mkm_db to mkm_user;
    ```
## Importing schema
To import the schema to the database from the file above, do the following:
1. Edit pg_hba.conf file and add an entry for your user. This file can be present in either:
    ```
    sudo vim /etc/postgresql/<version>/main/pg_hba.conf
    ```
    or
    ```
    sudo vim /var/lib/pgsql/<version>/data/
    ```
    Add the following line in the file:
    ```
    local   mkm_db          mkm_user                                password
    ```
2. Now, restart postresql service:
    ```
    sudo systemctl restart postgresql
    ```
3. Now, import the schema. It will prompt for password, enter your password for `mkm_user`.
    ```
    psql -d mkm_db -U mkm_user -f ../mkm_db.sql -L logfile.txt -W
    ```
## Inspecting database contents
Run `psql -d mkm_db -U mkm_user -W`, enter your password for `mkm_user` and then in the `psql` terminal, enter the queries you want to run.
# Building and running REST API

## Change the database password in db_utils.cpp
There will be a string `<DBPASSWORD>` that needs to be replaced with your `mkm_user` password.

## Build and run the API.
```
cd restapi
mkdir build && cd build
cmake ..
make
./MyKMomentsRestAPI
```

# 🚀 Quick Start (Recommended)

The fastest way to get MyKMoments running is with Docker. **No manual dependency installation required!**

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (2.0+)
- Git

## 1️⃣ Clone and Start

```bash
# Clone the repository with all dependencies
git clone --recurse-submodules https://github.com/Shriram-Vatturkar/mykmoments.git
cd mykmoments

# Start the application (first run will take 3-5 minutes to build)
docker-compose up --build
```

## 2️⃣ Access the Application

Once you see "Crow/1.2.1 server is running" in the logs:

- **🌐 Web Application**: http://localhost:8080
- **📱 All features available**: Create account, login, add moments, upload images

## 3️⃣ Stop the Application

```bash
# Press Ctrl+C in the terminal, or run:
docker-compose down
```

## ⚡ Features
- **🔐 User Authentication**: Secure JWT-based login system
- **📝 Moment Management**: Create, edit, delete personal moments
- **🖼️ Image Upload**: Store images with your moments
- **💾 PostgreSQL Database**: Persistent data storage
- **📱 Responsive UI**: Works on desktop and mobile

## 🐞 Troubleshooting

### Common Issues

- **Port already in use**: Change the port in `docker-compose.yml`:
  ```yaml
  ports:
    - "8081:80"  # Use port 8081 instead
  ```

- **Submodules not found**: If you cloned without `--recurse-submodules`:
  ```bash
  git submodule update --init --recursive
  ```

- **Docker build fails**: Try a clean build:
  ```bash
  docker-compose down -v
  docker-compose up --build --no-cache
  ```

### Database Access
Access the PostgreSQL database directly:
```bash
docker-compose exec db psql -U mkm_user -d mkm_db
```

---

# 🛠️ Advanced Setup & Development

For detailed Docker instructions, production deployment, and development setup, see [README.Docker.md](README.Docker.md).

<details>
<summary>📋 Manual Setup (Advanced Users)</summary>
### Running front end
Install required packages and run the frontend locally
```
npm install
npm run dev
```

</details>
