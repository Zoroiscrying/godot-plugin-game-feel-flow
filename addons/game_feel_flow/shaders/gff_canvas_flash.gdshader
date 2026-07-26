shader_type canvas_item;

/// Mixes texture RGB toward flash_color while preserving alpha.
/// Needed because CanvasItem.modulate multiplies — white*white is a no-op.

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV) * COLOR;
	tex.rgb = mix(tex.rgb, flash_color.rgb, flash_amount);
	COLOR = tex;
}
