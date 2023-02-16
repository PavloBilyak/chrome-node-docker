#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-chrome-node}"

docker build --no-cache -t "$IMAGE_NAME:latest" .

# MAJOR.MINOR.BUILD.PATCH
CHROME_VERSION="$(docker run --rm "$IMAGE_NAME:latest" | grep -oP "^Google Chrome \K([\d.]+)")"
docker tag "$IMAGE_NAME:latest" "$IMAGE_NAME:$CHROME_VERSION"

# MAJOR.MINOR.BUILD
CHROME_VERSION_BUILD="$(echo "$CHROME_VERSION" | grep -oP "^\K(\d+)(\.\d+){2}")"
docker tag "$IMAGE_NAME:latest" "$IMAGE_NAME:$CHROME_VERSION_BUILD"

# MAJOR.MINOR
CHROME_VERSION_MINOR="$(echo "$CHROME_VERSION" | grep -oP "^\K(\d+)(\.\d+)")"
docker tag "$IMAGE_NAME:latest" "$IMAGE_NAME:$CHROME_VERSION_MINOR"

# MAJOR
CHROME_VERSION_MAJOR="$(echo "$CHROME_VERSION" | grep -oP "^\K(\d+)")"
docker tag "$IMAGE_NAME:latest" "$IMAGE_NAME:$CHROME_VERSION_MAJOR"
