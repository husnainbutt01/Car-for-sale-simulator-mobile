extends Node3D

const START_CASH := 35000
const CAR_PRICE := 8000
var cash := START_CASH
var owned_cars: Array[String] = []
var selected_car := "None"
var reputation := 10
var day := 1
var is_driving := false
var drive_speed := 0.0
var fuel := 100.0
var engine_health := 100.0
var car_paint := Color(0.82, 0.12, 0.10)
var player: CharacterBody3D
var demo_car: CharacterBody3D
var hud: CanvasLayer
var cash_label: Label
var status_label: Label
var message_label: Label
var speed_label: Label
var panel: PanelContainer
var day_timer := 0.0

func _ready() -> void:
    player = $Player
    _setup_environment()
    _build_world()
    _build_dealership()
    _build_demo_car()
    _build_hud()
    _message("Welcome to Husnain Auto Dealership. Walk to a car and buy it!")
    _refresh_hud()

func _process(delta: float) -> void:
    day_timer += delta
    if day_timer >= 180.0:
        day_timer = 0.0
        day += 1
        reputation = min(100, reputation + 1)
        _message("A new business day has started!")
        _refresh_hud()
    if is_driving and is_instance_valid(demo_car):
        var throttle := Input.get_action_strength("accelerate")
        var brake_input := Input.get_action_strength("brake")
        drive_speed = move_toward(drive_speed, throttle * 22.0, 14.0 * delta)
        drive_speed = move_toward(drive_speed, 0.0, (5.0 + brake_input * 30.0) * delta)
        demo_car.position += -demo_car.transform.basis.z * drive_speed * delta
        var steer := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
        demo_car.rotate_y(-steer * delta * clamp(drive_speed / 8.0, 0.2, 1.3))
        fuel = max(0.0, fuel - throttle * delta * 0.18)
        if fuel <= 0.0:
            drive_speed = 0.0
        if is_instance_valid(speed_label):
            speed_label.text = "SPEED  " + str(int(drive_speed * 3.6)) + " km/h   |   FUEL " + str(int(fuel)) + "%"

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        if is_driving:
            _exit_car()
        else:
            _try_enter_car()

func _setup_environment() -> void:
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.72, 0.78, 0.86)
    env.ambient_light_energy = 0.85
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    $WorldEnvironment.environment = env

func _build_world() -> void:
    _add_box(Vector3(0, -0.2, 0), Vector3(90, 0.4, 90), Color(0.20, 0.23, 0.25), true)
    # Roads and lane markings
    _add_box(Vector3(0, 0.015, 17), Vector3(90, 0.03, 10), Color(0.10, 0.11, 0.12), false)
    for x in range(-42, 43, 8):
        _add_box(Vector3(x, 0.04, 17), Vector3(4, 0.02, 0.12), Color(0.92, 0.86, 0.55), false)
    # Decorative city blocks
    for i in range(8):
        var x := -35.0 + float(i) * 10.0
        var h := 5.0 + float((i * 7) % 11)
        _add_box(Vector3(x, h / 2.0, -27), Vector3(7, h, 8), Color(0.34 + float(i % 3) * 0.08, 0.38, 0.43), true)
        _add_box(Vector3(x, h / 2.0, 31), Vector3(7, h, 8), Color(0.40, 0.37 + float(i % 2) * 0.08, 0.32), true)

func _build_dealership() -> void:
    _add_box(Vector3(0, 0.08, -5), Vector3(25, 0.16, 20), Color(0.34, 0.36, 0.39), false)
    _add_box(Vector3(0, 3.2, -14.5), Vector3(25, 0.35, 0.5), Color(0.10, 0.12, 0.15), true)
    _add_box(Vector3(-12.2, 1.6, -5), Vector3(0.5, 3.2, 19), Color(0.12, 0.15, 0.18), true)
    _add_box(Vector3(12.2, 1.6, -5), Vector3(0.5, 3.2, 19), Color(0.12, 0.15, 0.18), true)
    var sign := Label3D.new()
    sign.text = "HUSNAIN AUTO DEALERSHIP"
    sign.font_size = 54
    sign.position = Vector3(0, 3.55, -14.15)
    sign.pixel_size = 0.006
    add_child(sign)
    _create_display_car(Vector3(-7, 0.5, -5), Color(0.82, 0.12, 0.10), "Falcon S")
    _create_display_car(Vector3(0, 0.5, -5), Color(0.10, 0.32, 0.82), "Comet LX")
    _create_display_car(Vector3(7, 0.5, -5), Color(0.12, 0.62, 0.32), "Ranger GT")
    _add_box(Vector3(-19, 0.2, 1), Vector3(8, 0.4, 7), Color(0.18, 0.18, 0.20), false)
    var workshop := Label3D.new()
    workshop.text = "WORKSHOP  |  REPAIR & UPGRADE"
    workshop.font_size = 30
    workshop.position = Vector3(-19, 1.4, -2)
    workshop.pixel_size = 0.009
    add_child(workshop)

func _create_display_car(pos: Vector3, color: Color, car_name: String) -> void:
    var root := Node3D.new()
    root.position = pos
    root.name = car_name.replace(" ", "")
    add_child(root)
    _car_meshes(root, color)
    var label := Label3D.new()
    label.text = car_name + "\nE: interact"
    label.font_size = 30
    label.position.y = 1.8
    label.pixel_size = 0.008
    root.add_child(label)

func _build_demo_car() -> void:
    demo_car = CharacterBody3D.new()
    demo_car.name = "PlayerVehicle"
    demo_car.position = Vector3(0, 0.5, 4)
    add_child(demo_car)
    _car_meshes(demo_car, car_paint)
    demo_car.visible = false

func _car_meshes(root: Node3D, color: Color) -> void:
    var body := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = Vector3(2.2, 0.65, 4.2)
    body.mesh = bm
    body.position.y = 0.35
    var paint := StandardMaterial3D.new()
    paint.albedo_color = color
    paint.metallic = 0.55
    paint.roughness = 0.25
    body.material_override = paint
    root.add_child(body)
    var cabin := MeshInstance3D.new()
    var cb := BoxMesh.new()
    cb.size = Vector3(1.65, 0.72, 1.9)
    cabin.mesh = cb
    cabin.position = Vector3(0, 1.0, -0.25)
    var glass := StandardMaterial3D.new()
    glass.albedo_color = Color(0.04, 0.10, 0.15)
    glass.metallic = 0.3
    cabin.material_override = glass
    root.add_child(cabin)
    for x in [-1.12, 1.12]:
        for z in [-1.3, 1.3]:
            var wheel := MeshInstance3D.new()
            var cyl := CylinderMesh.new()
            cyl.top_radius = 0.38
            cyl.bottom_radius = 0.38
            cyl.height = 0.24
            wheel.mesh = cyl
            wheel.rotation_degrees.z = 90
            wheel.position = Vector3(x, 0.0, z)
            var rubber := StandardMaterial3D.new()
            rubber.albedo_color = Color(0.018, 0.018, 0.02)
            wheel.material_override = rubber
            root.add_child(wheel)

func _add_box(pos: Vector3, size: Vector3, color: Color, solid: bool) -> void:
    var node: Node3D = StaticBody3D.new() if solid else Node3D.new()
    node.position = pos
    add_child(node)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    mesh.material_override = material
    node.add_child(mesh)
    if solid:
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        node.add_child(collision)

func _build_hud() -> void:
    hud = $CanvasLayer
    panel = PanelContainer.new()
    panel.position = Vector2(16, 16)
    panel.custom_minimum_size = Vector2(310, 150)
    hud.add_child(panel)
    var v := VBoxContainer.new()
    panel.add_child(v)
    var heading := Label.new()
    heading.text = "CAR FOR SALE SIMULATOR"
    heading.add_theme_font_size_override("font_size", 19)
    v.add_child(heading)
    cash_label = Label.new()
    v.add_child(cash_label)
    status_label = Label.new()
    v.add_child(status_label)
    message_label = Label.new()
    message_label.position = Vector2(350, 25)
    message_label.add_theme_font_size_override("font_size", 20)
    hud.add_child(message_label)
    speed_label = Label.new()
    speed_label.position = Vector2(950, 22)
    speed_label.add_theme_font_size_override("font_size", 19)
    hud.add_child(speed_label)
    _button("BUY CAR  $8,000", Vector2(16, 180), Vector2(300, 48), _buy_car)
    _button("ENTER / EXIT  (E)", Vector2(16, 235), Vector2(300, 48), _toggle_vehicle)
    _button("WORKSHOP  $1,500", Vector2(16, 290), Vector2(300, 48), _repair_car)
    _button("PAINT SHOP  $700", Vector2(16, 345), Vector2(300, 48), _paint_car)
    _button("AI CUSTOMER", Vector2(16, 400), Vector2(300, 48), _serve_customer)
    _button("SELL CAR  +$11,000", Vector2(16, 455), Vector2(300, 48), _sell_car)
    _button("NEXT DAY / MISSION", Vector2(16, 510), Vector2(300, 48), _next_day)
    _button("SAVE GAME", Vector2(16, 565), Vector2(145, 48), _save_game)
    _button("LOAD GAME", Vector2(171, 565), Vector2(145, 48), _load_game)
    var controls := Label.new()
    controls.text = "WASD: Move/Drive   E: Enter/Exit   Shift: Run   Touch buttons available"
    controls.position = Vector2(18, 675)
    controls.add_theme_font_size_override("font_size", 16)
    hud.add_child(controls)
    _button("▲", Vector2(1080, 535), Vector2(90, 75), func(): Input.action_press("move_forward"))
    _button("◀", Vector2(980, 610), Vector2(85, 75), func(): Input.action_press("move_left"))
    _button("▼", Vector2(1080, 610), Vector2(85, 75), func(): Input.action_press("move_back"))
    _button("▶", Vector2(1180, 610), Vector2(85, 75), func(): Input.action_press("move_right"))
    _refresh_hud()

func _button(caption: String, pos: Vector2, size: Vector2, callback: Callable) -> void:
    var b := Button.new()
    b.text = caption
    b.position = pos
    b.custom_minimum_size = size
    b.pressed.connect(callback)
    hud.add_child(b)

func _refresh_hud() -> void:
    if is_instance_valid(cash_label):
        cash_label.text = "Cash: $" + str(cash) + "   |   Day: " + str(day)
    if is_instance_valid(status_label):
        status_label.text = "Cars: " + str(owned_cars.size()) + "   |   Reputation: " + str(reputation) + "/100"
    if is_instance_valid(speed_label) and not is_driving:
        speed_label.text = "DEALERSHIP MODE"

func _message(text: String) -> void:
    if is_instance_valid(message_label):
        message_label.text = text

func _buy_car() -> void:
    if cash < CAR_PRICE:
        _message("Not enough cash to buy this vehicle.")
        return
    cash -= CAR_PRICE
    owned_cars.append("Falcon S")
    selected_car = "Falcon S"
    _message("Purchased Falcon S! You can now test drive and sell it.")
    _refresh_hud()

func _try_enter_car() -> void:
    if owned_cars.is_empty():
        _message("Buy a car first.")
        return
    _enter_car()

func _toggle_vehicle() -> void:
    if is_driving:
        _exit_car()
    else:
        _try_enter_car()

func _enter_car() -> void:
    is_driving = true
    demo_car.visible = true
    demo_car.position = player.position
    player.visible = false
    player.can_move = false
    $Player/CameraPivot/Camera3D.position = Vector3(0, 3.0, 8)
    $Player/CameraPivot/Camera3D.rotation_degrees = Vector3(-12, 0, 0)
    _message("Test drive! W accelerates, S brakes, A/D steer. E exits.")
    _refresh_hud()

func _exit_car() -> void:
    is_driving = false
    drive_speed = 0.0
    demo_car.visible = false
    player.visible = true
    player.can_move = true
    player.position = demo_car.position + Vector3(3, 0, 0)
    _message("Exited vehicle.")
    _refresh_hud()

func _repair_car() -> void:
    if cash < 1500:
        _message("Workshop service costs $1,500.")
        return
    cash -= 1500
    engine_health = 100.0
    fuel = 100.0
    reputation = min(100, reputation + 3)
    _message("Workshop complete: engine serviced and fuel refilled.")
    _refresh_hud()

func _paint_car() -> void:
    if cash < 700:
        _message("Paint service costs $700.")
        return
    cash -= 700
    var colors := [Color(0.85, 0.08, 0.08), Color(0.08, 0.25, 0.85), Color(0.08, 0.65, 0.28), Color(0.85, 0.65, 0.08)]
    car_paint = colors[randi() % colors.size()]
    _message("New paint selected! Visual paint customization is a prototype feature.")
    _refresh_hud()

func _serve_customer() -> void:
    if owned_cars.is_empty():
        _message("A customer wants to buy a car. Purchase inventory first.")
        return
    var offer := 9500 + randi_range(0, 3000)
    _message("AI customer offer: $" + str(offer) + ". Use SELL CAR to accept the demo sale.")
    reputation = min(100, reputation + 2)
    _refresh_hud()

func _sell_car() -> void:
    if owned_cars.is_empty():
        _message("No cars in inventory to sell.")
        return
    owned_cars.pop_back()
    cash += 11000
    reputation = min(100, reputation + 5)
    _message("Vehicle sold for $11,000. Dealership reputation increased!")
    _refresh_hud()

func _next_day() -> void:
    day += 1
    cash += 500
    reputation = min(100, reputation + 1)
    _message("New day! Daily operating costs and mission system will expand in later updates.")
    _refresh_hud()

func _save_game() -> void:
    var data := {"cash": cash, "cars": owned_cars, "reputation": reputation, "day": day}
    var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        _message("Game saved on this device.")
    else:
        _message("Save failed.")

func _load_game() -> void:
    if not FileAccess.file_exists("user://savegame.json"):
        _message("No saved game found yet.")
        return
    var file := FileAccess.open("user://savegame.json", FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) == TYPE_DICTIONARY:
        cash = int(parsed.get("cash", START_CASH))
        owned_cars.assign(parsed.get("cars", []))
        reputation = int(parsed.get("reputation", 10))
        day = int(parsed.get("day", 1))
        _message("Saved game loaded.")
        _refresh_hud()
