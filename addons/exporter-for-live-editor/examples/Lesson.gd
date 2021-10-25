extends Container

signal lesson_completed

const Exercise := preload("./Exercise.gd")
const LessonDonePopup := preload(
	"res://addons/exporter-for-live-editor/ui/components/LessonDonePopup.gd"
)

var _exercises := []
var _current_exercise := 0

onready var exercises_container := $Exercises as Container
onready var next_button := find_node("NextButton") as Button
onready var done_popup := find_node("LessonDonePopup") as LessonDonePopup


func _ready() -> void:
	done_popup.visible = false
	done_popup.connect("pressed", NavigationManager, "back")

	for child in exercises_container.get_children():
		if child is Exercise:
			var exercise := child as Exercise
			var index := _exercises.size()
			exercise.connect("exercise_validated", self, "_on_exercise_validated", [index])
			_exercises.append(exercise)

	for index in _exercises.size():
		var progress = (float(index + 1) / _exercises.size()) * 100
		var exercise := _exercises[index] as Exercise
		exercise.progress = progress
		exercise.visible = index == 0

	next_button.connect("pressed", self, "_on_next_button_pressed")


func _on_exercise_validated(is_valid: bool, exercise_index: int) -> void:
	_current_exercise = exercise_index + 1
	if _current_exercise >= _exercises.size():
		emit_signal("lesson_completed")
		done_popup.show()
	else:
		next_button.disabled = not is_valid


func _on_next_button_pressed() -> void:
	for index in _exercises.size():
		var exercise := _exercises[index] as Exercise
		var show = index == _current_exercise
		exercise.visible = show
