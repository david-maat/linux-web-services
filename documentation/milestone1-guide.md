# Milestone 1 - Docker Compose Stack Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Project Structure](#project-structure)
5. [Configuration Files](#configuration-files)
6. [Environment Variables](#environment-variables)
7. [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)
8. [Service Descriptions](#service-descriptions)
9. [Verification and Testing](#verification-and-testing)
10. [Troubleshooting](#troubleshooting)
11. [Cleanup](#cleanup)

---

## Overview

This Docker Compose stack creates a scalable web application infrastructure with the following components:

- **Traefik**: Reverse proxy with automatic HTTPS/SSL certificate management
- **Web Servers (Apache/PHP)**: Three replicas of Apache web servers with PHP-FPM support
- **MySQL Database**: Persistent database backend
- **phpMyAdmin**: Web-based database administration tool

The stack demonstrates:
- Load balancing across multiple web server instances
- Automatic SSL certificate provisioning via Let's Encrypt
- Container health monitoring
- Service dependencies and startup ordering
- Persistent data storage

---

## Architecture

```
                    Internet
                       ↓
                  Traefik (Reverse Proxy)
                  Port 443 (HTTPS)
                  Port 80 (HTTP → redirects to HTTPS)
                  Port 8080 (Dashboard)
                       ↓
          ┌────────────┴────────────┐
          ↓                         ↓
    Web Servers (×3)          phpMyAdmin
    Ports 8085-8087           Port 8088
    (Load Balanced)
          ↓
       MySQL Database
    (Internal Network)
```

---

## Prerequisites

Before deploying this stack, ensure you have:

1. **Docker Engine** (version 20.10 or later)
   - Check version: `docker --version`
   
2. **Docker Compose** (version 2.0 or later)
   - Check version: `docker compose version`

3. **Operating System**: 
   - Linux (recommended for production)
   - Windows with WSL2 or Docker Desktop
   - macOS with Docker Desktop

4. **Domain Name** (for production with real SSL certificates)
   - DNS properly configured to point to your server's IP

5. **Network Requirements**:
   - Ports 80, 443, 8080, 8085-8088 available
   - Internet connection for pulling images and obtaining SSL certificates

---

## Project Structure

```
Milestone 1/
├── docker-compose.yml          # Main orchestration file
├── webserver/                  # Web server configuration
│   ├── Dockerfile              # Custom Apache/PHP image
│   ├── 000-default.conf        # Apache VirtualHost configuration
│   ├── init.sql                # Database initialization script
│   └── www/                    # Web application files
│       └── index.php           # Main application file
```

---

## Configuration Files

### docker-compose.yml

The main orchestration file that defines all services, networks, and volumes.

**Key sections explained:**
- `services`: Defines each container/service
- `volumes`: Named volumes for persistent data
- `depends_on`: Service startup dependencies
- `healthcheck`: Container health monitoring
- `labels`: Traefik routing configuration

### Dockerfile

Custom image based on Ubuntu 24.04 with:
- Apache web server
- PHP 8.3 with FPM (FastCGI Process Manager)
- MySQL PHP extension
- Security hardening (non-root user)

### 000-default.conf

Apache VirtualHost configuration that:
- Sets up document root at `/var/www/html`
- Configures PHP-FPM integration via Unix socket
- Enables directory permissions

### init.sql

Database initialization script that:
- Creates a `users` table
- Inserts sample data

### index.php

PHP application that:
- Connects to MySQL database
- Displays user data
- Shows which container is serving the request (for load balancing verification)

---

## Environment Variables

Create a `.env` file in the `Milestone 1/` directory with the following variables:

```env
# Email for Let's Encrypt notifications
EMAIL=your-email@example.com

# Domain name for your application
DOMAIN=yourdomain.com

# ACME Server (use staging for testing)
# Staging: https://acme-staging-v02.api.letsencrypt.org/directory
# Production: https://acme-v02.api.letsencrypt.org/directory
ACME_SERVER=https://acme-staging-v02.api.letsencrypt.org/directory

# MySQL Configuration
MYSQL_ROOT_PASSWORD=secure_root_password_here
MYSQL_DATABASE=milestone_db
MYSQL_USER=milestone_user
MYSQL_PASSWORD=secure_user_password_here
```

**Parameter Explanations:**

| Variable | Description | Example |
|----------|-------------|---------|
| `EMAIL` | Email address for Let's Encrypt certificate notifications | `admin@example.com` |
| `DOMAIN` | Your domain name for the web application | `example.com` or `www.example.com` |
| `ACME_SERVER` | Let's Encrypt API endpoint (staging or production) | Use staging for testing |
| `MYSQL_ROOT_PASSWORD` | MySQL root user password (keep secure!) | Strong password with special chars |
| `MYSQL_DATABASE` | Name of the database to create | `milestone_db` |
| `MYSQL_USER` | MySQL user for the application | `milestone_user` |
| `MYSQL_PASSWORD` | Password for the MySQL user | Strong password |

---

## Step-by-Step Deployment Guide

### Step 1: Clone or Navigate to Project Directory

```powershell
cd "c:\Users\David\OneDrive - Thomas More\Semester 3\Linux Web Services\git\Milestone 1"
```

**Explanation**: Navigate to the directory containing the `docker-compose.yml` file.

---

### Step 2: Create Environment File

Create a `.env` file with your configuration:

```powershell
vim .env
```

**Explanation**: This opens vim to create the environment file. Paste the environment variables from the [Environment Variables](#environment-variables) section and save.

**Screenshot placeholder**: [Insert screenshot of .env file contents]

---

### Step 3: Validate Docker Compose Configuration

```powershell
docker compose config
```

**Explanation**: This command validates the syntax of your `docker-compose.yml` file and shows the merged configuration with environment variables substituted.

**What to look for:**
- No error messages
- Environment variables properly substituted
- All services listed correctly

**Screenshot placeholder**: [Insert screenshot of docker compose config output]

---

### Step 4: Pull Required Docker Images

```powershell
docker compose pull
```

**Explanation**: Downloads all required Docker images before building. This separates the download process from the build process.

**Images pulled:**
- `traefik:v3.2` (Reverse proxy)
- `mysql:lts` (Database)
- `phpmyadmin:latest` (Database admin tool)
- `ubuntu:24.04` (Base image for custom web server)

**Screenshot placeholder**: [Insert screenshot of docker compose pull progress]

---

### Step 5: Build Custom Images

```powershell
docker compose build
```

**Explanation**: Builds the custom web server image defined in `webserver/Dockerfile`. This includes:
- Installing Apache and PHP
- Configuring PHP-FPM
- Setting up a non-root user for security
- Copying application files

**Parameters in Dockerfile explained:**

| Instruction | Purpose |
|-------------|---------|
| `FROM ubuntu:24.04@sha256:...` | Base image with specific digest for reproducibility |
| `RUN apt update && apt install...` | Install Apache, PHP, and required extensions |
| `RUN useradd -r -u 1001...` | Create non-root user for running Apache (security best practice) |
| `COPY ./www /var/www/html` | Copy application files into the image |
| `RUN chown -R apacheuser:www-data...` | Set proper file permissions |
| `EXPOSE 80` | Document that container listens on port 80 |
| `CMD ["/start.sh"]` | Default command to run when container starts |

**Screenshot placeholder**: [Insert screenshot of docker compose build output]

---

### Step 6: Start the Stack

```powershell
docker compose up -d
```

**Explanation**: Starts all services in detached mode (runs in background).

**Flags explained:**
- `-d` or `--detach`: Run containers in the background

**What happens:**
1. Creates a custom Docker network for the services
2. Creates named volumes for persistent data
3. Starts MySQL container first (dependency)
4. Waits for MySQL health check to pass
5. Starts web server containers (3 replicas)
6. Starts phpMyAdmin
7. Starts Traefik reverse proxy

**Screenshot placeholder**: [Insert screenshot of docker compose up -d output]

---

### Step 7: Monitor Container Status

```powershell
docker compose ps
```

**Explanation**: Shows the status of all containers in the stack.

**Status indicators:**
- `Up (healthy)`: Container is running and passed health checks
- `Up (health: starting)`: Container is running but health check hasn't passed yet
- `Exit`: Container has stopped

**Screenshot placeholder**: [Insert screenshot of docker compose ps output showing all healthy containers]

---

### Step 8: View Container Logs

Check logs for all services:
```powershell
docker compose logs
```

Check logs for a specific service:
```powershell
docker compose logs traefik
```

Follow logs in real-time:
```powershell
docker compose logs -f contapa2-m1-dm
```

**Flags explained:**
- `-f` or `--follow`: Stream logs in real-time (like `tail -f`)
- `--tail=100`: Show only last 100 lines
- `--timestamps`: Add timestamps to log entries

**Screenshot placeholder**: [Insert screenshot of docker compose logs output]

---

### Step 9: Verify Network and Volumes

List networks:
```powershell
docker network ls
```

Inspect the stack's network:
```powershell
docker network inspect milestone1_default
```

List volumes:
```powershell
docker volume ls
```

**Explanation**: 
- Docker Compose creates a custom bridge network for service communication
- Named volumes persist data even when containers are removed
- Volumes: `db_data` (MySQL data), `traefik-certs` (SSL certificates)

**Screenshot placeholder**: [Insert screenshot of docker network and volume listings]

---

### Step 10: Scale Web Servers (Optional)

Scale to a different number of replicas:
```powershell
docker compose up -d --scale contapa2-m1-dm=5
```

**Explanation**: Changes the number of web server instances. Traefik automatically detects new containers and adds them to the load balancer.

**Screenshot placeholder**: [Insert screenshot of scaled containers]

---

## Service Descriptions

### 1. Traefik (Reverse Proxy)

**Image**: `traefik:v3.2`

**Purpose**: Acts as a reverse proxy and load balancer with automatic HTTPS certificate management.

**Ports Exposed:**
- `80`: HTTP entry point (redirects to HTTPS)
- `443`: HTTPS entry point
- `8080`: Traefik dashboard (insecure mode for development)

**Command-line Parameters Explained:**

| Parameter | Explanation |
|-----------|-------------|
| `--api.dashboard=true` | Enable the Traefik web dashboard |
| `--api.insecure=true` | Allow dashboard access without authentication (dev only) |
| `--ping=true` | Enable ping endpoint for health checks |
| `--entrypoints.web.address=:80` | Create HTTP entry point on port 80 |
| `--entrypoints.web.http.redirections.entrypoint.to=websecure` | Redirect HTTP to HTTPS |
| `--entrypoints.web.http.redirections.entrypoint.scheme=https` | Use HTTPS scheme for redirects |
| `--entrypoints.web.http.redirections.entrypoint.permanent=true` | Use HTTP 301 (permanent redirect) |
| `--entrypoints.websecure.address=:443` | Create HTTPS entry point on port 443 |
| `--certificatesresolvers.letsencrypt.acme.email=${EMAIL}` | Email for Let's Encrypt notifications |
| `--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json` | Where to store certificates |
| `--certificatesresolvers.letsencrypt.acme.caserver=${ACME_SERVER}` | Let's Encrypt server (staging/prod) |
| `--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web` | Use HTTP-01 challenge on port 80 |
| `--providers.docker=true` | Enable Docker provider |
| `--providers.docker.endpoint=unix:///var/run/docker.sock` | Docker socket location |
| `--providers.docker.exposedbydefault=false` | Require explicit `traefik.enable=true` label |
| `--log.level=INFO` | Set logging verbosity |

**Volumes:**
- `/var/run/docker.sock:/var/run/docker.sock:ro`: Docker socket (read-only) for service discovery
- `traefik-certs:/letsencrypt`: Persistent storage for SSL certificates

**Health Check:**
```yaml
test: ["CMD", "traefik", "healthcheck", "--ping"]
interval: 5s      # Check every 5 seconds
timeout: 3s       # Fail if check takes > 3 seconds
retries: 3        # Retry 3 times before marking unhealthy
start_period: 5s  # Grace period before starting checks
```

**Dependencies:**
- Depends on `contapa2-m1-dm` being healthy before starting

---

### 2. Web Server (contapa2-m1-dm)

**Build Context**: `./webserver/Dockerfile`

**Purpose**: Apache web server with PHP-FPM serving the application.

**Ports Exposed:**
- `8085-8087:80`: Maps host ports 8085, 8086, 8087 to container port 80 for 3 replicas

**Deployment:**
```yaml
deploy:
  replicas: 3  # Run 3 instances of this service
```

**Explanation**: Docker Compose will start 3 containers from this service definition. Each gets a unique name (contapa2-m1-dm-1, contapa2-m1-dm-2, contapa2-m1-dm-3).

**Environment Variables:**

| Variable | Purpose | Value Source |
|----------|---------|--------------|
| `MYSQL_HOST` | Database hostname | Hardcoded: `contsql-m1-dm` |
| `MYSQL_DATABASE` | Database name | From `.env` file |
| `MYSQL_USER` | Database username | From `.env` file |
| `MYSQL_PASSWORD` | Database password | From `.env` file |
| `COMPOSE_PROJECT_NAME` | Project namespace | Hardcoded: `milestone1` |

**Volumes:**
- `./webserver/www:/var/www/html`: Bind mount for live code updates (development)

**Traefik Labels:**

| Label | Explanation |
|-------|-------------|
| `traefik.enable=true` | Enable Traefik routing for this service |
| `traefik.http.routers.web.rule=Host(\`${DOMAIN}\`)` | Route requests matching this domain |
| `traefik.http.routers.web.entrypoints=websecure` | Use HTTPS entry point |
| `traefik.http.routers.web.tls.certresolver=letsencrypt` | Use Let's Encrypt for SSL |
| `traefik.http.services.web.loadbalancer.server.port=80` | Backend container port |

**Health Check:**
```yaml
test: ["CMD", "curl", "-f", "-s", "http://localhost/"]
interval: 30s     # Check every 30 seconds
timeout: 10s      # Fail if check takes > 10 seconds
retries: 3        # Retry 3 times before marking unhealthy
start_period: 10s # Wait 10s before starting checks
```

**Explanation**: Uses `curl` to test if the web server responds on port 80.

**Dependencies:**
- Depends on `mysql` being healthy before starting

---

### 3. MySQL Database

**Image**: `mysql:lts@sha256:5367102acfefeaa47eb0eb57c8d4f8b96c8c14004859131eac9bbfaa62f81e34`

**Purpose**: Persistent relational database backend.

**Image Digest Explanation:**
- Using `@sha256:...` pins the exact image version for reproducibility
- `lts` tag points to Long Term Support version of MySQL

**Container Name**: `contsql-m1-dm`

**Restart Policy**: `always` - Container restarts automatically if it stops

**Environment Variables:**

| Variable | Purpose |
|----------|---------|
| `MYSQL_ROOT_PASSWORD` | Password for MySQL root user |
| `MYSQL_DATABASE` | Database to create on initialization |
| `MYSQL_USER` | Non-root user to create |
| `MYSQL_PASSWORD` | Password for the non-root user |

**Health Check:**
```yaml
test: ["CMD-SHELL", "mysqladmin ping -h localhost -u${MYSQL_USER} -p${MYSQL_ROOT_PASSWORD} || exit 1"]
interval: 10s      # Check every 10 seconds
timeout: 5s        # Fail if check takes > 5 seconds
retries: 5         # Retry 5 times before marking unhealthy
start_period: 30s  # Wait 30s before starting (MySQL needs time to initialize)
```

**Explanation**: Uses `mysqladmin ping` to verify MySQL is accepting connections.

**Volumes:**

| Volume | Purpose |
|--------|---------|
| `db_data:/var/lib/mysql` | Persistent storage for database files |
| `./webserver/init.sql:/docker-entrypoint-initdb.d/init.sql` | Initialization script |

**Initialization Process:**
1. MySQL container starts
2. Creates database specified in `MYSQL_DATABASE`
3. Creates user specified in `MYSQL_USER`
4. Runs all `.sql` files in `/docker-entrypoint-initdb.d/`
5. Sets root password

---

### 4. phpMyAdmin

**Image**: `phpmyadmin:latest`

**Purpose**: Web-based database administration interface.

**Container Name**: `phpmyadmin-m1-dm`

**Ports Exposed:**
- `8088:80`: Access phpMyAdmin at http://localhost:8088

**Environment Variables:**

| Variable | Value | Purpose |
|----------|-------|---------|
| `PMA_HOST` | `mysql` | Hostname of MySQL server to connect to |

**Explanation**: `PMA_HOST` uses Docker's internal DNS to resolve the MySQL service name to its IP address.

**Restart Policy**: `always` - Ensures phpMyAdmin is always available

---

## Verification and Testing

### 1. Access Traefik Dashboard

Open your browser and navigate to:
```
http://localhost:8080
```

**What to check:**
- HTTP routers are configured
- All backend servers are listed
- Health status is green

**Screenshot placeholder**: [Insert screenshot of Traefik dashboard]

---

### 2. Access Web Application (Local)

Test direct access to individual web server replicas:

```
http://localhost:8085
http://localhost:8086
http://localhost:8087
```

**Expected Result:**
- Page displays "David Maat has reached Milestone 1!!"
- Shows container hostname (different for each port)

**Screenshot placeholder**: [Insert screenshot of web application showing different container hostnames]

---

### 3. Access Web Application (via Traefik)

**For local testing without a domain:**

Edit your hosts file:
- Windows: `C:\Windows\System32\drivers\etc\hosts`
- Linux/Mac: `/etc/hosts`

Add:
```
127.0.0.1 yourdomain.com
```

Then access:
```
https://yourdomain.com
```

**Note**: You'll get a certificate warning with staging certificates - this is expected.

**Screenshot placeholder**: [Insert screenshot of application via HTTPS]

---

### 4. Test Load Balancing

Refresh the page multiple times and observe the "Served by container" hostname changing between:
- `contapa2-m1-dm-1`
- `contapa2-m1-dm-2`
- `contapa2-m1-dm-3`

**Explanation**: Traefik distributes requests across all healthy backend servers.

**Screenshot placeholder**: [Insert screenshot showing different container names on refresh]

---

### 5. Access phpMyAdmin

Navigate to:
```
http://localhost:8088
```

**Login credentials:**
- **Server**: `contsql-m1-dm`
- **Username**: Value from `MYSQL_USER` in .env
- **Password**: Value from `MYSQL_PASSWORD` in .env

**What to check:**
- Database `milestone_db` exists
- Table `users` contains "David Maat"

**Screenshot placeholder**: [Insert screenshot of phpMyAdmin showing database and table]

---

### 6. Verify Container Health

Check all containers are healthy:
```powershell
docker compose ps
```

All services should show:
- **State**: Up
- **Health**: healthy

**Screenshot placeholder**: [Insert screenshot of all healthy containers]

---

### 7. Test Database Connectivity

Execute SQL query directly:
```powershell
docker compose exec mysql mysql -u milestone_user -p milestone_db -e "SELECT * FROM users;"
```

**Explanation:**
- `docker compose exec mysql`: Execute command in MySQL container
- `mysql -u milestone_user -p`: Connect as application user
- `milestone_db`: Database name
- `-e "SELECT * FROM users;"`: Execute query

**Expected Output:**
```
+----+-------------+
| id | name        |
+----+-------------+
|  1 | David Maat  |
+----+-------------+
```

**Screenshot placeholder**: [Insert screenshot of SQL query output]

---

### 8. Test Container Recovery

Stop one web server container:
```powershell
docker stop milestone1-contapa2-m1-dm-1
```

Observe:
- Container automatically restarts (no restart policy set, so it won't restart)
- Load balancer continues serving from remaining containers
- Traefik removes unhealthy container from rotation

Check status:
```powershell
docker compose ps
```

**Screenshot placeholder**: [Insert screenshot showing recovery]

---

### 9. View Resource Usage

Monitor CPU and memory usage:
```powershell
docker stats
```

**Columns explained:**
- `CONTAINER ID`: Unique container identifier
- `CPU %`: Percentage of host CPU used
- `MEM USAGE / LIMIT`: Current memory / maximum allowed
- `MEM %`: Percentage of available memory used
- `NET I/O`: Network bytes sent/received
- `BLOCK I/O`: Disk bytes read/written

**Screenshot placeholder**: [Insert screenshot of docker stats]

---

## Troubleshooting

### Issue: Containers fail to start

**Symptoms**: Services exit immediately after starting

**Diagnosis:**
```powershell
docker compose logs
```

**Common Causes:**
1. **Port conflicts**: Another service using ports 80, 443, 8080, 8085-8088
   - **Solution**: Stop conflicting services or change ports in `docker-compose.yml`

2. **Missing environment variables**: `.env` file not found or incomplete
   - **Solution**: Verify `.env` file exists and contains all required variables

3. **MySQL initialization failure**
   - **Solution**: Check MySQL logs: `docker compose logs mysql`

---

### Issue: Cannot access web application

**Symptoms**: Browser shows "connection refused" or "site cannot be reached"

**Diagnosis:**
```powershell
# Check if containers are running
docker compose ps

# Check if ports are listening
netstat -an | findstr "8085 8086 8087"

# Check container logs
docker compose logs contapa2-m1-dm
```

**Common Causes:**
1. **Containers not healthy**: Wait for health checks to pass
2. **Firewall blocking ports**: Configure Windows Firewall to allow ports
3. **Wrong URL**: Ensure using correct localhost or domain

---

### Issue: SSL certificate errors

**Symptoms**: Browser shows "Your connection is not private" or similar

**Expected Behavior:**
- **Staging certificates**: Will show warnings (expected during testing)
- **Production certificates**: Should be trusted after DNS propagation

**Solutions:**
1. **For testing**: Accept the certificate warning (staging certs are not trusted)
2. **For production**: 
   - Ensure DNS points to your server
   - Change `ACME_SERVER` to production URL
   - Restart stack: `docker compose down && docker compose up -d`

---

### Issue: Database connection errors in application

**Symptoms**: Web page shows "Connection failed"

**Diagnosis:**
```powershell
# Check MySQL health
docker compose ps mysql

# Test database connectivity
docker compose exec mysql mysqladmin ping -u milestone_user -p

# Check if database and user exist
docker compose exec mysql mysql -u root -p -e "SHOW DATABASES; SELECT User FROM mysql.user;"
```

**Common Causes:**
1. **MySQL not ready**: Health check hasn't passed yet
2. **Wrong credentials**: Verify environment variables match
3. **Network isolation**: Containers not on same network

---

### Issue: phpMyAdmin cannot connect to database

**Symptoms**: "Cannot connect: invalid settings" error

**Solution:**
```powershell
# Restart phpMyAdmin
docker compose restart phpmyadmin

# Check logs
docker compose logs phpmyadmin
```

**Common Causes:**
- MySQL service name mismatch (should be `mysql`)
- MySQL not fully initialized

---

### Issue: Load balancing not working

**Symptoms**: Same container serves all requests

**Diagnosis:**
```powershell
# Check how many replicas are running
docker compose ps contapa2-m1-dm

# Check Traefik dashboard
# Open http://localhost:8080
```

**Solutions:**
1. **Verify replicas are running**: Should see 3 containers
2. **Check Traefik configuration**: All containers should be registered as backends
3. **Clear browser cache**: Might be caching responses

---

### Issue: Out of disk space

**Symptoms**: Containers fail to start with "no space left on device"

**Diagnosis:**
```powershell
# Check Docker disk usage
docker system df

# Check volume sizes
docker volume ls
```

**Solutions:**
```powershell
# Remove unused containers, images, volumes
docker system prune -a --volumes

# WARNING: This removes all unused Docker data!
```

---

### Issue: Performance is slow

**Diagnosis:**
```powershell
# Check resource usage
docker stats

# Check for bottlenecks
docker compose logs --tail=100
```

**Solutions:**
1. **Increase Docker resources**: Configure in Docker Desktop settings
2. **Optimize MySQL**: Adjust MySQL configuration
3. **Scale down**: Reduce number of replicas if system is overloaded

---

## Cleanup

### Stop all services (keep data)

```powershell
docker compose stop
```

**Explanation**: Stops containers but preserves data in volumes.

---

### Stop and remove containers

```powershell
docker compose down
```

**Explanation**: Stops and removes containers, networks, but keeps volumes.

---

### Remove everything including volumes

```powershell
docker compose down -v
```

**Flags explained:**
- `-v` or `--volumes`: Remove named volumes declared in the volumes section

**WARNING**: This deletes all database data!

---

### Remove everything including images

```powershell
docker compose down -v --rmi all
```

**Flags explained:**
- `--rmi all`: Remove all images used by services
- `--rmi local`: Remove only images without custom tags

---

### Remove orphaned resources

```powershell
docker compose down --remove-orphans
```

**Explanation**: Removes containers for services not defined in current compose file.

---

### Clean up Docker system

```powershell
# Remove all stopped containers
docker container prune

# Remove all unused images
docker image prune -a

# Remove all unused volumes
docker volume prune

# Remove all unused networks
docker network prune

# Remove everything unused
docker system prune -a --volumes
```

**WARNING**: System prune commands affect ALL Docker resources, not just this project!

---

## Advanced Topics

### Viewing and Managing Volumes

**List volumes:**
```powershell
docker volume ls
```

**Inspect volume details:**
```powershell
docker volume inspect milestone1_db_data
docker volume inspect milestone1_traefik-certs
```

**Backup database volume:**
```powershell
docker run --rm -v milestone1_db_data:/data -v ${PWD}:/backup ubuntu tar czf /backup/db_backup.tar.gz /data
```

**Restore database volume:**
```powershell
docker run --rm -v milestone1_db_data:/data -v ${PWD}:/backup ubuntu tar xzf /backup/db_backup.tar.gz -C /
```

---

### Viewing Network Configuration

**List networks:**
```powershell
docker network ls
```

**Inspect network:**
```powershell
docker network inspect milestone1_default
```

**What to look for:**
- All containers attached to the network
- IP addresses assigned to containers
- Network driver type (bridge)

---

### Executing Commands in Containers

**Interactive shell in MySQL:**
```powershell
docker compose exec mysql bash
```

**Interactive shell in web server:**
```powershell
docker compose exec contapa2-m1-dm bash
```

**Single command execution:**
```powershell
docker compose exec mysql mysql -u root -p -e "SHOW DATABASES;"
```

---

### Monitoring Logs in Real-Time

**All services:**
```powershell
docker compose logs -f
```

**Specific service:**
```powershell
docker compose logs -f traefik
```

**Multiple services:**
```powershell
docker compose logs -f traefik mysql
```

**With timestamps:**
```powershell
docker compose logs -f --timestamps
```

**Tail last N lines:**
```powershell
docker compose logs -f --tail=50 contapa2-m1-dm
```

---

### Updating the Stack

**Update images to latest versions:**
```powershell
docker compose pull
docker compose up -d
```

**Rebuild custom images:**
```powershell
docker compose build --no-cache
docker compose up -d
```

**Force recreate containers:**
```powershell
docker compose up -d --force-recreate
```

---

## Security Considerations

### Production Checklist

- [ ] Change all default passwords in `.env`
- [ ] Use production ACME server for real SSL certificates
- [ ] Disable Traefik dashboard (`--api.dashboard=false`)
- [ ] Enable dashboard authentication if keeping it enabled
- [ ] Use Docker secrets instead of environment variables for passwords
- [ ] Implement firewall rules (allow only 80, 443)
- [ ] Enable Docker Content Trust (image signing)
- [ ] Regular backups of database volume
- [ ] Monitor logs for suspicious activity
- [ ] Keep images updated with security patches
- [ ] Use read-only root filesystem where possible
- [ ] Implement rate limiting in Traefik
- [ ] Add HTTP security headers

---

## Additional Resources

### Docker Documentation
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)

### Traefik Documentation
- [Traefik Official Docs](https://doc.traefik.io/traefik/)
- [Let's Encrypt Integration](https://doc.traefik.io/traefik/https/acme/)
- [Docker Provider](https://doc.traefik.io/traefik/providers/docker/)

### MySQL Documentation
- [MySQL Docker Image](https://hub.docker.com/_/mysql)
- [MySQL Configuration](https://dev.mysql.com/doc/)

### PHP Documentation
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)
- [PHP MySQL Extension](https://www.php.net/manual/en/book.mysqli.php)

---

## Conclusion

This Docker Compose stack demonstrates a production-ready architecture with:
- ✅ Load balancing across multiple web servers
- ✅ Automatic SSL certificate management
- ✅ Health monitoring and automatic recovery
- ✅ Persistent data storage
- ✅ Service isolation and dependency management
- ✅ Scalability (easily adjust replica count)

For questions or issues, refer to the troubleshooting section or consult the official documentation linked above.

---

**Document Version**: 1.0  
**Last Updated**: October 26, 2025  
**Author**: David Maat  
**Project**: Linux Web Services - Milestone 1
