#!/bin/sh
# Certificate renewal script - runs daily via crond

echo "========================================"
echo "Certificate Renewal Check: $(date)"
echo "========================================"

DOMAIN=${DOMAIN:-localhost}
EMAIL=${EMAIL:-admin@localhost}
ACME_SERVER=${ACME_SERVER:-https://acme-staging-v02.api.letsencrypt.org/directory}

# Renew certificate (lego will only renew if needed - within 30 days of expiry)
echo "Checking if renewal is needed for $DOMAIN..."

lego --email="$EMAIL" \
     --domains="$DOMAIN" \
     --http \
     --http.webroot="/var/www/html" \
     --path="/etc/lego" \
     --server="$ACME_SERVER" \
     --accept-tos \
     renew --days 30

# If renewal succeeded, recreate the HAProxy PEM bundle
if [ -f "/etc/lego/certificates/${DOMAIN}.crt" ] && [ -f "/etc/lego/certificates/${DOMAIN}.key" ]; then
    echo "Updating certificate bundle..."
    cat "/etc/lego/certificates/${DOMAIN}.crt" "/etc/lego/certificates/${DOMAIN}.key" > "/etc/lego/certificates/${DOMAIN}.pem"
    chmod 644 "/etc/lego/certificates/${DOMAIN}.pem"
    
    # Reload HAProxy to pick up new certificates
    echo "Reloading HAProxy..."
    docker exec haproxy-m1-dm kill -SIGUSR2 1 2>/dev/null || echo "Could not reload HAProxy (container may not be running)"
    
    echo "Certificate renewal completed successfully"
else
    echo "No certificate update needed"
fi

echo "========================================"
