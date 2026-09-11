#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT_VERSION="${GODOT_VERSION:-4.7.2}"
GODOT_CHANNEL="${GODOT_CHANNEL:-stable}"
EXPORT_PRESET="${EXPORT_PRESET:-Android}"
OUTPUT_PATH="${OUTPUT_PATH:-${ROOT_DIR}/builds/android/micro_farm_manager.apk}"
KEYSTORE_PATH="${ROOT_DIR}/android/keystore/debug.keystore"

mkdir -p "$(dirname "${OUTPUT_PATH}")"
mkdir -p "${HOME}/.config/godot"
JAVA_SDK_PATH="${JAVA_HOME:-/usr/lib/jvm/temurin-17-jdk-amd64}"
cat > "${HOME}/.config/godot/editor_settings-4.7.tres" <<EOF
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/debug_keystore = "res://android/keystore/debug.keystore"
export/android/debug_keystore_pass = "android"
export/android/java_sdk_path = "${JAVA_SDK_PATH}"
export/android/android_sdk_path = "${ANDROID_HOME:-/usr/local/lib/android/sdk}"
EOF

if [[ ! -d "${HOME}/.local/share/godot/export_templates/${GODOT_VERSION}.${GODOT_CHANNEL}" ]]; then
  echo "Install Godot ${GODOT_VERSION}.${GODOT_CHANNEL} export templates before running this script."
  exit 1
fi

export GODOT_ANDROID_KEYSTORE_DEBUG_PATH="${KEYSTORE_PATH}"
export GODOT_ANDROID_KEYSTORE_DEBUG_USER="androiddebugkey"
export GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD="android"
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="${KEYSTORE_PATH}"
export GODOT_ANDROID_KEYSTORE_RELEASE_USER="androiddebugkey"
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="android"

godot --headless --path "${ROOT_DIR}" --export-release "${EXPORT_PRESET}" "${OUTPUT_PATH}"
echo "Exported ${OUTPUT_PATH}"
