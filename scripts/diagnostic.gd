extends Control

var status_label: Label
var log_path := "user://vitek_diagnostic.log"

func _ready() -> void:
    _write_log("BOOT: _ready entered")
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var background := ColorRect.new()
    background.color = Color(0.055, 0.075, 0.10, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 18)
    center.add_child(column)

    var title := Label.new()
    title.text = "ВИТЁК: ДИАГНОСТИКА"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 30)
    column.add_child(title)

    status_label = Label.new()
    status_label.text = "Экран 2D запущен. Проверка пройдена."
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 21)
    column.add_child(status_label)

    var details := Label.new()
    details.text = "Если ты видишь эту надпись, APK запускает Godot и рисует интерфейс.\n3D-двор временно отключён для проверки."
    details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    details.add_theme_font_size_override("font_size", 16)
    column.add_child(details)

    _write_log("UI: 2D controls created")
    status_label.text = "2D ЗАПУСК УСПЕШЕН"
    _write_log("PASS: diagnostic screen visible")

func _write_log(line: String) -> void:
    var file := FileAccess.open(log_path, FileAccess.READ_WRITE)
    if file == null:
        file = FileAccess.open(log_path, FileAccess.WRITE)
    if file != null:
        file.seek_end()
        file.store_line(Time.get_datetime_string_from_system() + " " + line)
        file.close()
