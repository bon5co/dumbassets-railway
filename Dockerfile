# DumbAssets for Railway.
#
# A stock deploy of upstream DumbAssets has four defects on Railway: with DUMBASSETS_PIN unset or empty it serves every
# asset, receipt and manual to anyone who finds the URL (authentication is silently off), it counts failed PIN attempts
# per req.ip, which behind Railway's edge is the rotating edge hop instead of the visitor (the lockout can be walked
# around by simply retrying), it prints the PIN to the deploy log on every start, and BASE_URL defaults to localhost so
# CORS and the cookie Secure flag are wrong. This wrapper refuses to start without a valid PIN, keys the lockout on the
# first X-Forwarded-For address, removes the PIN log line and derives BASE_URL from the Railway domain. The application
# is otherwise untouched.
FROM dumbwareio/dumbassets:1.0.11@sha256:1bbe3a1c4aa404f3cbd9641cbf7ef24dfd3f4f09a92570eecc88d48de31517ab

COPY railway-entrypoint.sh patch-upstream.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/railway-entrypoint.sh /usr/local/bin/patch-upstream.sh \
 && /usr/local/bin/patch-upstream.sh

ENV NODE_ENV=production \
    SITE_TITLE=DumbAssets

WORKDIR /app
VOLUME /app/data
EXPOSE 3000
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["npm", "start"]
