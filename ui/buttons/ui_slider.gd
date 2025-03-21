@tool
class_name UISlider
extends Control
## A common UI slider.[br]
## The script is a tool script so the visuals update accordingly.

# TODO: Add ticks, but there's a bug in Godot that prevents this.
# ISSUE LINK: https://github.com/godotengine/godot/issues/103839

@export var max_value: float = 100.0:
	set(val):
		max_value = val

		if is_instance_valid(slider):
			slider.max_value = val
			_update_slider(value, false)
		if is_instance_valid(progress):
			progress.max_value = val
@export var value: float = 50.0:
	set(val):
		value = clampf(val, 0, max_value)

		if is_instance_valid(slider):
			slider.value = val
		if is_instance_valid(progress):
			progress.value = val
		if is_instance_valid(grabber_point) and grabber_point.is_inside_tree():
			grabber_point.progress_ratio = val / max_value

@export var default_value: float = 50.0

@export var slider_step: float = 1.0:
	set(val):
		slider_step = val

		if is_instance_valid(slider):
			slider.step = val
#@export var ticked: bool = false:
	#set(val):
		#ticked = val
#
		#if is_instance_valid(slider):
			#_update_ticks()

@export_category("References")
@export var slider: HSlider
@export var grabber_path: Path2D
@export var grabber_point: PathFollow2D
@export var grabber_button: Button
@export var grabber_rect: ColorRect
@export var progress: ProgressBar
@export var tick_sound: AudioStream


func _ready() -> void:
	_update_size()

	slider.value_changed.connect(_update_slider.bind(true))

	resized.connect(_update_size)
	resized.connect(func(): _update_slider(value, false))

	_set_initial_val()


## Can get overwritten by a parent class to change which value is loaded in.
func _set_initial_val() -> void:
	slider.value = default_value
	_update_slider(default_value, false)


func _update_size() -> void:
	progress.size.x = size.x
	slider.size.x = size.x - 2

	#_update_ticks()

	grabber_path.curve.clear_points()
	var x: float = size.x - grabber_button.size.x
	var y: float = floor(size.y / 2)
	grabber_path.curve.add_point(Vector2(0, y))
	grabber_path.curve.add_point(Vector2(x, y))


#func _update_ticks():
	#if ticked == true:
		#slider.tick_count = round(size.x / 8)
	#else:
		#slider.tick_count = 0


func _update_slider(new_value: float, play_sfx: bool = true) -> void:
	value = new_value

	if play_sfx:
		_try_sfx()


## Tries to play the tick sound effect if the conditions are met.
func _try_sfx():
	# If not playing on ready, and no sound effects are 
	# playing in the UI audio bus:
	if get_tree().get_nodes_in_group(&"UI").is_empty():
		SFX.play_sfx(tick_sound, &"UI", self)
