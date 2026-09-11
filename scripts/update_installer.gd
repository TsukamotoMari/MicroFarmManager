extends RefCounted
class_name UpdateInstaller

signal download_finished(ready: bool, error: String)
signal install_finished(needs_permission: bool, launched: bool, error: String)

const PLUGIN_NAME := "UpdateInstaller"

var _plugin

func _init() -> void:
	if Engine.has_singleton(PLUGIN_NAME):
		_plugin = Engine.get_singleton(PLUGIN_NAME)
		if not _plugin.update_download_finished.is_connected(_on_download_finished):
			_plugin.update_download_finished.connect(_on_download_finished)
		if not _plugin.update_install_finished.is_connected(_on_install_finished):
			_plugin.update_install_finished.connect(_on_install_finished)

func is_available() -> bool:
	return _plugin != null

func get_local_version_code() -> int:
	if _plugin != null:
		return int(_plugin.getLocalVersionCode())
	return int(ProjectSettings.get_setting("application/config/version_code", 1))

func get_local_version_name() -> String:
	if _plugin != null:
		return str(_plugin.getLocalVersionName())
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))

func download_update(url: String, fallback_url: String, version_code: int) -> void:
	if _plugin == null:
		download_finished.emit(false, "Updates only work in the Android app.")
		return
	_plugin.downloadUpdate(url, fallback_url, version_code)

func open_installer() -> void:
	if _plugin == null:
		install_finished.emit(false, false, "Updates only work in the Android app.")
		return
	_plugin.openInstaller()

func _on_download_finished(ready: bool, error: String) -> void:
	download_finished.emit(ready, error)

func _on_install_finished(needs_permission: bool, launched: bool, error: String) -> void:
	install_finished.emit(needs_permission, launched, error)
