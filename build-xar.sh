#!/usr/bin/env bash
set -euo pipefail

SOURCE="${1:-.}"
OUTPUT="${2:-../applicationTracking.xar}"

SOURCE="$(cd "$SOURCE" && pwd)"
OUTPUT="$(cd "$(dirname "$OUTPUT")" && pwd)/$(basename "$OUTPUT")"

test -f "$SOURCE/expath-pkg.xml" || {
  echo "ERROR: source directory must contain expath-pkg.xml at its root." >&2
  exit 1
}

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING" "$OUTPUT.zip"' EXIT

cp -R "$SOURCE"/. "$STAGING"/
rm -rf "$STAGING/.git"

(cd "$STAGING" && zip -qr "$OUTPUT.zip" .)
mv "$OUTPUT.zip" "$OUTPUT"

echo "Created valid eXist-db XAR: $OUTPUT"
