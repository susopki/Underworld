#!/usr/bin/env bash
set -euo pipefail

APK_PATH="${1:-builds/pico/underworld-pico.apk}"
PACKAGE_NAME="${2:-com.underworld.vr.pico}"

if [[ ! -f "$APK_PATH" ]]; then
  echo "APK not found: $APK_PATH" >&2
  exit 1
fi

if ! command -v aapt >/dev/null 2>&1; then
  echo "aapt is required to inspect APK manifests." >&2
  exit 1
fi

echo "Manifest markers in $APK_PATH:"
aapt dump xmltree "$APK_PATH" AndroidManifest.xml | grep -E \
  "pvr.app.type|pvr.sdk.version|com.picovr.intent.category.VR|org.khronos.openxr.intent.category.IMMERSIVE_HMD|android.software.xr.api.openxr|android.hardware.vr.headtracking|android.intent.action.MAIN|android.intent.category.LAUNCHER" \
  || true

if command -v adb >/dev/null 2>&1 && adb get-state >/dev/null 2>&1; then
  echo
  echo "Installed package markers from device:"
  adb shell dumpsys package "$PACKAGE_NAME" | grep -E \
    "pvr.app.type|pvr.sdk.version|com.picovr.intent.category.VR|org.khronos.openxr.intent.category.IMMERSIVE_HMD|android.intent.action.MAIN|android.intent.category.LAUNCHER" \
    || true
fi
