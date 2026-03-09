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

ARTIFACT_DIR=".artifacts"
WORKER_DIR="$ARTIFACT_DIR/worker"
PACKAGE_PATH="$ARTIFACT_DIR/api-service-${TAG}-${DEPLOY_ENV}.tgz"

if [ ! -d "$WORKER_DIR" ]; then
  echo "expected worker bundle at $WORKER_DIR" >&2
  exit 1
fi

mkdir -p "$ARTIFACT_DIR"
tar -czf "$PACKAGE_PATH" -C "$WORKER_DIR" .
echo "$PACKAGE_PATH" > "$ARTIFACT_DIR/latest-package.txt"

echo "api-service package created: $PACKAGE_PATH"
