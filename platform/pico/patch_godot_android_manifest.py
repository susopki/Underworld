#!/usr/bin/env python3
from __future__ import annotations

import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ANDROID_NS = "http://schemas.android.com/apk/res/android"
ET.register_namespace("android", ANDROID_NS)


def a(name: str) -> str:
    return f"{{{ANDROID_NS}}}{name}"


def has_child(parent: ET.Element, tag: str, android_name: str | None = None) -> bool:
    for child in parent.findall(tag):
        if android_name is None:
            return True
        if child.get(a("name")) == android_name:
            return True
    return False


def add_uses_permission(manifest: ET.Element, name: str) -> None:
    if not has_child(manifest, "uses-permission", name):
        item = ET.Element("uses-permission")
        item.set(a("name"), name)
        manifest.insert(0, item)


def add_uses_feature(manifest: ET.Element, name: str, required: bool = True, version: str | None = None) -> None:
    if not has_child(manifest, "uses-feature", name):
        item = ET.Element("uses-feature")
        item.set(a("name"), name)
        item.set(a("required"), "true" if required else "false")
        if version:
            item.set(a("version"), version)
        manifest.insert(0, item)


def add_meta(application: ET.Element, name: str, value: str) -> None:
    for child in application.findall("meta-data"):
        if child.get(a("name")) == name:
            child.set(a("value"), value)
            return
    item = ET.Element("meta-data")
    item.set(a("name"), name)
    item.set(a("value"), value)
    application.insert(0, item)


def add_property(application: ET.Element, name: str, value: str) -> None:
    for child in application.findall("property"):
        if child.get(a("name")) == name:
            child.set(a("value"), value)
            return
    item = ET.Element("property")
    item.set(a("name"), name)
    item.set(a("value"), value)
    application.insert(0, item)


def add_native_library(application: ET.Element, name: str, required: bool = False) -> None:
    for child in application.findall("uses-native-library"):
        if child.get(a("name")) == name:
            child.set(a("required"), "true" if required else "false")
            return
    item = ET.Element("uses-native-library")
    item.set(a("name"), name)
    item.set(a("required"), "true" if required else "false")
    application.append(item)


def intent_filter_is_launcher(intent_filter: ET.Element) -> bool:
    has_main = False
    has_launcher = False
    for child in intent_filter:
        if child.tag == "action" and child.get(a("name")) == "android.intent.action.MAIN":
            has_main = True
        if child.tag == "category" and child.get(a("name")) == "android.intent.category.LAUNCHER":
            has_launcher = True
    return has_main and has_launcher


def add_category(intent_filter: ET.Element, name: str) -> None:
    for child in intent_filter.findall("category"):
        if child.get(a("name")) == name:
            return
    category = ET.Element("category")
    category.set(a("name"), name)
    intent_filter.append(category)


def find_main_activity(application: ET.Element) -> ET.Element:
    for activity in application.findall("activity"):
        for intent_filter in activity.findall("intent-filter"):
            if intent_filter_is_launcher(intent_filter):
                return activity
    activities = application.findall("activity")
    if not activities:
        raise RuntimeError("No <activity> found in AndroidManifest.xml")
    return activities[0]


def patch(path: Path) -> None:
    tree = ET.parse(path)
    manifest = tree.getroot()
    application = manifest.find("application")
    if application is None:
        raise RuntimeError("No <application> found in AndroidManifest.xml")

    add_uses_permission(manifest, "org.khronos.openxr.permission.OPENXR")
    add_uses_feature(manifest, "android.hardware.vr.headtracking", True, "1")
    add_uses_feature(manifest, "android.software.xr.api.openxr", True, "0x00010000")
    add_uses_feature(manifest, "android.hardware.xr.input.controller", True)

    application.set(a("isGame"), "true")
    application.set(a("appCategory"), "game")
    application.set(a("resizeableActivity"), "false")

    add_meta(application, "pvr.app.type", "vr")
    add_meta(application, "pvr.sdk.version", "OpenXR")
    add_property(application, "android.window.PROPERTY_XR_ACTIVITY_START_MODE", "XR_ACTIVITY_START_MODE_FULL_SPACE_UNMANAGED")
    add_property(application, "android.window.PROPERTY_XR_BOUNDARY_TYPE_RECOMMENDED", "XR_BOUNDARY_TYPE_NO_RECOMMENDATION")
    add_native_library(application, "libopenxr_loader.so", False)
    add_native_library(application, "libopenxr.google.so", False)

    activity = find_main_activity(application)
    activity.set(a("exported"), "true")
    activity.set(a("screenOrientation"), "landscape")
    activity.set(a("launchMode"), "singleTask")

    launcher_filter = None
    for intent_filter in activity.findall("intent-filter"):
        if intent_filter_is_launcher(intent_filter):
            launcher_filter = intent_filter
            break
    if launcher_filter is None:
        launcher_filter = ET.SubElement(activity, "intent-filter")
        action = ET.SubElement(launcher_filter, "action")
        action.set(a("name"), "android.intent.action.MAIN")
        category = ET.SubElement(launcher_filter, "category")
        category.set(a("name"), "android.intent.category.LAUNCHER")

    add_category(launcher_filter, "org.khronos.openxr.intent.category.IMMERSIVE_HMD")
    add_category(launcher_filter, "com.picovr.intent.category.VR")

    ET.indent(tree, space="    ")
    tree.write(path, encoding="utf-8", xml_declaration=True)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: patch_godot_android_manifest.py path/to/AndroidManifest.xml")
    patch(Path(sys.argv[1]))
