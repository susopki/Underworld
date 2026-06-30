# Pico Neo 3 / Pico 4 build target

Goal: make Underworld launch on Pico as a VR game, not as a flat Android application.

## Required manifest markers

The final exported APK must contain these entries on the main Godot activity/application:

```xml
<meta-data android:name="pvr.app.type" android:value="vr" />
<meta-data android:name="pvr.sdk.version" android:value="OpenXR" />

<intent-filter>
    <action android:name="android.intent.action.MAIN" />
    <category android:name="android.intent.category.LAUNCHER" />
    <category android:name="org.khronos.openxr.intent.category.IMMERSIVE_HMD" />
    <category android:name="com.picovr.intent.category.VR" />
</intent-filter>
```

Also keep Android/XR discovery flags:

```xml
<uses-permission android:name="org.khronos.openxr.permission.OPENXR" />
<uses-feature android:name="android.hardware.vr.headtracking" android:required="true" android:version="1" />
<uses-feature android:name="android.software.xr.api.openxr" android:version="0x00010000" android:required="true" />
<uses-feature android:name="android.hardware.xr.input.controller" android:required="true" />
```

## Godot setup

Use one project, but export a dedicated Pico build:

- Renderer: Mobile.
- OpenXR: enabled.
- XR shaders: enabled.
- Architecture: arm64-v8a only.
- Package name: `com.underworld.vr.pico`.
- Package label: `Underworld`.
- Launch scene for VR build: `res://scenes/MainVR.tscn` once the VR rig is added.
- Target devices: Pico Neo 3, Pico 4.

Install Android build templates when Android SDK/export templates are available:

```bash
godot --headless --path /home/tux/Underworld --install-android-build-template
```

Then merge `platform/pico/AndroidManifest.pico-openxr.xml` into the generated Godot Android manifest.

## Device-side validation

Build and install:

```bash
godot --headless --path /home/tux/Underworld --export-release "Pico Android XR" builds/pico/underworld-pico.apk
adb install -r builds/pico/underworld-pico.apk
```

Check that Pico sees the package as launchable VR content:

```bash
adb shell dumpsys package com.underworld.vr.pico | grep -E "pvr.app.type|com.picovr.intent.category.VR|IMMERSIVE_HMD|MAIN|LAUNCHER"
```

Launch directly:

```bash
adb shell monkey -p com.underworld.vr.pico -c android.intent.category.LAUNCHER 1
```

If it opens as a flat 2D panel, the APK manifest is missing either:

- `com.picovr.intent.category.VR`; or
- `pvr.app.type=vr`; or
- OpenXR runtime/loader entries.

## Pico OS note

For modern Pico OS use Khronos OpenXR loader path. Avoid relying on the old custom Pico OpenXR loader unless targeting old firmware deliberately.
