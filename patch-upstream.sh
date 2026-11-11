#!/bin/sh
# Build-time patches to upstream server.js. Each one is asserted: if upstream moves the line, the build fails.
set -eu
F=/app/server.js

# Lockout key: first X-Forwarded-For hop. Railway replaces the inbound header, so the first entry is the real client;
# upstream's req.ip is the rotating edge hop behind `trust proxy 1`.
sed -i "s#const ip = req.ip;#const ip = ((req.headers['x-forwarded-for'] || '').split(',')[0] || '').trim() || req.ip;#" "$F"
[ "$(grep -c "x-forwarded-for'\] || '').split" "$F")" = 1 ] || { echo "patch: lockout key line not found" >&2; exit 1; }

# Upstream prints the PIN in clear on every start.
sed -i "/console.log('PIN:', PIN);/d" "$F"
[ "$(grep -c "console.log('PIN:'" "$F")" = 0 ] || { echo "patch: PIN log line still present" >&2; exit 1; }
