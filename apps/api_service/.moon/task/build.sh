#!/usr/bin/env -S usage bash
#USAGE arg "<tag>" help="Publish tag/channel" default="latest"
#USAGE arg "<environment>" help="Wrangler environment" default="preview"

set -euo pipefail

: "${MOON_WORKSPACE_ROOT:?MOON_WORKSPACE_ROOT is required}"
: "${MOON_PROJECT_SOURCE:?MOON_PROJECT_SOURCE is required}"
PROJECT_ROOT="$MOON_WORKSPACE_ROOT/$MOON_PROJECT_SOURCE"
cd "$PROJECT_ROOT"

TAG="${PUBLISH_TAG:-${usage_tag:-latest}}"
DEPLOY_ENV="${DEPLOY_ENV:-${usage_environment:-preview}}"
OUTDIR=".artifacts/worker"

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

bunx wrangler deploy \
  --dry-run \
  --outdir "$OUTDIR" \
  --env "$DEPLOY_ENV" \
  --var BUILD_TAG:"$TAG" \
  --var DEPLOY_ENV:"$DEPLOY_ENV"

echo "api-service worker bundle staged at apps/api_service/$OUTDIR"
