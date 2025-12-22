class_name CarGUICanvas
extends CanvasLayer

@export var car: Car
@onready var gui: CarGUI = $CarGUI
@onready var reset_message: Label = %ResetMessage

var max_laps:
	set(value):
		if is_inf(value):
			value = "∞"
		max_laps = value
		%LapCount.text = str(car.current_lap) + " of "  + str(max_laps)

func _ready():
	if car:
		car.speed_updated.connect(_on_player_speed_updated)
		car.lap_completed.connect(_on_player_lap_completed)

func on_track_changed(track: Track) -> void:
	%LapCount.text = str(car.current_lap) + " of "  + str(max_laps)
	
func on_max_laps_changed(new_max_laps) -> void:
	max_laps = new_max_laps
	
func _on_player_lap_completed(car: Car) -> void:
	%LapCount.text = str(car.current_lap) + " of "  + str(max_laps)

func _on_player_speed_updated(speed: float) -> void:
	%Speed.text = str(round(speed * 3.6)) + " KMH"
	%RawSpeed.text = str(speed)
	
func on_car_flipped(car: Car):
	reset_message.show()
	
func on_car_reset(car: Car):
	reset_message.hide()
