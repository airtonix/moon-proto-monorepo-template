#!/usr/bin/env -S usage bash
#USAGE arg "<tag>" help="Publish tag/channel" default="latest"

set -euo pipefail

: "${MOON_WORKSPACE_ROOT:?MOON_WORKSPACE_ROOT is required}"
: "${MOON_PROJECT_SOURCE:?MOON_PROJECT_SOURCE is required}"
PROJECT_ROOT="$MOON_WORKSPACE_ROOT/$MOON_PROJECT_SOURCE"
cd "$PROJECT_ROOT"

TAG="${PUBLISH_TAG:-${usage_tag:-latest}}"

ARTIFACT_DIR=".artifacts"
PAGES_DIR="$ARTIFACT_DIR/github-pages"
PACKAGE_PATH="$ARTIFACT_DIR/docs-site-${TAG}.tgz"

rm -rf "$PAGES_DIR"
mkdir -p "$PAGES_DIR"
cp -R dist/. "$PAGES_DIR/"

tar -czf "$PACKAGE_PATH" -C "$PAGES_DIR" .
echo "$PACKAGE_PATH" > "$ARTIFACT_DIR/latest-package.txt"

echo "docs-site package created: $PACKAGE_PATH"
