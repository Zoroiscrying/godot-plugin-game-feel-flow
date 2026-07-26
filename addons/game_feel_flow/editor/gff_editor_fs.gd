@tool
class_name GFFEditorFS
extends RefCounted

## Editor FileSystem helpers (highlight / reveal saved resources).


static func reveal_path(path: String) -> void:
	## Refresh FileSystem if needed, then select and scroll to `path` in the dock.
	if not Engine.is_editor_hint() or path.is_empty():
		return
	if not FileAccess.file_exists(path):
		return

	var fs := EditorInterface.get_resource_filesystem()
	fs.update_file(path)

	var reveal := func() -> void:
		var dock := EditorInterface.get_file_system_dock()
		if dock:
			dock.navigate_to_path(path)
		EditorInterface.select_file(path)

	# New folders (e.g. first save into res://presets/combos/) need a scan.
	# Overwrites in a known folder can navigate immediately after update_file.
	var parent_known := fs.get_filesystem_path(path.get_base_dir()) != null
	if fs.is_scanning() or not parent_known:
		fs.filesystem_changed.connect(reveal, CONNECT_ONE_SHOT)
		if not fs.is_scanning():
			fs.scan()
	else:
		reveal.call_deferred()
