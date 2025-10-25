# LEGO ACME Client Setup with Auto-Renewal

This setup includes automatic SSL/TLS certificate management using the LEGO ACME client with Let's Encrypt.

## Features

- **LEGO ACME Client**: Automatic certificate issuance and renewal
- **Docker-in-Docker (dind)**: Runs LEGO in a containerized environment
- **Automatic Renewals**: Daily cron job checks and renews certificates (30 days before expiry)
- **HAProxy SSL Termination**: HTTPS support with automatic certificate loading
- **HTTP-01 Challenge**: Uses HTTP-01 challenge method for domain validation

## Configuration

### 1. Update Environment Variables

Edit `docker-compose.yml` and update the LEGO service environment variables:

```yaml
environment:
  - DOMAIN=your-domain.com          # Your actual domain name
  - EMAIL=your-email@example.com    # Your email for Let's Encrypt notifications
  - ACME_SERVER=https://acme-staging-v02.api.letsencrypt.org/directory  # Use staging for testing
```

**Important**: 
- For **testing**, use the staging server: `https://acme-staging-v02.api.letsencrypt.org/directory`
- For **production**, use: `https://acme-v02.api.letsencrypt.org/directory`

### 2. Update HAProxy Configuration

Edit `haproxy/haproxy.cfg` and replace `your-domain.com` with your actual domain:

```
bind *:443 ssl crt /etc/haproxy/certs/your-domain.com.pem alpn h2,http/1.1
```

### 3. DNS Configuration

**CRITICAL**: Ensure your domain's DNS A record points to your server's public IP address before starting. ACME validation will fail otherwise.

### 4. Port Forwarding

If running behind a firewall/router, forward these ports to your server:
- Port 80 (HTTP) - Required for ACME HTTP-01 challenge
- Port 443 (HTTPS) - For secure connections

## Deployment

### Start the Services

```bash
docker-compose up -d
```

### Monitor Certificate Issuance

Check the LEGO container logs to monitor certificate requests:

```bash
docker logs -f lego-acme-m1-dm
```

### Verify Certificate

Once issued, check the certificate:

```bash
# List certificates
docker exec lego-acme-m1-dm ls -la /etc/lego/certificates/

# View certificate details
docker exec lego-acme-m1-dm openssl x509 -in /etc/lego/certificates/your-domain.com.crt -text -noout
```

### Test HTTPS

Open your browser and navigate to:
```
https://your-domain.com:8443
```

## Automatic Renewal

The renewal script (`lego/renew.sh`) runs daily via cron and:
1. Checks if the certificate needs renewal (within 30 days of expiry)
2. Requests a new certificate if needed
3. Creates the HAProxy PEM bundle
4. Reloads HAProxy to use the new certificate

### Manual Renewal

To manually trigger a renewal check:

```bash
docker exec lego-acme-m1-dm /etc/periodic/daily/renew-certs
```

## Troubleshooting

### Certificate Request Fails

1. **Check DNS**: Verify your domain points to the correct IP
   ```bash
   nslookup your-domain.com
   ```

2. **Check Port 80 Access**: Ensure port 80 is accessible from the internet
   ```bash
   curl -I http://your-domain.com/.well-known/acme-challenge/test
   ```

3. **Check Logs**: Review LEGO container logs
   ```bash
   docker logs lego-acme-m1-dm
   ```

### Rate Limits

Let's Encrypt has rate limits:
- **Staging**: Much higher limits, use for testing
- **Production**: 50 certificates per domain per week

Always test with the staging server first!

### HAProxy Not Using Certificate

1. Check if PEM bundle exists:
   ```bash
   docker exec lego-acme-m1-dm ls -la /etc/lego/certificates/your-domain.com.pem
   ```

2. Restart HAProxy:
   ```bash
   docker-compose restart haproxy
   ```

## File Structure

```
.
├── docker-compose.yml
├── haproxy/
│   └── haproxy.cfg                 # HAProxy config with SSL/HTTPS
├── lego/
│   ├── entrypoint.sh              # LEGO initialization script
│   └── renew.sh                   # Daily renewal cron job
└── webserver/
    └── ...
```

## Security Notes

1. **Staging vs Production**: Always test with staging server first to avoid rate limits
2. **Certificate Storage**: Certificates are stored in Docker volumes (`certs`)
3. **Backup**: Consider backing up the `certs` volume to preserve certificates
4. **Email**: Use a valid email for Let's Encrypt expiration notices

## Production Checklist

- [ ] Update `DOMAIN` to your actual domain
- [ ] Update `EMAIL` to your valid email
- [ ] Verify DNS A record points to your server
- [ ] Test with staging server first
- [ ] Port 80 and 443 are accessible from internet
- [ ] Update HAProxy config with correct domain name
- [ ] Change `ACME_SERVER` to production URL after testing
- [ ] Monitor initial certificate issuance
- [ ] Verify HTTPS works
- [ ] Confirm automatic renewal is scheduled

## Additional Resources

- [LEGO Documentation](https://go-acme.github.io/lego/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [HAProxy SSL Termination](https://www.haproxy.com/documentation/haproxy-configuration-tutorials/ssl-tls/)
