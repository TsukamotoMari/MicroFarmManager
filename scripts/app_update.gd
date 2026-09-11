extends RefCounted
class_name AppUpdate

signal update_available(info: Dictionary)
signal status_changed(message: String)

const VERSION_URLS := [
	"https://TsukamotoMari.github.io/MicroFarmManager/version.json",
	"https://raw.githubusercontent.com/TsukamotoMari/MicroFarmManager/gh-pages/version.json"
]
const REQUEST_HEADERS: Array[String] = [
	"Accept: application/json",
	"User-Agent: MicroFarmManager/1.0 (Android)",
]

var installer := UpdateInstaller.new()
var remote: Dictionary = {}
var busy := false
var ready := false
var message: String = ""
var _version_check_index := 0
var _version_check_http: HTTPRequest
var _checking := false

func get_local_version_code() -> int:
	return installer.get_local_version_code()

func get_local_version_name() -> String:
	return installer.get_local_version_name()

func has_update() -> bool:
	return not remote.is_empty()

func check_for_update(http: HTTPRequest) -> void:
	if OS.get_name() != "Android" or _checking or has_update():
		return
	if not http.request_completed.is_connected(_on_version_response):
		http.request_completed.connect(_on_version_response)
	_version_check_index = 0
	_version_check_http = http
	_checking = true
	_request_next_version_url()

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

func _request_next_version_url() -> void:
	if _version_check_http == null or _version_check_index >= VERSION_URLS.size():
		_checking = false
		return
	var cache_bust := "?t=%d" % Time.get_unix_time_from_system()
	_version_check_http.request(VERSION_URLS[_version_check_index] + cache_bust, PackedStringArray(REQUEST_HEADERS))

func _try_next_version_url() -> void:
	_version_check_index += 1
	_request_next_version_url()

func _is_remote_newer(data: Dictionary) -> bool:
	var remote_code := int(data.get("versionCode", 0))
	var local_code := get_local_version_code()
	if remote_code > local_code:
		return true
	var remote_version := str(data.get("version", ""))
	var local_version := get_local_version_name()
	return _compare_versions(remote_version, local_version) > 0

func _compare_versions(remote_version: String, local_version: String) -> int:
	var remote_parts := _version_parts(remote_version)
	var local_parts := _version_parts(local_version)
	for i in range(maxi(remote_parts.size(), local_parts.size())):
		var remote_part := int(remote_parts[i]) if i < remote_parts.size() else 0
		var local_part := int(local_parts[i]) if i < local_parts.size() else 0
		if remote_part != local_part:
			return remote_part - local_part
	return 0

func _version_parts(version: String) -> PackedStringArray:
	return version.strip_edges().trim_prefix("v").split(".")

func _on_version_response(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		_try_next_version_url()
		return
	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		_try_next_version_url()
		return
	var data: Dictionary = parsed
	if not _is_remote_newer(data):
		_checking = false
		return
	remote = data
	_checking = false
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
