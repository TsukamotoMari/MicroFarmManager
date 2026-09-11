extends RefCounted
class_name AppUpdate

signal update_available(info: Dictionary)
signal status_changed(message: String)
signal check_finished(found: bool, error: String)

const VERSION_URLS := [
	"https://raw.githubusercontent.com/TsukamotoMari/MicroFarmManager/gh-pages/version.json",
	"https://TsukamotoMari.github.io/MicroFarmManager/version.json",
]
const REQUEST_HEADERS: Array[String] = [
	"Accept: application/json",
	"Cache-Control: no-cache",
	"User-Agent: MicroFarmManager/1.0 (Android)",
]
const CHECK_TIMEOUT_SECONDS := 20.0

var installer := UpdateInstaller.new()
var remote: Dictionary = {}
var busy := false
var ready := false
var message: String = ""
var _version_check_index := 0
var _version_check_http: HTTPRequest
var _checking := false
var _check_timeout: SceneTreeTimer

func get_local_version_code() -> int:
	return installer.get_local_version_code()

func get_local_version_name() -> String:
	return installer.get_local_version_name()

func has_update() -> bool:
	return not remote.is_empty()

func check_for_update(http: HTTPRequest) -> void:
	if OS.get_name() != "Android":
		check_finished.emit(false, "Updates only work in the Android app.")
		return
	if _checking:
		return
	if has_update():
		update_available.emit(remote)
		check_finished.emit(true, "")
		return
	if not http.request_completed.is_connected(_on_version_response):
		http.request_completed.connect(_on_version_response)
	_version_check_index = 0
	_version_check_http = http
	_checking = true
	_start_check_timeout(http)
	_request_next_version_url()

func reset_and_check(http: HTTPRequest) -> void:
	_cancel_check_timeout()
	if _version_check_http != null and _version_check_http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_version_check_http.cancel_request()
	_checking = false
	check_for_update(http)

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

func _start_check_timeout(http: HTTPRequest) -> void:
	_cancel_check_timeout()
	if http == null or http.get_tree() == null:
		return
	_check_timeout = http.get_tree().create_timer(CHECK_TIMEOUT_SECONDS)
	_check_timeout.timeout.connect(_on_check_timeout)

func _cancel_check_timeout() -> void:
	if _check_timeout != null and _check_timeout.timeout.is_connected(_on_check_timeout):
		_check_timeout.timeout.disconnect(_on_check_timeout)
	_check_timeout = null

func _on_check_timeout() -> void:
	if not _checking:
		return
	_checking = false
	if _version_check_http != null:
		_version_check_http.cancel_request()
	var err := "Could not reach the update server. Check your connection and try again."
	status_changed.emit(err)
	check_finished.emit(false, err)

func _request_next_version_url() -> void:
	if _version_check_http == null or _version_check_index >= VERSION_URLS.size():
		_finish_check(false, "Could not reach the update server. Check your connection and try again.")
		return
	var cache_bust := "?t=%d" % Time.get_unix_time_from_system()
	var err := _version_check_http.request(
		VERSION_URLS[_version_check_index] + cache_bust,
		PackedStringArray(REQUEST_HEADERS)
	)
	if err != OK:
		_try_next_version_url()

func _try_next_version_url() -> void:
	_version_check_index += 1
	_request_next_version_url()

func _finish_check(found: bool, error: String = "") -> void:
	_checking = false
	_cancel_check_timeout()
	check_finished.emit(found, error)
	if not error.is_empty():
		status_changed.emit(error)

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
		_finish_check(false, "")
		return
	remote = data
	_finish_check(true, "")
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
