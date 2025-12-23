extends Control

var progress = []
var scene_path : String
var use_sub_threads : bool = true

func _ready():
	# Start the background load request
	ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)

func _process(_delta):
	# Check the status of the load
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	# Update the bar (progress[0] is a value from 0.0 to 1.0)
	$ProgressBar.value = progress[0] * 100
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		# Load is finished!
		var new_scene = ResourceLoader.load_threaded_get(scene_path)
		get_tree().root.get_node("Main").finalize_load(new_scene)
		queue_free() # Remove the loading screen
