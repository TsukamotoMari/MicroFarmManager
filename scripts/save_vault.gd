extends RefCounted
class_name SaveVault

signal read_finished(ok: bool, json_text: String, exists: bool)
signal write_finished(ok: bool, error: String)

const PLUGIN_NAME := "SaveVault"

var _plugin

func is_available() -> bool:
	return _ensure_plugin()

func prepare_restore() -> void:
	if _ensure_plugin():
		_plugin.prepareRestore()

func write_save(json_text: String) -> void:
	if not _ensure_plugin():
		return
	_plugin.writeSave(json_text)

func read_save() -> void:
	if not _ensure_plugin():
		read_finished.emit(false, "", false)
		return
	_plugin.readSave()

func _ensure_plugin() -> bool:
	if _plugin != null:
		return true
	if not Engine.has_singleton(PLUGIN_NAME):
		return false
	_plugin = Engine.get_singleton(PLUGIN_NAME)
	if not _plugin.save_vault_read_finished.is_connected(_on_read_finished):
		_plugin.save_vault_read_finished.connect(_on_read_finished)
	if not _plugin.save_vault_write_finished.is_connected(_on_write_finished):
		_plugin.save_vault_write_finished.connect(_on_write_finished)
	return true

func _on_read_finished(ok: bool, json_text: String, exists: bool) -> void:
	read_finished.emit(ok, json_text, exists)

func _on_write_finished(ok: bool, error: String) -> void:
	write_finished.emit(ok, error)
