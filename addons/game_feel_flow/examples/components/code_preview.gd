extends Window

## Code preview component
## Show effect call code and support copying

# ===== Properties =====
var code_text: String = ""
var language: String = "gdscript"

# ===== Node References =====
@onready var code_edit: CodeEdit = $VBoxContainer/CodeEdit
@onready var copy_button: Button = $VBoxContainer/HBoxContainer/CopyButton
@onready var close_button: Button = $VBoxContainer/HBoxContainer/CloseButton

# ===== Lifecycle =====

func _ready() -> void:
	copy_button.pressed.connect(_on_copy_pressed)
	close_button.pressed.connect(_on_close_pressed)
	close_requested.connect(_on_close_pressed)

# ===== Public Methods =====

func show_code(code: String, lang: String = "gdscript") -> void:
	code_text = code
	language = lang
	
	if code_edit:
		code_edit.text = code
		code_edit.editable = false
	
	popup_centered(Vector2i(600, 400))

func copy_to_clipboard() -> void:
	DisplayServer.clipboard_set(code_text)

# ===== Callbacks =====

func _on_copy_pressed() -> void:
	copy_to_clipboard()

func _on_close_pressed() -> void:
	hide()