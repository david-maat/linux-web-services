#!/bin/sh
set -e

MODE="${LEGO_MODE:-run}"

echo "Running lego in '$MODE' mode..."

exec lego \
  --email="${EMAIL}" \
  --domains="${DOMAIN}" \
  --http \
  --http.port=:80 \
  --path=/etc/lego \
  --server="${ACME_SERVER:-https://acme-staging-v02.api.letsencrypt.org/directory}" \
  --accept-tos \
  ${MODE} \
  ${LEGO_ARGS}
