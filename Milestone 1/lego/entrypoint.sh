#!/bin/sh
set -e

echo "Starting LEGO ACME client setup..."

# Install lego client
echo "Installing LEGO ACME client..."
apk add --no-cache curl wget tar

# Detect architecture
ARCH=$(uname -m)
case ${ARCH} in
    x86_64)
        LEGO_ARCH="amd64"
        ;;
    aarch64)
        LEGO_ARCH="arm64"
        ;;
    armv7l)
        LEGO_ARCH="armv7"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# Download and install LEGO
LEGO_VERSION="v4.18.0"
echo "Downloading LEGO ${LEGO_VERSION} for linux_${LEGO_ARCH}..."
wget "https://github.com/go-acme/lego/releases/download/${LEGO_VERSION}/lego_${LEGO_VERSION}_linux_${LEGO_ARCH}.tar.gz" -O /tmp/lego.tar.gz

if [ $? -ne 0 ]; then
    echo "Failed to download LEGO"
    exit 1
fi

echo "Extracting LEGO..."
tar -xzf /tmp/lego.tar.gz -C /usr/local/bin/ lego
chmod +x /usr/local/bin/lego
rm /tmp/lego.tar.gz

# Verify lego is working
if ! /usr/local/bin/lego --version; then
    echo "LEGO installation failed"
    exit 1
fi

# Create directories
mkdir -p /etc/lego/certificates
mkdir -p /var/www/html/.well-known/acme-challenge

# Set default values if not provided
DOMAIN=${DOMAIN:-localhost}
EMAIL=${EMAIL:-admin@localhost}
ACME_SERVER=${ACME_SERVER:-https://acme-staging-v02.api.letsencrypt.org/directory}

echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo "ACME Server: $ACME_SERVER"

# Create a self-signed certificate for HAProxy to start with (if no cert exists)
if [ ! -f "/etc/lego/certificates/${DOMAIN}.pem" ]; then
    echo "Creating temporary self-signed certificate for initial HAProxy startup..."
    apk add --no-cache openssl
    openssl req -x509 -newkey rsa:2048 -keyout "/etc/lego/certificates/${DOMAIN}.key" \
        -out "/etc/lego/certificates/${DOMAIN}.crt" \
        -days 1 -nodes -subj "/CN=${DOMAIN}"
    cat "/etc/lego/certificates/${DOMAIN}.crt" "/etc/lego/certificates/${DOMAIN}.key" > "/etc/lego/certificates/${DOMAIN}.pem"
    chmod 644 "/etc/lego/certificates/${DOMAIN}.pem"
    echo "Temporary certificate created"
fi

# Initial certificate request (only if certificate doesn't exist)
if [ ! -f "/etc/lego/certificates/${DOMAIN}.crt" ]; then
    echo "Requesting initial certificate for $DOMAIN..."
    # Wait a bit for HAProxy and webservers to be ready
    sleep 10
    lego --email="$EMAIL" \
         --domains="$DOMAIN" \
         --http.webroot="/var/www/html" \
         --path="/etc/lego" \
         --server="$ACME_SERVER" \
         --accept-tos \
         run
    
    # Convert certificate to HAProxy format (PEM bundle)
    if [ -f "/etc/lego/certificates/${DOMAIN}.crt" ] && [ -f "/etc/lego/certificates/${DOMAIN}.key" ]; then
        cat "/etc/lego/certificates/${DOMAIN}.crt" "/etc/lego/certificates/${DOMAIN}.key" > "/etc/lego/certificates/${DOMAIN}.pem"
        chmod 644 "/etc/lego/certificates/${DOMAIN}.pem"
        # Make other cert files readable so HAProxy doesn't complain
        chmod 644 "/etc/lego/certificates/${DOMAIN}.crt"
        chmod 644 "/etc/lego/certificates/${DOMAIN}.key"
        chmod 644 "/etc/lego/certificates/${DOMAIN}.issuer.crt" 2>/dev/null || true
        echo "Certificate bundle created successfully"
    fi
else
    echo "Certificate already exists, skipping initial request"
    # Still create/update the PEM bundle for HAProxy
    if [ -f "/etc/lego/certificates/${DOMAIN}.crt" ] && [ -f "/etc/lego/certificates/${DOMAIN}.key" ]; then
        cat "/etc/lego/certificates/${DOMAIN}.crt" "/etc/lego/certificates/${DOMAIN}.key" > "/etc/lego/certificates/${DOMAIN}.pem"
        chmod 644 "/etc/lego/certificates/${DOMAIN}.pem"
        # Make other cert files readable so HAProxy doesn't complain
        chmod 644 "/etc/lego/certificates/${DOMAIN}.crt"
        chmod 644 "/etc/lego/certificates/${DOMAIN}.key"
        chmod 644 "/etc/lego/certificates/${DOMAIN}.issuer.crt" 2>/dev/null || true
        echo "Certificate bundle updated"
    fi
fi

# Copy the renewal script to the cron directory and make it executable
cp /renew.sh /etc/periodic/daily/renew-certs
chmod +x /etc/periodic/daily/renew-certs

echo "LEGO ACME client setup complete. Starting crond for automatic renewals..."

# Execute the command passed to the container (crond)
exec "$@"
