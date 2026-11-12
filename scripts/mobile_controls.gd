extends Node
class_name EVEEMobileControls

static func make_hold_button(label_text: String, action_name: String, minimum_size := Vector2(116.0, 82.0)) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = minimum_size
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _button_style(Color(0.07, 0.09, 0.14, 0.82)))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.18, 0.12, 0.30, 0.94)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.36, 0.16, 0.62, 0.96)))
	button.button_down.connect(func(): Input.action_press(action_name))
	button.button_up.connect(func(): Input.action_release(action_name))
	button.tree_exiting.connect(func(): Input.action_release(action_name))
	return button

static func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.65, 0.48, 0.92, 0.7)
	return style
