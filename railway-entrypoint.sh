#!/bin/sh
# DumbAssets for Railway: refuse to serve the asset register without a PIN, derive BASE_URL from the Railway domain,
# make sure the data directories exist on the volume, then run upstream.
set -eu

# Upstream treats an unset or empty PIN as "no authentication" and serves every asset, receipt and manual to anyone.
case "${DUMBASSETS_PIN:-}" in
  ''|*[!0-9]*) echo "railway-entrypoint: DUMBASSETS_PIN must be 4 to 32 digits; refusing to start an open asset register" >&2; exit 1 ;;
esac
if [ "${#DUMBASSETS_PIN}" -lt 4 ] || [ "${#DUMBASSETS_PIN}" -gt 32 ]; then
  echo "railway-entrypoint: DUMBASSETS_PIN must be 4 to 32 digits; refusing to start an open asset register" >&2
  exit 1
fi

# BASE_URL feeds CORS and decides whether the auth cookie carries the Secure flag.
if [ -z "${BASE_URL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export BASE_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

# The listener must follow Railway's injected PORT: the healthcheck dials it, not the domain target.
export PORT="${PORT:-3000}"

mkdir -p /app/data/Images /app/data/Receipts /app/data/Manuals
echo "railway-entrypoint: uid=$(id -u) /app/data owner=$(stat -c %u:%g /app/data) writable=$(touch /app/data/.w && rm /app/data/.w && echo yes || echo NO) base_url=${BASE_URL:-unset} port=$PORT"

exec "$@"
