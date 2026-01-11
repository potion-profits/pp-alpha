extends Control

## Handles switching buttons to appropriate alternate sprite depending on state
##
## Based on the LanguageManager offset and the state offset
##
## @deprecated: Currently used but will be reduced in functionality when multi-language support becomes unsupported

var button_map := {}

const BTN_W = LanguageManager.BTN_W
const BTN_H = LanguageManager.BTN_H
const PADDING_OFFSET = LanguageManager.PADDING_OFFSET


const STATE_OFFSET = {
	"normal": BTN_W*0,
	"hover": BTN_W*0,	#no sprite in alpha for hover
	"pressed": BTN_W*1
}

func _ready()->void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	LanguageManager.connect("language_changed",self._on_lang_changed)
	_update_textures(LanguageManager.current_lang)

func _on_lang_changed(lang: String)->void:
	_update_textures(lang)
	
func _update_textures(lang: String)->void:
	var lang_offset: Variant = LanguageManager.LANG_OFFSET.get(lang, 0)
	for button_name: String in button_map.keys():
		var btn : Node = get_node(button_name)
		var l : String = button_map[button_name]
		var base_tex: AtlasTexture = load(l)
		_set_button_states(btn, base_tex, lang_offset)

func _set_button_states(btn: Button, base_tex: AtlasTexture, lang_off: int)->void:
	for state : String in STATE_OFFSET.keys():
		var tex : AtlasTexture = base_tex.duplicate()
		tex.region.position.y = lang_off
		tex.region.position.x += STATE_OFFSET[state]
		
		var stylebox: StyleBoxTexture = StyleBoxTexture.new()
		stylebox.texture = tex
		
		btn.add_theme_stylebox_override(state, stylebox)
