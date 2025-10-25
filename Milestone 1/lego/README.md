# LEGO ACME Certificate Management

## Overview
This setup uses the official `goacme/lego` Docker image for SSL/TLS certificate management with automatic renewal via cron.

## Architecture

### Two-Container Approach

1. **lego** - One-time certificate acquisition
   - Uses official `goacme/lego:latest` image
   - Runs once to obtain initial certificates
   - Creates self-signed cert if needed (for HAProxy bootstrap)
   - Exits after obtaining certificate (`restart: "no"`)

2. **lego-renew** - Automated certificate renewal
   - Uses `docker:27-cli` image with cron
   - Runs continuously with cron job (daily at 2 AM)
   - Uses Docker-in-Docker approach via `/var/run/docker.sock`
   - Spawns temporary lego containers for renewals
   - Automatically reloads HAProxy after renewal

## How It Works

### Initial Certificate Acquisition
1. The `lego` service starts and checks if certificates exist
2. If no certificate exists, creates a temporary self-signed certificate
3. Requests a real certificate from Let's Encrypt (or configured ACME server)
4. Creates HAProxy-compatible PEM bundle (cert + key)
5. Exits successfully

### Automatic Renewals
1. The `lego-renew` service starts after `lego` completes
2. Sets up a cron job to run daily at 2 AM
3. Each day, spawns a temporary lego container to check for renewal
4. Lego only renews if certificate expires within 30 days
5. Updates PEM bundle if renewal occurs
6. Sends SIGUSR2 to HAProxy to reload certificates
7. Logs all operations to `/var/log/lego-renew.log`

## Benefits Over Previous Approach

✅ **No custom scripts** - Uses official lego image directly
✅ **Cleaner separation** - Initial setup vs renewal are separate services
✅ **Docker-native** - Uses Docker CLI for orchestration
✅ **Better logging** - Renewal logs are centralized
✅ **No manual installation** - No need to download/install lego binary
✅ **Version control** - Easy to update lego version via image tag
✅ **Simpler maintenance** - Standard Docker patterns

## Environment Variables

- `DOMAIN` - Domain name for certificate
- `EMAIL` - Email for Let's Encrypt notifications
- `ACME_SERVER` - ACME server URL (defaults to Let's Encrypt staging)

## Manual Certificate Renewal

To manually trigger a renewal check:

```bash
docker exec lego-renew-m1-dm /renew-certs.sh
```

## Viewing Renewal Logs

```bash
docker exec lego-renew-m1-dm cat /var/log/lego-renew.log
```

## Volume Mounts

- `certs` - Stores certificates and keys
- `acme_challenge` - HTTP-01 challenge responses (shared with webservers)
- `/var/run/docker.sock` - Docker socket for spawning renewal containers

## Migration Notes

The old `entrypoint.sh` and `renew.sh` scripts are no longer needed and can be safely deleted.
