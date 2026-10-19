# Chhoto URL on VibeNest — guided pilot

Based on upstream `SinTan1729/chhoto-url` at
`ad378c0482d3793127ed29684616002ccc12d944` (7.8.4). License and upstream attribution
are preserved. Build and runtime acceptance on VibeNest are pending.

The README button opens `/start` with this fork prefilled. It does not provision
the configuration below. Do not start a public instance until credentials and
persistent storage are configured. There is no first-admin registration step:
the configured password protects the management UI and API from the first request.

| Setting | Value |
| --- | --- |
| Repository | `https://github.com/NikitaBabenko/chhoto-url` |
| Branch | `main` (record and verify the exact commit before launch) |
| Build pack | Dockerfile |
| Base directory / build context | `/` / repository root |
| Dockerfile | `/Dockerfile` |
| Internal HTTP port | `4567` |
| Persistent volume | entire `/data` directory |
| Public URL | `https://YOUR-PROJECT.vibenest.net` |

Create a draft without a repository or hardware first. Save environment variables
using the Environment tab; do not use **Apply to Deployment** during preparation.
Save repository/build settings with **Save Configuration**, not **Deploy Now**.
Attaching hardware can launch the app automatically. Saving a volume invokes a
redeploy dispatcher. Therefore the pilot operator must defer both actions until
the coordinator assigns the single Free slot and the current security/resource
preflight permits the action. Do not infer permission from an idle status.

Before attaching hardware, save `/data` as the persistent volume through the
normal platform control. Verify the saved path and ensure no build started without
the assigned hardware. Then use the normal hardware/deploy flow and its security
gate. If that order is refused, stop and report the exact refusal; do not use a
direct provider launch or a replacement project to work around it.

Set these environment variables before any start:

```dotenv
CHHOTO_DB_URL=/data/urls.sqlite
CHHOTO_SQLITE_USE_WAL_MODE=True
CHHOTO_SQLITE_ENSURE_ACID=True
CHHOTO_DISABLE_BACKUPS=False
CHHOTO_LISTEN_ADDRESS=0.0.0.0
CHHOTO_LISTEN_PORT=4567
CHHOTO_PUBLIC_MODE=Disable
CHHOTO_REQUIRE_PASSWORD=True
CHHOTO_SECURE_COOKIES=True
CHHOTO_WORKERS=1
CHHOTO_SITE_URL=https://YOUR-PROJECT.vibenest.net
CHHOTO_REDIRECT_METHOD=TEMPORARY
CHHOTO_PASSWORD=REPLACE_WITH_A_UNIQUE_RANDOM_SECRET
CHHOTO_API_KEY=REPLACE_WITH_A_DIFFERENT_RANDOM_SECRET
```

Generate a unique random password (at least 32 random bytes) and a different API
key (128 alphanumeric characters), save them securely once, and reuse them across
restarts and replacement deployments. Never commit them or paste them into logs.
The upstream plaintext environment credential mode is supported; Argon2 hashes
are recommended for long-term use (see the upstream installation guide). If
enabling Argon2, hash both credentials and configure `CHHOTO_HASH_ALGORITHM=Argon2`.
Never enable public creation for this pilot. The hosted guard refuses startup if
the password is missing or public mode is enabled. This is opt-in outside the
root Dockerfile; legacy upstream deployment defaults are unchanged.

The fork enables Secure cookies behind HTTPS and limits the main HTTP worker pool
to one through `CHHOTO_WORKERS`. Session encryption keys deliberately retain the
upstream behavior: generated on startup, so restart invalidates sessions. Log in
again after restart; the password, API key and persisted links remain unchanged.
The separate health server listens only on container loopback port `1729`; use
the public UI/API on port `4567` for routed acceptance checks.

The database, WAL/SHM companions and rotating SQLite backups all belong under
`/data`. Mount the directory, not just the database file. Preserve the volume
during restart/replacement and keep independent backups for real usage. Upstream
documentation screenshots use Git LFS; runtime frontend assets do not. Frontend
QR generation uses a versioned jsDelivr script and needs browser network access.

## Acceptance still required

- Build the exact fork SHA from source on the authorized executor; no binary download.
- Check HTTPS, Secure/HttpOnly/SameSite cookie attributes, incorrect credentials,
  and unauthenticated create/edit/delete/list denial.
- Create, list and edit a synthetic link, follow its public redirect, render its QR
  code, observe hit count updates, then delete only the synthetic disposable link.
- Measure actual RAM/CPU limits, startup/idle/load memory, disk usage and any hard
  quota separately. Nominal Free resources are not measurements.
- Observe a small realistic workload without OOM or automatic restarts; verify a
  retained link and hit count after normal restart and replacement redeploy.
- Record source/image identity and security evidence for each lifecycle action.

No Free-tier capacity or runtime compatibility claim is made yet. The Rust release
build uses one job but retains upstream fat LTO; build memory requirements still
need an executor preflight. Do not run a heavy build on a shared laptop or a busy
production host merely to test availability.
