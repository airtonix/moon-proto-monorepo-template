# api_service

Cloudflare Workers service scaffold for API-style endpoints.

## Runtime

- Target runtime: **Cloudflare Workers**
- Entrypoint: `src/index.ts`
- Config: `wrangler.toml`
- Health endpoint: `GET /health`

## Moon publish contract

- `build`: creates a dry-run Worker bundle in `apps/api_service/.artifacts/worker`
- `package`: archives that bundle to `apps/api_service/.artifacts/api-service-<tag>-<env>.tgz`
- `publish`: deploys with Wrangler when deploy is enabled and credentials are present; otherwise performs dry-run packaging

### Examples

```bash
# Build/package only (dry-run)
DEPLOY=false moon run api-service:publish -- latest preview

# Explicit no-deploy mode (always dry-run even if DEPLOY=true)
NO_DEPLOY=true moon run api-service:publish -- latest staging

# Real deploy (requires Cloudflare credentials)
CLOUDFLARE_ACCOUNT_ID=... \
CLOUDFLARE_API_TOKEN=... \
moon run api-service:publish -- latest production
```

## Environment strategy

Wrangler environments are defined for:

- `preview`
- `staging`
- `production`

Override routes at deploy time with `CF_WORKER_ROUTES` (comma-separated routes) or define static `routes` in `wrangler.toml` under `env.production`.

## Auth strategy

`publish` accepts either:

- `CLOUDFLARE_API_TOKEN` directly, or
- `CLOUDFLARE_OIDC_TOKEN` (pre-exchanged token) which is mapped to `CLOUDFLARE_API_TOKEN`.

`CLOUDFLARE_ACCOUNT_ID` is required for actual deploys.

> This service is **not** deployed to GitHub Pages.
