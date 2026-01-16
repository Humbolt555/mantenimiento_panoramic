#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.22.2}"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_CACHE_ROOT="${NETLIFY_CACHE_DIR:-$HOME}"
FLUTTER_ROOT="${FLUTTER_CACHE_ROOT}/flutter"

if [ ! -d "${FLUTTER_ROOT}/flutter" ]; then
  echo "Downloading Flutter ${FLUTTER_VERSION} (${FLUTTER_CHANNEL})..."
  mkdir -p "${FLUTTER_ROOT}"
  curl -L "https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz" -o /tmp/flutter.tar.xz
  tar -xf /tmp/flutter.tar.xz -C "${FLUTTER_ROOT}"
fi

export PATH="${FLUTTER_ROOT}/flutter/bin:${PATH}"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
