extends Node

const CONFIG_PATH = "user://settings.cfg"

var current_lang := "en"
var supported_langs = ["en", "fr", "es", "zh", "pt", "ar", "ru"]

const BTN_H = 16
const BTN_W = 48
#const PADDING_OFFSET = 2 * BTN_W	#map has 2 cols of non used sprites
const PADDING_OFFSET = 2*BTN_W	#map has 2 cols of non used sprites
const LANG_OFFSET = {
	"en": BTN_H*0,
	"fr": BTN_H*1,
	"es": BTN_H*2,
	"zh": BTN_H*3,
	"pt": BTN_H*4,
	"ar": BTN_H*5,
	"ru": BTN_H*6
}

signal language_changed(lang:String)

func _ready():
	load_language()
	
func set_languages(lang: String):
	if lang not in supported_langs:
		push_warning("Unsupported language: %s" % lang)
		return
	current_lang = lang
	save_language()
	emit_signal("language_changed", lang)
	
func next_language():
	var next_i = (supported_langs.find(current_lang) + 1) % supported_langs.size()
	set_languages(supported_langs[next_i])

func save_language():
	var cfg = ConfigFile.new()
	cfg.set_value("settings","language", current_lang)
	cfg.save(CONFIG_PATH)
	
func load_language():
	var cfg = ConfigFile.new()
	var err = cfg.load(CONFIG_PATH)
	if err == OK:
		current_lang = cfg.get_value("settings","language","en")
