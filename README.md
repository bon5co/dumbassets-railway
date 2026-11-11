# dumbassets-railway

Thin wrapper over `dumbwareio/dumbassets` (DumbAssets, a self-hosted asset tracker: assets, components, warranties,
maintenance events, photos, receipts and manuals, with a REST API) for the Railway template "DumbAssets". Refuses to
start without a 4 to 32 digit `DUMBASSETS_PIN` (upstream serves the whole register to anyone when the PIN is unset),
keys the PIN lockout on the first `X-Forwarded-For` address (upstream keys it on the rotating Railway edge hop), removes
upstream's start-up log line that prints the PIN, and derives `BASE_URL` from the Railway domain.
