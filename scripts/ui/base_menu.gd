extends Control

var button_map := {}

const BTN_W = LanguageManager.BTN_W
const BTN_H = LanguageManager.BTN_H
const PADDING_OFFSET = LanguageManager.PADDING_OFFSET


const STATE_OFFSET = {
	"normal": BTN_W*0,
	"hover": BTN_W*0,	#no sprite in alpha for hover
	"pressed": BTN_W*1
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	LanguageManager.connect("language_changed",self._on_lang_changed)
	_update_textures(LanguageManager.current_lang)

func _on_lang_changed(lang: String):
	_update_textures(lang)
	
func _update_textures(lang: String):
	var lang_offset = LanguageManager.LANG_OFFSET.get(lang, 0)
	for button_name in button_map.keys():
		var btn = get_node(button_name)
		var l = button_map[button_name]
		var base_tex: AtlasTexture = load(l)
		_set_button_states(btn, base_tex, lang_offset)

func _set_button_states(btn: Button, base_tex: AtlasTexture, lang_off: int):
	for state in STATE_OFFSET.keys():
		var tex = base_tex.duplicate()
		tex.region.position.y = lang_off
		tex.region.position.x += STATE_OFFSET[state]
		
		var stylebox = StyleBoxTexture.new()
		stylebox.texture = tex
		
		btn.add_theme_stylebox_override(state, stylebox)
