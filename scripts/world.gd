extends Node3D

var player: CharacterBody3D
var hud: CanvasLayer
var money := 0
var bottles := 0
var message_label: Label
var money_label: Label
var touch_vector := Vector2.ZERO
var job_ready := true

func _ready() -> void:
    _make_environment()
    _make_player()
    _make_pickups()
    _make_hud()
    _say("Лето 2005-го. В кармане пусто. Надо заработать на свою девятку.")

func _make_environment() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.72, 0.78, 0.84)
    env.ambient_light_energy = 0.8
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -30, 0)
    sun.light_energy = 1.2
    add_child(sun)

    _box("Асфальт", Vector3(0, -0.25, 0), Vector3(34, 0.5, 34), Color(0.22,0.23,0.22))
    _box("Панелька слева", Vector3(-12, 4, -8), Vector3(5, 8, 18), Color(0.72,0.63,0.48))
    _box("Панелька справа", Vector3(12, 4, -9), Vector3(5, 8, 18), Color(0.62,0.68,0.65))
    _box("Гаражи", Vector3(-8, 1.4, 11), Vector3(15, 2.8, 4), Color(0.36,0.39,0.38))
    _box("Крыша гаражей", Vector3(-8, 2.9, 11), Vector3(15.3, 0.25, 4.3), Color(0.25,0.27,0.27))
    _box("Дорога", Vector3(0, 0.02, -15), Vector3(34, 0.08, 3), Color(0.12,0.12,0.12))
    for i in range(5):
        _box("Разметка", Vector3(-13 + i * 6.5, 0.08, -15), Vector3(2.8,0.02,0.12), Color(0.82,0.78,0.58))
    _box("Скамейка сиденье", Vector3(3,0.7,2), Vector3(3,0.18,0.55), Color(0.12,0.25,0.55))
    _box("Скамейка спинка", Vector3(3,1.15,2.25), Vector3(3,0.75,0.15), Color(0.12,0.25,0.55))
    _box("Столб", Vector3(7,2,6), Vector3(0.18,4,0.18), Color(0.35,0.34,0.3))
    _box("Киоск", Vector3(10,1.4,3), Vector3(3,2.8,2.5), Color(0.55,0.34,0.2))
    _box("Крыша киоска", Vector3(10,2.9,3), Vector3(3.3,0.2,2.8), Color(0.25,0.2,0.16))

func _box(label: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = label
    body.position = pos
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    body.add_child(mesh)
    var shape := CollisionShape3D.new()
    var box_shape := BoxShape3D.new()
    box_shape.size = size
    shape.shape = box_shape
    body.add_child(shape)
    add_child(body)

func _make_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Vitek"
    player.position = Vector3(0, 1, 5)
    var mesh := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.38
    capsule.height = 1.7
    mesh.mesh = capsule
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.55,0.42,0.3)
    mesh.material_override = mat
    mesh.position.y = 0.85
    player.add_child(mesh)
    var collision := CollisionShape3D.new()
    var cap_shape := CapsuleShape3D.new()
    cap_shape.radius = 0.38
    cap_shape.height = 1.7
    collision.shape = cap_shape
    collision.position.y = 0.85
    player.add_child(collision)
    var camera := Camera3D.new()
    camera.position = Vector3(0, 4.5, 7)
    camera.rotation_degrees = Vector3(-22, 0, 0)
    player.add_child(camera)
    camera.current = true
    add_child(player)

func _make_pickups() -> void:
    for p in [Vector3(-5,0.35,1), Vector3(5,0.35,-5), Vector3(9,0.35,9), Vector3(-10,0.35,-3)]:
        var area := Area3D.new()
        area.position = p
        var mesh := MeshInstance3D.new()
        var bottle := CylinderMesh.new()
        bottle.top_radius = 0.09
        bottle.bottom_radius = 0.12
        bottle.height = 0.55
        mesh.mesh = bottle
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.2,0.65,0.25)
        mesh.material_override = mat
        area.add_child(mesh)
        var collision := CollisionShape3D.new()
        var sphere := SphereShape3D.new()
        sphere.radius = 0.7
        collision.shape = sphere
        area.add_child(collision)
        area.body_entered.connect(_on_bottle_found.bind(area))
        add_child(area)

func _on_bottle_found(body: Node3D, bottle: Area3D) -> void:
    if body == player:
        bottles += 1
        money += 5
        bottle.queue_free()
        _update_hud()
        _say("Подобрал бутылку. Пять рублей в карман, уже не ноль!")

func _make_hud() -> void:
    hud = CanvasLayer.new()
    add_child(hud)
    var panel := PanelContainer.new()
    panel.position = Vector2(16,16)
    panel.size = Vector2(290,88)
    hud.add_child(panel)
    var vbox := VBoxContainer.new()
    panel.add_child(vbox)
    money_label = Label.new()
    vbox.add_child(money_label)
    message_label = Label.new()
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    message_label.custom_minimum_size = Vector2(270,45)
    vbox.add_child(message_label)
    _update_hud()

    var hint := Label.new()
    hint.text = "WASD / стрелки: ходить   E: подработка"
    hint.position = Vector2(16,112)
    hud.add_child(hint)

    var job_button := Button.new()
    job_button.text = "Подработка"
    job_button.position = Vector2(16, get_viewport().get_visible_rect().size.y - 90)
    job_button.size = Vector2(150,60)
    job_button.pressed.connect(_do_job)
    hud.add_child(job_button)

    var controls := HBoxContainer.new()
    controls.position = Vector2(get_viewport().get_visible_rect().size.x - 210, get_viewport().get_visible_rect().size.y - 190)
    controls.add_theme_constant_override("separation", 6)
    hud.add_child(controls)
    for pair in [["←", Vector2.LEFT], ["↑", Vector2.UP], ["↓", Vector2.DOWN], ["→", Vector2.RIGHT]]:
        var b := Button.new()
        b.text = pair[0]
        b.custom_minimum_size = Vector2(46,56)
        b.button_down.connect(func(): touch_vector = pair[1])
        b.button_up.connect(func(): touch_vector = Vector2.ZERO)
        controls.add_child(b)

func _do_job() -> void:
    if job_ready:
        money += 25
        job_ready = false
        _update_hud()
        _say("Разгрузил ящики у ларька. Двадцать пять рублей! Спина сказала спасибо, но не очень.")
    else:
        _say("На сегодня смена закончена. Дай спине пожить, брат.")

func _say(text: String) -> void:
    if is_instance_valid(message_label):
        message_label.text = text

func _update_hud() -> void:
    if is_instance_valid(money_label):
        money_label.text = "В кармане: %d ₽   Бутылок: %d" % [money, bottles]

func _physics_process(_delta: float) -> void:
    if not is_instance_valid(player):
        return
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if touch_vector != Vector2.ZERO:
        input = touch_vector
    var direction := Vector3(input.x, 0, input.y)
    player.velocity.x = direction.x * 5.0
    player.velocity.z = direction.z * 5.0
    player.velocity.y -= 20.0 * _delta
    player.move_and_slide()
    if Input.is_action_just_pressed("interact"):
        _do_job()
