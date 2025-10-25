#!/bin/sh
set -e

# Generate HAProxy config with environment variables substituted
envsubst '${DOMAIN}' < /usr/local/etc/haproxy/haproxy.cfg.template > /usr/local/etc/haproxy/haproxy.cfg

# Start HAProxy
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
