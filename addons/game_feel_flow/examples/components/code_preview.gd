extends Window

## 代码预览组件
## 显示效果调用代码并支持复制

# ===== 属性 =====
var code_text: String = ""
var language: String = "gdscript"

# ===== 节点引用 =====
@onready var code_edit: CodeEdit = $VBoxContainer/CodeEdit
@onready var copy_button: Button = $VBoxContainer/HBoxContainer/CopyButton
@onready var close_button: Button = $VBoxContainer/HBoxContainer/CloseButton

# ===== 生命周期 =====

func _ready() -> void:
	copy_button.pressed.connect(_on_copy_pressed)
	close_button.pressed.connect(_on_close_pressed)
	close_requested.connect(_on_close_pressed)

# ===== 公共方法 =====

func show_code(code: String, lang: String = "gdscript") -> void:
	code_text = code
	language = lang
	
	if code_edit:
		code_edit.text = code
		code_edit.editable = false
	
	popup_centered(Vector2i(600, 400))

func copy_to_clipboard() -> void:
	DisplayServer.clipboard_set(code_text)

# ===== 回调方法 =====

func _on_copy_pressed() -> void:
	copy_to_clipboard()

func _on_close_pressed() -> void:
	hide()