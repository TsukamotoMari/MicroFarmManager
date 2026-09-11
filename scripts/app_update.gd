extends RefCounted
class_name AppUpdate

signal update_available(info: Dictionary)
signal status_changed(message: String)

const GITHUB_REPO := "TsukamotoMari/MicroFarmManager"
const VERSION_URL := "https://TsukamotoMari.github.io/MicroFarmManager/version.json"

var installer := UpdateInstaller.new()
var remote: Dictionary = {}
var busy := false
var ready := false
var message: String = ""

func get_local_version_code() -> int:
	return installer.get_local_version_code()

func get_local_version_name() -> String:
	return installer.get_local_version_name()

func has_update() -> bool:
	return not remote.is_empty()

func check_for_update(http: HTTPRequest) -> void:
	if OS.get_name() != "Android":
		return
	if not http.request_completed.is_connected(_on_version_response):
		http.request_completed.connect(_on_version_response)
	var cache_bust := "?t=%d" % Time.get_unix_time_from_system()
	http.request(VERSION_URL + cache_bust)

func install_update() -> void:
	if remote.is_empty() or busy:
		return
	if ready:
		installer.open_installer()
		return
	busy = true
	message = ""
	status_changed.emit(message)
	installer.download_update(
		str(remote.get("apkUrl", "")),
		str(remote.get("fallbackUrl", "")),
		int(remote.get("versionCode", 0))
	)

func _on_version_response(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code < 200 or response_code >= 300:
		return
	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	var remote_code := int(data.get("versionCode", 0))
	if remote_code <= get_local_version_code():
		return
	remote = data
	update_available.emit(remote)

func _on_download_finished(ok: bool, error: String) -> void:
	busy = false
	if ok:
		ready = true
		message = "Download finished. Tap Install now and confirm the Android screen."
	else:
		ready = false
		message = error if not error.is_empty() else "Download failed."
	status_changed.emit(message)

func _on_install_finished(needs_permission: bool, launched: bool, error: String) -> void:
	if needs_permission:
		message = error if not error.is_empty() else "Turn on Allow from this source, then tap Install now."
	elif launched:
		message = error if not error.is_empty() else "Confirm the Android install screen."
	elif not error.is_empty():
		message = error
		if error.contains("gone"):
			ready = false
	status_changed.emit(message)

func connect_installer_signals() -> void:
	if not installer.download_finished.is_connected(_on_download_finished):
		installer.download_finished.connect(_on_download_finished)
	if not installer.install_finished.is_connected(_on_install_finished):
		installer.install_finished.connect(_on_install_finished)
