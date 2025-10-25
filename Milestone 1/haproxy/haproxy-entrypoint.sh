#!/bin/sh
set -e

# Generate HAProxy config with environment variables substituted
envsubst '${DOMAIN}' < /usr/local/etc/haproxy/haproxy.cfg.template > /tmp/haproxy.cfg

# Start HAProxy
exec haproxy -f /tmp/haproxy.cfg
