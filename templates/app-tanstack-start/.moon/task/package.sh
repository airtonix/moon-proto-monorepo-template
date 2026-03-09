#!/usr/bin/env -S usage bash
#USAGE arg "<tag>" help="Publish tag/channel" default="latest"

set -euo pipefail

: "${MOON_WORKSPACE_ROOT:?MOON_WORKSPACE_ROOT is required}"
: "${MOON_PROJECT_SOURCE:?MOON_PROJECT_SOURCE is required}"
PROJECT_ROOT="$MOON_WORKSPACE_ROOT/$MOON_PROJECT_SOURCE"
cd "$PROJECT_ROOT"

TAG="${PUBLISH_TAG:-${usage_tag:-latest}}"

ARTIFACT_DIR=".artifacts"
PAGES_DIR="$ARTIFACT_DIR/pages"
PACKAGE_PATH="$ARTIFACT_DIR/{{ name }}-${TAG}.tgz"

rm -rf "$PAGES_DIR"
mkdir -p "$PAGES_DIR"
cp -R dist/client "$PAGES_DIR/client"
cp -R dist/server "$PAGES_DIR/server"

tar -czf "$PACKAGE_PATH" -C "$PAGES_DIR" .
echo "$PACKAGE_PATH" > "$ARTIFACT_DIR/latest-package.txt"

echo "{{ name }} package created: $PACKAGE_PATH"
