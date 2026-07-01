@tool
extends EditorPlugin

var export_plugin: PicoVRManifestExportPlugin


func _enter_tree() -> void:
	export_plugin = PicoVRManifestExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree() -> void:
	if export_plugin != null:
		remove_export_plugin(export_plugin)
		export_plugin = null


class PicoVRManifestExportPlugin extends EditorExportPlugin:
	var _plugin_name := "PicoVRManifest"

	func _get_name() -> String:
		return _plugin_name

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_manifest_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
		return "\n".join([
			'<uses-permission android:name="org.khronos.openxr.permission.OPENXR" />',
			'<uses-feature android:name="android.hardware.vr.headtracking" android:required="true" android:version="1" />',
			'<uses-feature android:name="android.software.xr.api.openxr" android:required="true" android:version="0x00010000" />',
			'<uses-feature android:name="android.hardware.xr.input.controller" android:required="true" />',
		])

	func _get_android_manifest_application_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
		return "\n".join([
			'<meta-data android:name="pvr.app.type" android:value="vr" />',
			'<meta-data android:name="pvr.sdk.version" android:value="OpenXR" />',
			'<property android:name="android.window.PROPERTY_XR_ACTIVITY_START_MODE" android:value="XR_ACTIVITY_START_MODE_FULL_SPACE_UNMANAGED" />',
			'<property android:name="android.window.PROPERTY_XR_BOUNDARY_TYPE_RECOMMENDED" android:value="XR_BOUNDARY_TYPE_NO_RECOMMENDATION" />',
			'<uses-native-library android:name="libopenxr_loader.so" android:required="false" />',
			'<uses-native-library android:name="libopenxr.google.so" android:required="false" />',
		])

	func _get_android_manifest_activity_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
		return "\n".join([
			'<intent-filter>',
			'    <action android:name="android.intent.action.MAIN" />',
			'    <category android:name="android.intent.category.LAUNCHER" />',
			'    <category android:name="org.khronos.openxr.intent.category.IMMERSIVE_HMD" />',
			'    <category android:name="com.picovr.intent.category.VR" />',
			'</intent-filter>',
		])
