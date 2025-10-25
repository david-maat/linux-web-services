#!/bin/sh
set -e

echo "Starting HAProxy setup..."

# Wait for certificate to be available
echo "Waiting for certificate for domain: ${DOMAIN}"
CERT_PATH="/etc/haproxy/certs/${DOMAIN}.pem"

# Wait up to 120 seconds for the certificate to appear
TIMEOUT=120
ELAPSED=0
while [ ! -f "$CERT_PATH" ] && [ $ELAPSED -lt $TIMEOUT ]; do
    echo "Waiting for certificate at $CERT_PATH... (${ELAPSED}s)"
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

if [ ! -f "$CERT_PATH" ]; then
    echo "WARNING: Certificate not found at $CERT_PATH after ${TIMEOUT}s"
    echo "HAProxy will start but HTTPS may not work until certificate is available"
else
    echo "Certificate found at $CERT_PATH"
    ls -lh "$CERT_PATH"
fi

# Start HAProxy with the default configuration
echo "Starting HAProxy..."
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
