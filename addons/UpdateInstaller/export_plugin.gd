@tool
extends EditorPlugin

var export_plugin: AndroidExportPlugin

func _enter_tree() -> void:
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)

func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null

class AndroidExportPlugin extends EditorExportPlugin:
	var _plugin_name := "UpdateInstaller"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		if debug:
			return PackedStringArray([
				"UpdateInstaller/bin/debug/UpdateInstaller-debug.aar"
			])
		return PackedStringArray([
			"UpdateInstaller/bin/release/UpdateInstaller-release.aar"
		])

	func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"androidx.core:core:1.15.0"
		])

	func _get_android_manifest_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
		return """
		<uses-permission android:name="android.permission.INTERNET" />
		<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
		<queries>
			<intent>
				<action android:name="android.intent.action.VIEW" />
				<data android:mimeType="application/vnd.android.package-archive" />
			</intent>
		</queries>
		"""

	func _get_android_manifest_application_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
		return """
		<provider
			android:name="androidx.core.content.FileProvider"
			android:authorities="com.devinaigames.microfarmmanager.fileprovider"
			android:exported="false"
			android:grantUriPermissions="true">
			<meta-data
				android:name="android.support.FILE_PROVIDER_PATHS"
				android:resource="@xml/update_file_paths" />
		</provider>
		"""

	func _get_name() -> String:
		return _plugin_name
