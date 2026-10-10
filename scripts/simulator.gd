extends Control

const SupabaseConfig = preload("res://scripts/supabase_config.gd")

const BG := Color("#0b0e14")
const SURFACE := Color("#121722")
const SURFACE_ALT := Color("#1a2230")
const BORDER := Color("#303b4e")
const TEXT_COLOR := Color("#edf2fa")
const MUTED := Color("#b1bdd0")
const ACCENT := Color("#a9b8ff")
const TEAL := Color("#7ce0d0")
const GREEN := Color("#8cdda6")
const YELLOW := Color("#f3ce7a")
const ORANGE := Color("#f3a77f")
const RED := Color("#ff8eaa")
const LAVENDER := Color("#c5a5ff")

class FlowCanvas extends Control:
	var nodes_data: Array = []
	var caption := ""
	const INK := Color("#edf2fa")
	const ACCENT := Color("#a9b8ff")
	const SUBTLE := Color("#8793aa")
	const LINE := Color("#56647b")

	func set_graph(data: Array, title_text: String) -> void:
		nodes_data = data
		caption = title_text
		queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#0e131d"), true)
		var gx := 0.0
		while gx < size.x:
			draw_line(Vector2(gx, 0), Vector2(gx, size.y), Color(0.52, 0.60, 0.75, 0.10), 1.0)
			gx += 28.0
		var gy := 0.0
		while gy < size.y:
			draw_line(Vector2(0, gy), Vector2(size.x, gy), Color(0.42, 0.43, 0.55, 0.13), 1.0)
			gy += 28.0
		if nodes_data.is_empty():
			draw_string(ThemeDB.fallback_font, Vector2(22, size.y * 0.52), "Selecciona una entidad para inspeccionar sus relaciones.", HORIZONTAL_ALIGNMENT_LEFT, size.x - 44, 14, INK)
			return

		var visual_type := str(nodes_data[0].get("visual_type", ""))
		if visual_type == "particula":
			_draw_particula(nodes_data[0])
			return
		if visual_type == "ium":
			_draw_ium(nodes_data[0])
			return
		if visual_type == "oris":
			_draw_oris(nodes_data[0])
			return

		var count := nodes_data.size()
		var gap := 14.0
		var margin_x := 18.0
		var usable := size.x - margin_x * 2.0 - gap * float(count - 1)
		var box_width := maxf(82.0, usable / float(count))
		if box_width > 178.0:
			box_width = 178.0
		var full_width := box_width * float(count) + gap * float(count - 1)
		var start_x := maxf(margin_x, (size.x - full_width) * 0.5)
		var box_height := 144.0
		var start_y := maxf(52.0, (size.y - box_height) * 0.5)

		for index in range(count):
			var data: Dictionary = nodes_data[index]
			var px := start_x + float(index) * (box_width + gap)
			var rect := Rect2(Vector2(px, start_y), Vector2(box_width, box_height))
			var tint: Color = data.get("color", ACCENT)
			if index < count - 1:
				var y_mid := start_y + box_height * 0.51
				var x1 := rect.end.x + 2.0
				var x2 := px + box_width + gap - 3.0
				draw_line(Vector2(x1, y_mid), Vector2(x2, y_mid), LINE, 2.0, true)
				draw_colored_polygon(PackedVector2Array([
					Vector2(x2, y_mid),
					Vector2(x2 - 7.0, y_mid - 4.0),
					Vector2(x2 - 7.0, y_mid + 4.0)
				]), LINE)

			draw_rect(rect, Color("#151c28"), true)
			draw_rect(rect, tint, false, 1.4)
			draw_rect(Rect2(rect.position, Vector2(box_width, 4.0)), tint, true)
			draw_string(ThemeDB.fallback_font, Vector2(px + 9, start_y + 25), _short(str(data.get("role", "ETAPA")), 17).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, box_width - 18, 10, tint)
			draw_multiline_string(ThemeDB.fallback_font, Vector2(px + 9, start_y + 51), _wrap(_short(str(data.get("title", "Nodo")), 34), 18), HORIZONTAL_ALIGNMENT_LEFT, box_width - 18, 14, -1, INK)
			draw_multiline_string(ThemeDB.fallback_font, Vector2(px + 9, start_y + 86), _wrap(_short(str(data.get("detail", "")), 96), 22), HORIZONTAL_ALIGNMENT_LEFT, box_width - 18, 11, -1, Color("#c5d0e3"))

	func _draw_particula(data: Dictionary) -> void:
		var formula := str(data.get("formula", "")).to_upper()
		var letters: Array[String] = []
		for i in range(formula.length()):
			var letter := formula.substr(i, 1)
			if letter in ["A", "T", "S", "I"]:
				letters.append(letter)
		var radius := minf(size.x, size.y) * 0.29
		var center := Vector2(size.x * 0.5, size.y * 0.46)
		var palette := {
			"A": [Color("#353d59"), Color("#6576a8"), Color("#e3e9ff")],
			"T": [Color("#29344d"), Color("#52658f"), Color("#d8e2ff")],
			"S": [Color("#202738"), Color("#414f73"), Color("#c8d4f4")],
			"I": [Color("#252b43"), Color("#4b5b88"), Color("#d3dcff")]
		}
		if letters.size() <= 1:
			var letter := letters[0] if not letters.is_empty() else ""
			var colors: Array = palette.get(letter, [Color("#171e2a"), Color("#56647b"), INK])
			draw_circle(center, radius, colors[0])
			draw_arc(center, radius, 0.0, TAU, 64, colors[1], maxf(1.2, radius * 0.05), true)
			if not letter.is_empty():
				draw_string(ThemeDB.fallback_font, center + Vector2(-radius * 0.18, radius * 0.15), letter, HORIZONTAL_ALIGNMENT_CENTER, radius * 0.36, int(radius * 0.48), colors[2])
		else:
			for i in range(letters.size()):
				var a0 := -PI / 2.0 + float(i) * TAU / 3.0
				var a1 := a0 + TAU / 3.0
				var polygon := PackedVector2Array([center])
				for step in range(17):
					var a := lerpf(a0, a1, float(step) / 16.0)
					polygon.append(center + Vector2(cos(a), sin(a)) * radius)
				draw_colored_polygon(polygon, palette[letters[i]][0])
				draw_arc(center, radius, a0, a1, 24, palette[letters[i]][1], maxf(1.2, radius * 0.05), true)
				var mid := (a0 + a1) * 0.5
				var label_pos := center + Vector2(cos(mid), sin(mid)) * radius * 0.58
				draw_string(ThemeDB.fallback_font, label_pos + Vector2(-5, 5), letters[i], HORIZONTAL_ALIGNMENT_CENTER, 10, int(radius * 0.38), palette[letters[i]][2])
		draw_string(ThemeDB.fallback_font, Vector2(16, size.y - 28), str(data.get("title", "Partícula")), HORIZONTAL_ALIGNMENT_LEFT, size.x - 32, 17, INK)
		draw_string(ThemeDB.fallback_font, Vector2(16, size.y - 9), formula, HORIZONTAL_ALIGNMENT_LEFT, size.x - 32, 12, ACCENT)

	func _draw_ium(data: Dictionary) -> void:
		var center := Vector2(size.x * 0.5, size.y * 0.48)
		var radius := minf(size.x * 0.31, size.y * 0.39)
		var particles: Array = data.get("particles", [])
		var geometry := str(data.get("geometry", "radial"))
		var count := particles.size()
		var points: Array[Vector2] = []
		var particle_radius := radius * 0.23
		for i in range(count):
			var t := float(i) / float(maxi(1, count - 1))
			var p := center
			match geometry:
				"puntual":
					var a := -PI / 2.0 + float(i) * TAU / float(maxi(1, count))
					p = center + Vector2(cos(a), sin(a)) * radius * 0.22
					particle_radius = radius * (0.25 if count <= 3 else 0.19)
				"lineal":
					p = center + Vector2((t - 0.5) * radius * 1.5, 0)
					particle_radius = minf(radius * 0.27, radius * 0.75 / float(maxi(1, count - 1)))
				"flexible":
					p = center + Vector2((t - 0.5) * radius * 1.55, -sin(t * TAU) * radius * 0.28)
					particle_radius = minf(radius * 0.26, radius * 0.78 / float(maxi(1, count - 1)))
				"angular":
					p = center + Vector2((t - 0.5) * radius * 1.55, radius * 0.48 - (1.0 - absf(2.0 * t - 1.0)) * radius)
					particle_radius = minf(radius * 0.27, radius * 0.78 / float(maxi(1, count - 1)))
				_:
					var a := -PI / 2.0 + float(i) * TAU / float(maxi(1, count))
					var orbit := radius * (0.58 if geometry == "red" else 0.66)
					p = center + Vector2(cos(a), sin(a)) * orbit
					particle_radius = minf(radius * 0.24, orbit * sin(PI / float(maxi(1, count))) * 0.9)
			points.append(p)
		# Armazón geométrico bajo las partículas.
		var frame_color := Color("#7286bf")
		match geometry:
			"puntual":
				draw_arc(center, radius * 0.9, 0.0, TAU, 64, Color("#7286bf", 0.45), 1.2, true)
			"lineal":
				if points.size() > 1:
					draw_line(points[0], points[points.size() - 1], frame_color, 2.0, true)
			"red":
				for i in range(points.size()):
					for j in range(i + 1, points.size()):
						draw_line(points[i], points[j], Color("#7286bf", 0.65), 1.2, true)
			"radial":
				draw_arc(center, radius * 0.66, 0.0, TAU, 64, Color("#7286bf", 0.75), 1.3, true)
				for p in points:
					draw_line(center, p, Color("#7286bf", 0.65), 1.0, true)
			"flexible", "angular":
				for i in range(points.size() - 1):
					draw_line(points[i], points[i + 1], frame_color, 1.7, true)
		for i in range(count):
			var item: Dictionary = particles[i]
			var formula := str(item.get("formula", ""))
			var letters: Array[String] = []
			for j in range(formula.length()):
				var letter := formula.substr(j, 1).to_upper()
				if letter in ["A", "T", "S", "I"]:
					letters.append(letter)
			var p := points[i]
			var r := maxf(5.0, particle_radius)
			if letters.size() >= 3:
				for k in range(3):
					var a0 := -PI / 2.0 + float(k) * TAU / 3.0
					var poly := PackedVector2Array([p])
					for step in range(9):
						var a := a0 + float(step) / 8.0 * TAU / 3.0
						poly.append(p + Vector2(cos(a), sin(a)) * r)
					draw_colored_polygon(poly, Color("#353d59") if letters[k] == "A" else (Color("#29344d") if letters[k] == "T" else (Color("#202738") if letters[k] == "S" else Color("#252b43"))))
			else:
				draw_circle(p, r, Color("#353d59"))
			draw_arc(p, r, 0.0, TAU, 24, Color("#9baeff"), 1.0, true)
		draw_string(ThemeDB.fallback_font, Vector2(16, size.y - 28), str(data.get("title", "IUM")), HORIZONTAL_ALIGNMENT_LEFT, size.x - 32, 17, INK)
		draw_string(ThemeDB.fallback_font, Vector2(16, size.y - 9), geometry.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, size.x - 32, 12, ACCENT)

	func _draw_oris(data: Dictionary) -> void:
		var topology_id := str(data.get("topology_id", ""))
		var topology := str(data.get("topology", "Topología"))
		var graph_nodes: Array = data.get("oris_nodes", [])
		var unions: Array = data.get("oris_unions", [])
		var center := Vector2(size.x * 0.5, size.y * 0.48)
		var w := minf(size.x - 48.0, 520.0)
		var h := minf(size.y - 72.0, 300.0)
		var left := (size.x - w) * 0.5
		var top := maxf(26.0, (size.y - h) * 0.5)
		var pos := {}
		match topology_id:
			"T01":
				pos = {"nucleo": Vector2(left + w * 0.72, top + h * 0.5), "a": Vector2(left + w * 0.28, top + h * 0.27), "b": Vector2(left + w * 0.28, top + h * 0.73)}
			"T02":
				pos = {"a": Vector2(left + w * 0.12, top + h * 0.2), "nucleo": Vector2(left + w * 0.5, top + h * 0.2), "b": Vector2(left + w * 0.88, top + h * 0.2), "d": Vector2(left + w * 0.88, top + h * 0.8), "c": Vector2(left + w * 0.5, top + h * 0.8)}
			"T03":
				pos = {"a": Vector2(left + w * 0.12, top + h * 0.5), "nucleo": Vector2(left + w * 0.42, top + h * 0.5), "b": Vector2(left + w * 0.78, top + h * 0.22), "c": Vector2(left + w * 0.68, top + h * 0.75), "d": Vector2(left + w * 0.9, top + h * 0.48)}
			"T04", "T07":
				pos = {"a": Vector2(left + w * 0.2, top + h * 0.2), "b": Vector2(left + w * 0.63, top + h * 0.2), "nucleo": Vector2(left + w * 0.63, top + h * 0.8), "c": Vector2(left + w * 0.2, top + h * 0.8), "d": Vector2(left + w * 0.9, top + h * 0.8)}
			"T05":
				pos = {"a": Vector2(left + w * 0.3, top + h * 0.22), "b": Vector2(left + w * 0.7, top + h * 0.22), "nucleo": Vector2(left + w * 0.5, top + h * 0.5), "c": Vector2(left + w * 0.5, top + h * 0.82)}
			"T06":
				pos = {"a": Vector2(left + w * 0.15, top + h * 0.22), "b": Vector2(left + w * 0.15, top + h * 0.78), "nucleo": Vector2(left + w * 0.5, top + h * 0.5), "c": Vector2(left + w * 0.85, top + h * 0.5)}
			_:
				pos = {"nucleo": center}
				for i in range(graph_nodes.size()):
					var angle := -PI / 2.0 + float(i) * TAU / float(maxi(1, graph_nodes.size()))
					pos[str(graph_nodes[i].get("posicion", ""))] = center + Vector2(cos(angle), sin(angle)) * minf(w, h) * 0.32
		for union in unions:
			var from_key := str(union.get("origen", ""))
			var to_key := str(union.get("destino", ""))
			if not pos.has(from_key) or not pos.has(to_key):
				continue
			var a: Vector2 = pos[from_key]
			var b: Vector2 = pos[to_key]
			var direction := (b - a).normalized()
			var start := a + direction * 30.0
			var finish := b - direction * 34.0
			var kind := str(union.get("tipo_union", "dirigida"))
			var line_color := Color("#7185bd")
			draw_line(start, finish, line_color, 2.0 if kind == "reciproca" else 1.5, true)
			if kind != "acoplamiento":
				var normal := Vector2(-direction.y, direction.x)
				var tip := finish
				draw_colored_polygon(PackedVector2Array([tip, tip - direction * 9.0 + normal * 4.0, tip - direction * 9.0 - normal * 4.0]), line_color)
			if kind == "reciproca":
				var normal := Vector2(-direction.y, direction.x)
				draw_colored_polygon(PackedVector2Array([start, start + direction * 9.0 + normal * 4.0, start + direction * 9.0 - normal * 4.0]), line_color)
			if kind == "acoplamiento":
				for t in range(1, 8, 2):
					var p := start.lerp(finish, float(t) / 8.0)
					draw_circle(p, 1.8, line_color)
		for node in graph_nodes:
			var key := str(node.get("posicion", ""))
			if not pos.has(key):
				continue
			var p: Vector2 = pos[key]
			var is_core := key == "nucleo"
			var rr := 29.0 if is_core else 24.0
			draw_circle(p, rr + 3.0, Color("#0e131d"))
			draw_circle(p, rr, Color("#1b2435"))
			draw_arc(p, rr, 0.0, TAU, 48, Color("#a9b8ff") if is_core else Color("#6576a8"), 1.6 if is_core else 1.0, true)
			var label := str(node.get("ium", node.get("ium_id", "IUM")))
			draw_string(ThemeDB.fallback_font, p + Vector2(-rr, rr + 15), _short(label, 13), HORIZONTAL_ALIGNMENT_CENTER, rr * 2.0, 10, INK)
		draw_string(ThemeDB.fallback_font, Vector2(12, 18), (topology_id + " · " + topology).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, size.x - 24, 10, ACCENT)

	func _short(value: String, length: int) -> String:
		if value.length() <= length:
			return value
		return value.substr(0, length - 1) + "…"

	func _wrap(value: String, width: int) -> String:
		var words := value.split(" ")
		var lines: Array[String] = []
		var current := ""
		for word in words:
			if current.length() + word.length() + 1 > width and not current.is_empty():
				lines.append(current)
				current = word
			else:
				if not current.is_empty():
					current += " "
				current += word
		if not current.is_empty():
			lines.append(current)
		if lines.size() > 3:
			lines = lines.slice(0, 3)
			lines[2] = _short(lines[2], width)
		return "\n".join(lines)


var catalogs: Dictionary = {}
var relations: Dictionary = {}
var finished: Dictionary = {}
var errors: Dictionary = {}
var selected: Dictionary = {}
var selected_ids: Array[String] = []
var current_mode := "Procesos"
var current_key := "procesos"
var last_rpc: Dictionary = {}
var success_count := 0

var mode_tabs: HBoxContainer
var subnav: HBoxContainer
var catalog_list: VBoxContainer
var catalog_count_label: Label
var search_input: LineEdit
var graph: FlowCanvas
var inspector_content: VBoxContainer
var status_label: Label
var status_dot: ColorRect
var selection_button: Button
var simulate_button: Button
var process_lab_panel: PanelContainer
var process_oris_option: OptionButton
var process_time_model: OptionButton
var process_k_input: SpinBox
var process_duration_input: SpinBox
var process_practice_input: SpinBox
var process_context_input: TextEdit
var process_requirements_label: Label
var process_run_button: Button
var result_panel: PanelContainer
var result_label: Label
var graph_title: Label
var inspector_title: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_set_mode("Procesos")
	_load_catalogues()


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = BG
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 20)
	outer.add_theme_constant_override("margin_right", 20)
	outer.add_theme_constant_override("margin_top", 16)
	outer.add_theme_constant_override("margin_bottom", 16)
	add_child(outer)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	outer.add_child(page)

	mode_tabs = HBoxContainer.new()
	mode_tabs.add_theme_constant_override("separation", 8)
	page.add_child(mode_tabs)
	subnav = HBoxContainer.new()
	subnav.add_theme_constant_override("separation", 8)
	page.add_child(subnav)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(body)

	var left_panel := _panel()
	left_panel.custom_minimum_size = Vector2(270, 0)
	body.add_child(left_panel)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 10)
	left_panel.add_child(_with_margin(left, 14))
	search_input = LineEdit.new()
	search_input.placeholder_text = "Buscar nombre, regla o fórmula…"
	search_input.clear_button_enabled = true
	search_input.add_theme_color_override("font_color", TEXT_COLOR)
	search_input.add_theme_color_override("font_placeholder_color", Color("#6c7086"))
	search_input.add_theme_stylebox_override("normal", _field_style())
	search_input.add_theme_stylebox_override("focus", _field_style(true))
	search_input.add_theme_stylebox_override("read_only", _field_style())
	search_input.text_changed.connect(_on_search_changed)
	left.add_child(search_input)
	catalog_count_label = _label("CARGANDO REGISTROS", 10, MUTED)
	left.add_child(catalog_count_label)

	var list_scroll := ScrollContainer.new()
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(list_scroll)
	catalog_list = VBoxContainer.new()
	catalog_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	catalog_list.add_theme_constant_override("separation", 7)
	list_scroll.add_child(catalog_list)

	selection_button = _button("Incluir en selección", Callable(self, "_toggle_selection"), false)
	selection_button.visible = false
	left.add_child(selection_button)

	var center_panel := _panel()
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center_panel)
	var center := VBoxContainer.new()
	center.add_theme_constant_override("separation", 12)
	center_panel.add_child(_with_margin(center, 14))

	var center_header := HBoxContainer.new()
	center.add_child(center_header)
	var graph_titles := VBoxContainer.new()
	graph_titles.add_theme_constant_override("separation", 2)
	center_header.add_child(graph_titles)
	graph_title = _label("Selecciona una entidad", 19, TEXT_COLOR)
	graph_titles.add_child(graph_title)
	var head_spacer := Control.new()
	head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_header.add_child(head_spacer)

	graph = FlowCanvas.new()
	graph.custom_minimum_size = Vector2(420, 250)
	graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(graph)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	center.add_child(actions)
	simulate_button = _button("Resolver selección", Callable(self, "_run_simulation"), true)
	simulate_button.visible = false
	actions.add_child(simulate_button)

	process_lab_panel = _panel()
	process_lab_panel.visible = false
	center.add_child(process_lab_panel)
	var process_lab_content := VBoxContainer.new()
	process_lab_content.add_theme_constant_override("separation", 9)
	process_lab_panel.add_child(_with_margin(process_lab_content, 9))
	process_lab_content.add_child(_label("DEMANDA DE ETERIUM", 12, TEAL))
	process_requirements_label = _label("", 11, MUTED)
	process_requirements_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	process_lab_content.add_child(process_requirements_label)
	var process_options := HBoxContainer.new()
	process_options.add_theme_constant_override("separation", 7)
	process_lab_content.add_child(process_options)
	var oris_column := VBoxContainer.new()
	oris_column.add_theme_constant_override("separation", 3)
	oris_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	process_options.add_child(oris_column)
	oris_column.add_child(_label("ORIS", 10, MUTED))
	process_oris_option = OptionButton.new()
	process_oris_option.add_theme_stylebox_override("normal", _field_style())
	process_oris_option.add_theme_stylebox_override("hover", _field_style(true))
	process_oris_option.add_theme_stylebox_override("focus", _field_style(true))
	process_oris_option.add_theme_color_override("font_color", TEXT_COLOR)
	process_oris_option.add_theme_font_size_override("font_size", 12)
	oris_column.add_child(process_oris_option)
	var model_column := VBoxContainer.new()
	model_column.add_theme_constant_override("separation", 3)
	model_column.custom_minimum_size.x = 150
	process_options.add_child(model_column)
	model_column.add_child(_label("MODELO TEMPORAL", 9, MUTED))
	process_time_model = OptionButton.new()
	for temporal_model in ["PULSO", "CONSTANTE", "CRECIENTE", "DECRECIENTE"]:
		process_time_model.add_item(temporal_model)
	process_time_model.select(0)
	process_time_model.add_theme_stylebox_override("normal", _field_style())
	process_time_model.add_theme_stylebox_override("hover", _field_style(true))
	process_time_model.add_theme_stylebox_override("focus", _field_style(true))
	process_time_model.add_theme_color_override("font_color", TEXT_COLOR)
	process_time_model.add_theme_font_size_override("font_size", 12)
	model_column.add_child(process_time_model)

	var parameter_row := HBoxContainer.new()
	parameter_row.add_theme_constant_override("separation", 10)
	process_lab_content.add_child(parameter_row)
	process_k_input = _spinbox(0.0, 1000000000.0, 0.1, 0.0)
	process_duration_input = _spinbox(0.0, 1000000000.0, 0.1, 1.0)
	process_practice_input = _spinbox(0.0, 1.0, 0.05, 1.0)
	parameter_row.add_child(_labeled_control("k temporal", process_k_input))
	parameter_row.add_child(_labeled_control("Duración (s)", process_duration_input))
	parameter_row.add_child(_labeled_control("Práctica · 0–1", process_practice_input))

	var context_row := VBoxContainer.new()
	context_row.add_theme_constant_override("separation", 3)
	process_lab_content.add_child(context_row)
	context_row.add_child(_label("CONTEXTO FÍSICO · JSON", 10, MUTED))
	process_context_input = TextEdit.new()
	process_context_input.custom_minimum_size.y = 76
	process_context_input.placeholder_text = "{\"masa_objetivo\": 2, \"temperatura_inicial\": 300}"
	process_context_input.text = "{}"
	process_context_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	process_context_input.add_theme_color_override("font_color", TEXT_COLOR)
	process_context_input.add_theme_stylebox_override("normal", _field_style())
	process_context_input.add_theme_stylebox_override("focus", _field_style(true))
	process_context_input.add_theme_font_size_override("font_size", 13)
	context_row.add_child(process_context_input)
	var process_actions := HBoxContainer.new()
	process_actions.alignment = BoxContainer.ALIGNMENT_END
	process_lab_content.add_child(process_actions)
	process_run_button = _button("Calcular demanda", Callable(self, "_run_process_eterium"), true)
	process_actions.add_child(process_run_button)

	result_panel = _panel()
	result_panel.visible = false
	result_panel.custom_minimum_size.y = 108
	center.add_child(result_panel)
	var result_content := VBoxContainer.new()
	result_content.add_theme_constant_override("separation", 4)
	result_panel.add_child(_with_margin(result_content, 9))
	result_content.add_child(_label("RESULTADO", 11, TEAL))
	result_label = _label("", 12, TEXT_COLOR)
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.custom_minimum_size.y = 50
	result_content.add_child(result_label)

	var right_panel := _panel()
	right_panel.custom_minimum_size = Vector2(300, 0)
	body.add_child(right_panel)
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 7)
	right_panel.add_child(_with_margin(right, 14))
	inspector_title = _label("Registro seleccionado", 17, ACCENT)
	right.add_child(inspector_title)
	var inspector_scroll := ScrollContainer.new()
	inspector_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(inspector_scroll)
	inspector_content = VBoxContainer.new()
	inspector_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector_content.add_theme_constant_override("separation", 9)
	inspector_scroll.add_child(inspector_content)


func _load_catalogues() -> void:
	_get_catalog("procesos", "/rest/v1/procesos?select=id,nombre,tipo,descripcion,entrada,transformacion,salida,conservacion,regla_clave,estado_fundamento,naturaleza_canonica,revision_requerida&order=nombre.asc&limit=500")
	_get_catalog("oris", "/rest/v1/oris?select=id,orden,nombre,familia,formula,dominio,descripcion&order=orden.asc&limit=100")
	_get_catalog("iums", "/rest/v1/iums?select=id,orden,nombre,detalle,extra&order=orden.asc&limit=100")
	_get_catalog("particulas", "/rest/v1/particulas?select=id,orden,nombre,formula,categoria,ejes_fundamentales,capa_canonica,funcion_canonica,efecto_canonico,peso_masa,polaridad_carga,vector_neto&order=orden.asc&limit=100")
	_get_catalog("elementos", "/rest/v1/elementos?select=id,nombre,simbolo,numero_atomico,masa_base,carga_q,estabilidad,rigidez,flexibilidad,dureza,conductividad,transparencia,regimen_estructural,estado_configuracion,perfil_fisico&order=numero_atomico.asc&limit=250")
	_get_catalog("compuestos", "/rest/v1/compuestos?select=id,nombre,simbolo,formula_canonica,masa,carga,estabilidad,rigidez,flexibilidad,dureza,conductividad,transparencia,densidad_real,volumen_real,propiedades_emergentes&order=nombre.asc&limit=250")
	_get_catalog("materiales", "/rest/v1/materiales?select=id,nombre,descripcion,tipo_material,categoria,estado_fisico,material_padre_id,propiedades_calculadas,estado_calculo&order=orden.asc&limit=250")
	_get_catalog("estructuras", "/rest/v1/estructuras?select=id,nombre,tipo,descripcion,escala,explicacion,estado_calculo,propiedades_calculadas&order=nombre.asc&limit=300")
	_get_catalog("objetos", "/rest/v1/items?select=id,nombre,descripcion,estado_fisico,geometria_fisica,propiedades_fisicas,material_id,tipo_objeto_id&order=nombre.asc&limit=250")
	_get_catalog("organismos", "/rest/v1/organismos?select=id,nombre,descripcion,tipo_organismo,nivel_conciencia,propiedades_calculadas,estado_calculo,material_id,organismo_base_id,clado_id&order=orden.asc&limit=250")

	_get_relation("oris_demanda", "/rest/v1/v_oris_demanda_eterium_v2?select=oris_id,nombre,dominio,formula,tareas,n_iums,n_uniones,unidades_organizacion,demanda_eterium_organizacion,unidad_eterium,formula_demanda,modelo&order=orden.asc&limit=100")
	_get_relation("process_oris", "/rest/v1/oris_procesos?select=oris_id,proceso_id,oris(id,nombre,orden)&activo=eq.true&limit=2000")
	_get_relation("process_laws", "/rest/v1/proceso_leyes_cuantitativas_v1?select=id,proceso_id,clave,modelo,formula,magnitudes_requeridas,descripcion,estado&limit=1000")
	_get_relation("process_models", "/rest/v1/proceso_modelos_resolucion_v1?select=id,proceso_id,clave,modo,formula,magnitudes_requeridas,descripcion,estado&limit=1000")
	_get_relation("process_law_variables", "/rest/v1/proceso_ley_variables_v1?select=ley_id,variable_clave,obligatorio,magnitudes_fisicas(clave,nombre,simbolo,dimension)&limit=1500")
	_get_relation("ium_config", "/rest/v1/iums_configuraciones_funcionales?select=ium_id,patron_organizacion,topologia_acoplamiento,regimen_garin,requiere_coherencia_eterium,descripcion,modo_acoplamiento_garin,dependencia_eterium,etapa_eterium&limit=100")
	_get_relation("ium_outputs", "/rest/v1/ium_salidas_funcionales?select=ium_id,clave,nombre,tipo_salida,es_principal,orden&es_principal=eq.true&limit=100")
	_get_relation("ium_particles", "/rest/v1/iums_particulas?select=ium_id,cantidad,particulas(nombre,formula,orden)&limit=300")
	_get_relation("ium_geometry", "/rest/v1/v_iums_geometria_canonica_v1?select=ium_id,geometria,geometria_nombre,geometria_familia,dimensionalidad&limit=200")
	_get_relation("oris_graph", "/rest/v1/v_oris_grafo_canonico?select=oris_id,topologia_id,topologia,nodos,uniones&limit=100")
	_get_relation("element_particles", "/rest/v1/elemento_particulas?select=elemento_id,capa,cantidad,particulas(nombre,orden)&limit=1000")
	_get_relation("compound_elements", "/rest/v1/compuesto_elementos?select=compuesto_id,cantidad,proporcion_molar,rol,orden_estructura,elementos(nombre,simbolo)&limit=1000")
	_get_relation("material_components", "/rest/v1/v_frontend_worldbuilder_material_componentes?select=material_id,material_nombre,componente_tipo,componente_nombre,cantidad,proporcion_min,proporcion_max,unidad,rol,orden&limit=1000")
	_get_relation("structure_composition", "/rest/v1/v_estructura_composicion?select=estructura_id,compuesto,compuesto_id,cantidad,proporcion,rol,orden&limit=1000")
	_get_relation("object_materials", "/rest/v1/item_materiales?select=item_id,cantidad,proporcion,rol,materiales(nombre)&limit=1000")
	_get_relation("object_structures", "/rest/v1/item_estructuras_fisicas?select=item_id,principal,estructuras(nombre,tipo,escala)&limit=1000")
	_get_relation("organism_systems", "/rest/v1/organismo_sistemas?select=organismo_id,proporcion,sistemas(nombre)&limit=500")
	_get_relation("organism_organs", "/rest/v1/organismo_organos?select=organismo_id,rol,cantidad,organos(nombre)&limit=1000")


func _get_catalog(key: String, path: String) -> void:
	_request("catalog:" + key, path, HTTPClient.METHOD_GET, null)


func _get_relation(key: String, path: String) -> void:
	_request("relation:" + key, path, HTTPClient.METHOD_GET, null)


func _request(tag: String, path: String, method: int, payload: Variant) -> void:
	var req := HTTPRequest.new()
	req.timeout = 20.0
	req.use_threads = true
	add_child(req)
	req.request_completed.connect(_on_request_completed.bind(tag, req), CONNECT_ONE_SHOT)
	var headers := PackedStringArray([
		"apikey: " + SupabaseConfig.PUBLISHABLE_KEY,
		"Accept: application/json"
	])
	var body := ""
	if payload != null:
		headers.append("Content-Type: application/json")
		body = JSON.stringify(payload)
	var code := req.request(SupabaseConfig.PROJECT_URL + path, headers, method, body)
	if code != OK:
		req.queue_free()
		_handle_response(tag, false, {}, "No se pudo iniciar la petición: " + error_string(code))


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, tag: String, req: HTTPRequest) -> void:
	req.queue_free()
	var data: Variant = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		_handle_response(tag, false, {}, "Error de red: " + str(result))
		return
	if response_code < 200 or response_code >= 300:
		var message := "HTTP " + str(response_code)
		if data is Dictionary:
			message = str(data.get("message", data.get("details", data.get("hint", message))))
		_handle_response(tag, false, data, message)
		return
	_handle_response(tag, true, data, "")


func _handle_response(tag: String, ok: bool, data: Variant, message: String) -> void:
	if tag.begins_with("catalog:"):
		var key := tag.trim_prefix("catalog:")
		finished[key] = true
		if ok and data is Array:
			catalogs[key] = data
			errors.erase(key)
			success_count += 1
		else:
			catalogs[key] = []
			errors[key] = message if not message.is_empty() else "Respuesta no reconocida."
			push_warning("Catálogo " + key + ": " + str(errors[key]))
		_update_status()
		_render_catalog()
		_render_graph()
		_render_inspector()
		return

	if tag.begins_with("relation:"):
		var key := tag.trim_prefix("relation:")
		if ok and data is Array:
			relations[key] = data
			errors.erase("rel:" + key)
		else:
			relations[key] = []
			errors["rel:" + key] = message
			push_warning("Relación " + key + ": " + message)
		_render_graph()
		_render_inspector()
		_refresh_process_oris()
		_refresh_actions()
		return

	if tag.begins_with("rpc:"):
		result_panel.visible = true
		if ok:
			last_rpc = {"tag": tag, "data": data}
			result_label.text = _rpc_summary(data, tag)
			_graph_rpc_result(data, tag)
			inspector_title.text = "Resultado de simulación"
			_render_inspector()
			_set_status("Cálculo completado", GREEN)
		else:
			result_label.text = "El motor rechazó la petición.\n" + message
			_set_status("Error al calcular", RED)
			push_warning("RPC " + tag + ": " + message)


func _update_status() -> void:
	if success_count > 0 and errors.is_empty():
		_set_status("Catálogos cargados", GREEN)
	elif success_count > 0:
		_set_status("Conexión parcial · revisar avisos", ORANGE)
	elif not errors.is_empty():
		_set_status("No se pudieron leer los catálogos", RED)
	else:
		_set_status("Cargando datos…", YELLOW)


func _set_status(message: String, tint: Color) -> void:
	if is_instance_valid(status_label):
		status_label.text = message
		status_label.add_theme_color_override("font_color", tint)
	if is_instance_valid(status_dot):
		status_dot.color = tint


func _reload_catalogues() -> void:
	catalogs.clear()
	relations.clear()
	finished.clear()
	errors.clear()
	success_count = 0
	selected.clear()
	selected_ids.clear()
	last_rpc.clear()
	result_panel.visible = false
	_set_status("Actualizando catálogos…", YELLOW)
	_load_catalogues()


func _set_mode(mode: String) -> void:
	current_mode = mode
	selected.clear()
	selected_ids.clear()
	last_rpc.clear()
	result_panel.visible = false
	match mode:
		"Procesos":
			current_key = "procesos"
		"Oris / IUM":
			current_key = "oris"
		"Materia":
			current_key = "elementos"
		"Objetos":
			current_key = "objetos"
		"Organismos":
			current_key = "organismos"
	_refresh_mode_tabs()
	_refresh_subnav()
	_render_catalog()
	_render_graph()
	_render_inspector()
	_refresh_actions()


func _choose_catalog(key: String) -> void:
	current_key = key
	selected.clear()
	selected_ids.clear()
	last_rpc.clear()
	result_panel.visible = false
	_refresh_subnav()
	_render_catalog()
	_render_graph()
	_render_inspector()
	_refresh_actions()


func _refresh_mode_tabs() -> void:
	_clear(mode_tabs)
	for mode in ["Procesos", "Oris / IUM", "Materia", "Objetos", "Organismos"]:
		mode_tabs.add_child(_button(mode, Callable(self, "_set_mode").bind(mode), current_mode == mode))


func _refresh_subnav() -> void:
	_clear(subnav)
	var options: Array = []
	match current_mode:
		"Oris / IUM":
			options = [
				{"key": "oris", "label": "Oris"},
				{"key": "iums", "label": "IUMs"},
				{"key": "particulas", "label": "Partículas TASI"}
			]
		"Materia":
			options = [
				{"key": "elementos", "label": "Elementos"},
				{"key": "compuestos", "label": "Compuestos"},
				{"key": "materiales", "label": "Materiales"},
				{"key": "estructuras", "label": "Estructuras"}
			]
	if options.is_empty():
		subnav.visible = false
		return
	subnav.visible = true
	for option in options:
		var key: String = option["key"]
		subnav.add_child(_button(option["label"], Callable(self, "_choose_catalog").bind(key), current_key == key))


func _render_catalog() -> void:
	if not is_instance_valid(catalog_list):
		return
	_clear(catalog_list)
	var entries: Array = catalogs.get(current_key, [])
	var query := search_input.text.strip_edges().to_lower() if is_instance_valid(search_input) else ""
	var count := 0
	for item in entries:
		if not item is Dictionary:
			continue
		var name := str(item.get("nombre", item.get("name", "Sin nombre")))
		var searchable := (name + " " + str(item.get("descripcion", "")) + " " + str(item.get("regla_clave", "")) + " " + str(item.get("formula", ""))).to_lower()
		if not query.is_empty() and not searchable.contains(query):
			continue
		count += 1
		var ident := str(item.get("id", ""))
		var active := not selected.is_empty() and str(selected.get("id", "")) == ident
		var included := selected_ids.has(ident)
		var row := _button("", Callable(self, "_on_item_pressed").bind(item), active)
		row.custom_minimum_size = Vector2(0, 72)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var row_margin := MarginContainer.new()
		row_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		row_margin.add_theme_constant_override("margin_left", 12)
		row_margin.add_theme_constant_override("margin_right", 12)
		row_margin.add_theme_constant_override("margin_top", 8)
		row_margin.add_theme_constant_override("margin_bottom", 8)
		row_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(row_margin)
		var row_content := VBoxContainer.new()
		row_content.add_theme_constant_override("separation", 4)
		row_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_margin.add_child(row_content)
		var title_row := HBoxContainer.new()
		title_row.add_theme_constant_override("separation", 6)
		title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_content.add_child(title_row)
		var title_label := _label(name, 13, TEXT_COLOR if active else Color("#e0e7f2"))
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title_row.add_child(title_label)
		if included or active:
			var badge_text := "EN SELECCIÓN" if included else "ACTIVO"
			var badge := _label(badge_text, 10, TEAL if included else ACCENT)
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			title_row.add_child(badge)
		var subtitle := _label(_item_subtitle(item), 11, MUTED)
		subtitle.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_content.add_child(subtitle)
		catalog_list.add_child(row)
	if is_instance_valid(catalog_count_label):
		var total := entries.size()
		if not finished.get(current_key, false):
			catalog_count_label.text = "CARGANDO REGISTROS"
		elif not errors.has(current_key):
			catalog_count_label.text = "%d REGISTROS" % total if query.is_empty() else "%d DE %d COINCIDEN" % [count, total]
		else:
			catalog_count_label.text = "ERROR DE ACCESO"
	if count == 0:
		var message := "Cargando…"
		if finished.get(current_key, false):
			if errors.has(current_key):
				message = "Catálogo inaccesible.\n" + str(errors[current_key])
			elif entries.is_empty() and query.is_empty():
				message = "No hay datos visibles en este catálogo."
			else:
				message = "No hay resultados para este filtro."
		var empty := _label(message, 12, MUTED)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		catalog_list.add_child(empty)
	_refresh_actions()


func _item_subtitle(item: Dictionary) -> String:
	match current_key:
		"procesos":
			return str(item.get("tipo", "proceso")) + " · " + str(item.get("regla_clave", "sin regla"))
		"oris":
			return str(item.get("dominio", item.get("familia", "Oris")))
		"iums":
			return str(item.get("detalle", item.get("extra", "IUM funcional")))
		"particulas":
			return str(item.get("capa_canonica", item.get("categoria", item.get("funcion_canonica", "TASI"))))
		"elementos":
			return str(item.get("simbolo", "—")) + " · Z " + str(item.get("numero_atomico", "—"))
		"compuestos":
			return str(item.get("formula_canonica", item.get("simbolo", "Compuesto")))
		"materiales":
			return str(item.get("tipo_material", item.get("categoria", item.get("estado_fisico", "Material"))))
		"estructuras":
			return str(item.get("tipo", "Estructura")) + " · " + str(item.get("escala", "escala no indicada"))
		"objetos":
			return str(item.get("estado_fisico", "Objeto")) + " · entidad física"
		"organismos":
			return str(item.get("tipo_organismo", "Organismo")) + " · " + str(item.get("nivel_conciencia", ""))
	return ""


func _on_item_pressed(item: Dictionary) -> void:
	selected = item
	last_rpc.clear()
	result_panel.visible = false
	_render_catalog()
	_render_graph()
	_render_inspector()
	_refresh_process_oris()
	_refresh_actions()


func _on_search_changed(_value: String) -> void:
	_render_catalog()


func _toggle_selection() -> void:
	if selected.is_empty():
		return
	var ident := str(selected.get("id", ""))
	if ident.is_empty():
		_show_result("Este registro no tiene un identificador compatible con el motor.")
		return
	if selected_ids.has(ident):
		selected_ids.erase(ident)
	else:
		selected_ids.append(ident)
	last_rpc.clear()
	result_panel.visible = false
	_render_catalog()
	_render_graph()
	_render_inspector()
	_refresh_actions()
	_set_status("%d registro(s) preparados" % selected_ids.size(), ACCENT)


func _refresh_actions() -> void:
	if not is_instance_valid(selection_button) or not is_instance_valid(simulate_button):
		return
	var supports_selection := current_key == "elementos" or current_key == "compuestos" or current_key == "iums"
	selection_button.visible = supports_selection
	if selected.is_empty():
		selection_button.text = "Selecciona un registro"
		selection_button.disabled = true
	else:
		var ident := str(selected.get("id", ""))
		selection_button.disabled = ident.is_empty()
		selection_button.text = ("Quitar de selección" if selected_ids.has(ident) else "Incluir en selección") + " · " + str(selected_ids.size())
	simulate_button.visible = supports_selection
	var required_count := 1 if current_key == "iums" else 2
	simulate_button.disabled = selected_ids.size() < required_count
	if is_instance_valid(process_lab_panel):
		process_lab_panel.visible = current_key == "procesos" and not selected.is_empty()
	if is_instance_valid(process_run_button):
		var oris_metadata: Variant = null
		if process_oris_option.item_count > 0 and process_oris_option.get_selected() >= 0:
			oris_metadata = process_oris_option.get_item_metadata(process_oris_option.get_selected())
		process_run_button.disabled = selected.is_empty() or current_key != "procesos" or oris_metadata == null or str(oris_metadata).is_empty()


func _run_simulation() -> void:
	last_rpc.clear()
	result_panel.visible = false
	_render_graph()
	_render_inspector()
	if current_key == "iums":
		if selected_ids.is_empty():
			_show_result("Incluye al menos un IUM en el montaje.")
			return
		var components: Array[Dictionary] = []
		for index in range(selected_ids.size()):
			components.append({
				"ium_id": selected_ids[index],
				"rol": "componente",
				"posicion": "X",
				"orden": index + 1
			})
		var links: Array[Dictionary] = []
		for index in range(selected_ids.size() - 1):
			links.append({
				"origen": selected_ids[index],
				"destino": selected_ids[index + 1],
				"tipo_union": "dirigida"
			})
		_set_status("Evaluando organización IUM…", YELLOW)
		_request("rpc:ium", "/rest/v1/rpc/simular_organizacion_ium_v1", HTTPClient.METHOD_POST, {
			"p_componentes": components,
			"p_enlaces": links,
			"p_contexto": {"origen": "Simulator", "modo": "experimental_no_persistente"}
		})
		return
	if selected_ids.size() < 2:
		_show_result("Selecciona al menos dos registros.")
		return
	if current_key == "elementos":
		_set_status("Calculando compuesto…", YELLOW)
		_request("rpc:compuesto", "/rest/v1/rpc/simular_compuesto_desde_elementos", HTTPClient.METHOD_POST, {"p_elemento_ids": selected_ids})
	elif current_key == "compuestos":
		_set_status("Calculando material…", YELLOW)
		_request("rpc:material", "/rest/v1/rpc/simular_material_desde_compuestos", HTTPClient.METHOD_POST, {"p_compuesto_ids": selected_ids})


func _run_process_eterium() -> void:
	last_rpc.clear()
	result_panel.visible = false
	_render_graph()
	_render_inspector()
	if selected.is_empty() or current_key != "procesos":
		_show_result("Selecciona un proceso canónico antes de calcular su demanda.")
		return
	if process_oris_option.item_count == 0 or process_oris_option.get_selected() < 0:
		_show_result("Este proceso no tiene un Oris activo disponible para resolver.")
		return
	var selected_oris_metadata: Variant = process_oris_option.get_item_metadata(process_oris_option.get_selected())
	if selected_oris_metadata == null or str(selected_oris_metadata).is_empty():
		_show_result("No se encontró un vínculo canónico activo entre este proceso y un Oris.")
		return
	var context_data: Variant = JSON.parse_string(process_context_input.text)
	if not context_data is Dictionary:
		_show_result("El contexto debe ser un objeto JSON válido. Ejemplo: {\"masa_objetivo\": 2}")
		return
	var oris_id := str(selected_oris_metadata)
	var time_model := process_time_model.get_item_text(process_time_model.get_selected())
	_set_status("Calculando física y demanda de Eterium…", YELLOW)
	_request("rpc:eterium", "/rest/v1/rpc/calcular_requerimiento_eterium_proceso_v1", HTTPClient.METHOD_POST, {
		"p_oris_id": oris_id,
		"p_proceso_id": str(selected.get("id", "")),
		"p_resolucion": context_data,
		"p_contexto": context_data,
		"p_arquetipo_tiempo": time_model,
		"p_k_tiempo": process_k_input.value,
		"p_tiempo": process_duration_input.value,
		"p_factor_practica": process_practice_input.value
	})


func _refresh_process_oris() -> void:
	if not is_instance_valid(process_oris_option):
		return
	process_oris_option.clear()
	if selected.is_empty() or current_key != "procesos":
		process_oris_option.add_item("Selecciona un proceso")
		_update_process_requirements()
		return
	var process_id := str(selected.get("id", ""))
	var seen: Array[String] = []
	for mapping in relations.get("process_oris", []):
		if not mapping is Dictionary or str(mapping.get("proceso_id", "")) != process_id:
			continue
		var oris_id := str(mapping.get("oris_id", ""))
		var oris_value: Variant = mapping.get("oris", {})
		if oris_value is Array and not oris_value.is_empty():
			oris_value = oris_value[0]
		if not oris_value is Dictionary:
			continue
		var oris_name := str(oris_value.get("nombre", "Oris"))
		if oris_id.is_empty() or seen.has(oris_id):
			continue
		seen.append(oris_id)
		process_oris_option.add_item(oris_name)
		process_oris_option.set_item_metadata(process_oris_option.item_count - 1, oris_id)
	if process_oris_option.item_count == 0:
		process_oris_option.add_item("Sin Oris activo vinculado")
	else:
		process_oris_option.select(0)
	_update_process_requirements()
	_refresh_actions()


func _update_process_requirements() -> void:
	if not is_instance_valid(process_requirements_label):
		return
	if selected.is_empty() or current_key != "procesos":
		process_requirements_label.text = "Selecciona un proceso para consultar su ley y magnitudes."
		return
	var requirements: Array[String] = []
	var laws := _related_rows("process_laws", "proceso_id", str(selected.get("id", "")))
	for law in laws:
		var magnitudes: Variant = law.get("magnitudes_requeridas", [])
		var magnitude_names: Array[String] = []
		if magnitudes is Array:
			for magnitude in magnitudes:
				magnitude_names.append(str(magnitude))
		var line := str(law.get("clave", law.get("modelo", "Ley"))) + " · " + str(law.get("formula", "fórmula no indicada"))
		if not magnitude_names.is_empty():
			line += " · Variables: " + ", ".join(magnitude_names)
		requirements.append(line)
	if requirements.is_empty():
		process_requirements_label.text = "No hay una ley cuantitativa disponible para este proceso."
	else:
		process_requirements_label.text = "Magnitudes: " + " | ".join(requirements)


func _show_result(message: String) -> void:
	result_panel.visible = true
	result_label.text = message


func _rpc_summary(data: Variant, tag: String) -> String:
	if not data is Dictionary:
		return str(data)
	var state := str(data.get("estado", "respuesta recibida"))
	var lines: Array[String] = ["Estado: " + state]
	if tag == "rpc:ium":
		lines.append("Salidas: " + _pretty(data.get("salidas", [])))
		var candidates: Array = data.get("procesos_candidatos", [])
		lines.append("Procesos candidatos: " + str(candidates.size()))
		if not str(data.get("proceso_principal", "")).is_empty():
			lines.append("Proceso principal: " + str(data.get("proceso_principal")))
	elif tag == "rpc:eterium":
		lines.append("Eterium estable: " + str(data.get("eterium_estable_requerido", "no resuelto")))
		lines.append("Eterium liberado: " + str(data.get("eterium_liberado_necesario", "no resuelto")))
		lines.append("Demanda física: " + str(data.get("demanda_fisica_eterium", "no resuelta")))
		lines.append("Coste temporal: " + str(data.get("costo_temporal_eterium", "no resuelto")))
		var organization: Variant = data.get("organizacion_proceso", {})
		if organization is Dictionary:
			lines.append("Configuración IUM: " + str(organization.get("configuracion_version", "versión no indicada")) + " · " + str(organization.get("configuracion_estado", "estado no indicado")))
			lines.append("Organización: " + str(organization.get("n_iums", "—")) + " IUM · " + str(organization.get("n_uniones", "—")) + " uniones")
	else:
		var props: Array[String] = []
		for key in ["masa", "carga", "volumen_real", "volumen", "densidad_real", "densidad", "estabilidad", "rigidez", "flexibilidad", "dureza", "conductividad", "transparencia", "interaccion"]:
			if data.has(key):
				props.append(key.replace("_", " ") + ": " + str(data[key]))
		if not props.is_empty():
			lines.append(" · ".join(props))
		if data.has("nota"):
			lines.append(str(data["nota"]))
	return "\n".join(lines)


func _graph_rpc_result(data: Variant, tag: String) -> void:
	var state := "Respuesta recibida"
	var detail := JSON.stringify(data, " ")
	if data is Dictionary:
		state = str(data.get("estado", data.get("status", state)))
	var nodes: Array = []
	if tag == "rpc:ium" and data is Dictionary:
		var components: Array = data.get("componentes", [])
		for index in range(mini(components.size(), 2)):
			var component: Dictionary = components[index]
			nodes.append({"role": "IUM " + str(index + 1), "title": str(component.get("ium", component.get("ium_id", "IUM"))), "detail": "Salida: " + str(component.get("salida_funcional", "sin salida resuelta")), "color": LAVENDER})
		if components.size() > 2:
			nodes.append({"role": "MONTAJE", "title": "+" + str(components.size() - 2) + " IUMs", "detail": "Componentes adicionales del montaje", "color": ACCENT})
		var candidates: Array = data.get("procesos_candidatos", [])
		var candidate_names: Array[String] = []
		for candidate in candidates.slice(0, 3):
			if candidate is Dictionary:
				candidate_names.append(str(candidate.get("proceso", "Proceso")))
		var candidate_summary := ", ".join(candidate_names) if not candidate_names.is_empty() else "Sin patrón completo coincidente"
		nodes.append({"role": "RESOLUCIÓN", "title": str(data.get("proceso_principal", state)), "detail": candidate_summary, "color": GREEN if state == "simulado" else YELLOW})
		graph.set_graph(nodes, "ORGANIZACIÓN IUM · EVALUACIÓN NO PERSISTENTE")
		return
	if tag == "rpc:eterium" and data is Dictionary:
		var org_cost := str(data.get("organizacion_proceso_eterium", "no resuelto"))
		var physical_cost := str(data.get("demanda_fisica_eterium", "no resuelto"))
		var temporal_cost := str(data.get("costo_temporal_eterium", "no resuelto"))
		var organization: Variant = data.get("organizacion_proceso", {})
		var config_state := ""
		var config_label := "Configuración de acoplamiento"
		if organization is Dictionary:
			config_state = str(organization.get("configuracion_estado", ""))
			config_label = str(organization.get("configuracion_version", "versión no indicada")) + " · " + config_state
		var result_tint: Color = GREEN if state == "calculado" else YELLOW
		if not config_state.is_empty() and not ["canonico", "canonico_formal", "validada", "vigente"].has(config_state):
			result_tint = YELLOW
		nodes = [
			{"role": "ORIS", "title": str(data.get("oris", "Oris")), "detail": config_label, "color": YELLOW if config_state == "propuesta" else LAVENDER},
			{"role": "PROCESO", "title": str(data.get("proceso", "Proceso")), "detail": "Ley cuantitativa y contexto físico", "color": ACCENT},
			{"role": "FÍSICA", "title": "Demanda física", "detail": physical_cost + " Eterium", "color": TEAL},
			{"role": "COSTE", "title": "Eterium estable", "detail": org_cost + " org. + " + temporal_cost + " temporal", "color": ORANGE},
			{"role": "RESULTADO", "title": state, "detail": "Liberación: " + str(data.get("eterium_liberado_necesario", "no resuelta")), "color": result_tint}
		]
		graph.set_graph(nodes, "ORIS · LEY FÍSICA · DEMANDA DE ETERIUM")
		return
	var title := "Formar compuesto" if tag == "rpc:compuesto" else "Formar material"
	nodes = [
		{"role": "ENTRADA", "title": str(selected_ids.size()) + " entidades", "detail": "Selección del catálogo canónico", "color": TEAL},
		{"role": "RPC EXISTENTE", "title": title, "detail": "Resolución delegada a PostgreSQL", "color": ACCENT},
		{"role": "RESULTADO", "title": state, "detail": detail.substr(0, 100), "color": GREEN if state.to_lower().contains("calcul") or state.to_lower().contains("simulad") else YELLOW}
	]
	graph.set_graph(nodes, "EJECUCIÓN REAL · RESPUESTA DE SUPABASE")


func _render_graph() -> void:
	if not is_instance_valid(graph):
		return
	if not last_rpc.is_empty():
		_graph_rpc_result(last_rpc.get("data", {}), str(last_rpc.get("tag", "")))
		return
	if current_key == "iums" and not selected_ids.is_empty():
		graph_title.text = "Montaje IUM · " + str(selected_ids.size()) + " componente(s)"
		var preview_nodes: Array = []
		var display_count := mini(selected_ids.size(), 2)
		for index in range(display_count):
			var ium_id := selected_ids[index]
			var ium_name := ium_id
			for ium_row in catalogs.get("iums", []):
				if ium_row is Dictionary and str(ium_row.get("id", "")) == ium_id:
					ium_name = str(ium_row.get("nombre", ium_id))
					break
			var output_row: Dictionary = _related_row("ium_outputs", "ium_id", ium_id)
			var output_name := str(output_row.get("nombre", output_row.get("clave", "Salida principal pendiente")))
			preview_nodes.append({"role": "IUM " + str(index + 1), "title": ium_name, "detail": "Salida: " + output_name, "color": LAVENDER})
		if selected_ids.size() > 2:
			preview_nodes.append({"role": "OTROS IUMS", "title": "+" + str(selected_ids.size() - 2), "detail": "Más IUMs incluidos en este orden", "color": ACCENT})
		preview_nodes.append({"role": "MONTAJE", "title": "Listo para evaluar", "detail": str(selected_ids.size()) + " IUM · " + str(maxi(0, selected_ids.size() - 1)) + " unión(es) dirigida(s)", "color": TEAL})
		graph.set_graph(preview_nodes, "VISTA PREVIA · CONFIGURACIÓN EXPERIMENTAL")
		return
	if selected.is_empty():
		graph_title.text = "Selecciona una entidad"
		graph.set_graph([
			{"role": "CAPA", "title": "Procesos", "detail": "Entradas y transformaciones", "color": ACCENT},
			{"role": "ACOPLAMIENTO", "title": "Oris / IUMs", "detail": "Organización funcional", "color": LAVENDER},
			{"role": "MATERIA", "title": "Elementos y compuestos", "detail": "Propiedades y estructura", "color": ORANGE},
			{"role": "SISTEMA", "title": "Objetos / organismos", "detail": "Arquitectura material y biológica", "color": GREEN}
		], "VISTA GENERAL DEL LABORATORIO")
		return

	graph_title.text = str(selected.get("nombre", "Entidad"))
	var nodes: Array = []
	match current_key:
		"procesos":
			var process_id := str(selected.get("id", ""))
			var laws := _related_rows("process_laws", "proceso_id", process_id)
			var models := _related_rows("process_models", "proceso_id", process_id)
			var law_title := "Sin ley vinculada"
			var law_detail := "No hay ley cuantitativa registrada para este proceso"
			if not laws.is_empty():
				law_title = str(laws[0].get("clave", laws[0].get("modelo", "Ley registrada")))
				law_detail = str(laws[0].get("formula", laws[0].get("descripcion", "Ley registrada")))
			if not models.is_empty():
				law_detail += "\nResolución: " + str(models[0].get("modo", models[0].get("clave", "modelo registrado")))
			nodes = [
				{"role": "ENTRADA", "title": "Entrada", "detail": str(selected.get("entrada", "No descrita en el registro")), "color": TEAL},
				{"role": "LEY", "title": law_title, "detail": law_detail, "color": LAVENDER},
				{"role": "TRANSFORMACIÓN", "title": str(selected.get("nombre", "Proceso")), "detail": str(selected.get("transformacion", selected.get("descripcion", "Sin descripción"))), "color": ACCENT},
				{"role": "SALIDA", "title": "Salida", "detail": str(selected.get("salida", "No descrita en el registro")), "color": GREEN}
			]
		"oris":
			var canonical_graph := _related_row("oris_graph", "oris_id", str(selected.get("id", "")))
			if not canonical_graph.is_empty() and canonical_graph.get("nodos", []) is Array:
				graph.set_graph([{
					"visual_type": "oris",
					"title": str(selected.get("nombre", "Oris")),
					"topology_id": str(canonical_graph.get("topologia_id", "")),
					"topology": str(canonical_graph.get("topologia", "")),
					"oris_nodes": canonical_graph.get("nodos", []),
					"oris_unions": canonical_graph.get("uniones", [])
				}], "")
				return
			var demand := _related_row("oris_demanda", "oris_id", str(selected.get("id", "")))
			var demand_text := "Demanda estructural no disponible"
			if not demand.is_empty():
				demand_text = str(demand.get("demanda_eterium_organizacion", "—")) + " " + str(demand.get("unidad_eterium", ""))
			nodes = [
				{"role": "SELECCIÓN", "title": "Eterium", "detail": "Selecciona y dirige el IUM", "color": LAVENDER},
				{"role": "ORIS", "title": str(selected.get("nombre", "Oris")), "detail": str(selected.get("dominio", "Dominio funcional")), "color": ACCENT},
				{"role": "IUMS", "title": "Configuración", "detail": str(selected.get("formula", "Fórmula no indicada")), "color": TEAL},
				{"role": "DEMANDA", "title": "Organización", "detail": demand_text, "color": ORANGE},
				{"role": "EJECUCIÓN", "title": "Garin", "detail": "Infraestructura espacial de ejecución", "color": LAVENDER}
			]
		"iums":
			var ium_id := str(selected.get("id", ""))
			var particle_visuals: Array[Dictionary] = []
			for row in _related_rows("ium_particles", "ium_id", ium_id):
				var nested: Variant = row.get("particulas", {})
				if nested is Array and not nested.is_empty():
					nested = nested[0]
				if nested is Dictionary:
					var amount := mini(12, maxi(1, int(row.get("cantidad", 1))))
					for particle_index in range(amount):
						particle_visuals.append({"nombre": str(nested.get("nombre", "Partícula")), "formula": str(nested.get("formula", ""))})
			var geometry_row := _related_row("ium_geometry", "ium_id", ium_id)
			var geometry_name := str(geometry_row.get("geometria", "radial"))
			graph.set_graph([{
				"visual_type": "ium",
				"title": str(selected.get("nombre", "IUM")),
				"particles": particle_visuals,
				"geometry": geometry_name
			}], "")
			var part_text := _related_text("ium_particles", "ium_id", "nombre", "particulas", ium_id)
			var conf := _related_row("ium_config", "ium_id", str(selected.get("id", "")))
			nodes = [
				{"role": "PARTÍCULAS", "title": str(selected.get("nombre", "IUM")), "detail": part_text if not part_text.is_empty() else str(selected.get("detalle", "Composición no disponible")), "color": LAVENDER},
				{"role": "ORGANIZACIÓN", "title": str(conf.get("patron_organizacion", "Patrón funcional")), "detail": str(conf.get("topologia_acoplamiento", "Topología no indicada")), "color": ACCENT},
				{"role": "GARIN", "title": str(conf.get("regimen_garin", "Régimen espacial")), "detail": "Infraestructura espacial configurada", "color": ORANGE},
				{"role": "COHERENCIA", "title": "Eterium", "detail": str(conf.get("dependencia_eterium", "Dependencia según el canon")), "color": TEAL}
			]
		"particulas":
			graph.set_graph([{
				"visual_type": "particula",
				"title": str(selected.get("nombre", "Partícula")),
				"formula": str(selected.get("formula", ""))
			}], "")
			return
			nodes = [
				{"role": "IDENTIDAD TASI", "title": str(selected.get("nombre", "Partícula")), "detail": str(selected.get("formula", "Sin fórmula indicada")), "color": YELLOW},
				{"role": "FUNCIÓN", "title": str(selected.get("funcion_canonica", "Función canónica")), "detail": str(selected.get("capa_canonica", "Capa no indicada")), "color": ACCENT},
				{"role": "EFECTO", "title": "Efecto registrado", "detail": str(selected.get("efecto_canonico", "No indicado")), "color": TEAL}
			]
		"elementos":
			var parts := _related_text("element_particles", "elemento_id", "nombre", "particulas", str(selected.get("id", "")))
			nodes = [
				{"role": "PARTÍCULAS", "title": str(selected.get("nombre", "Elemento")), "detail": parts if not parts.is_empty() else "Relación no disponible", "color": YELLOW},
				{"role": "CONFIGURACIÓN", "title": str(selected.get("regimen_estructural", "Régimen")), "detail": str(selected.get("estado_configuracion", "Estado no indicado")), "color": ACCENT},
				{"role": "PROPIEDADES", "title": "Perfil físico", "detail": _property_summary(selected), "color": TEAL}
			]
		"compuestos":
			var parts := _related_text("compound_elements", "compuesto_id", "nombre", "elementos", str(selected.get("id", "")))
			nodes = [
				{"role": "ELEMENTOS", "title": "Composición", "detail": parts if not parts.is_empty() else str(selected.get("formula_canonica", "Composición no disponible")), "color": YELLOW},
				{"role": "COMPUESTO", "title": str(selected.get("nombre", "Compuesto")), "detail": str(selected.get("formula_canonica", "Topología composicional")), "color": ACCENT},
				{"role": "PROPIEDADES", "title": "Estado registrado", "detail": _property_summary(selected), "color": TEAL}
			]
		"materiales":
			var parts := _related_text("material_components", "material_id", "componente_nombre", "", str(selected.get("id", "")))
			nodes = [
				{"role": "COMPONENTES", "title": "Composición", "detail": parts if not parts.is_empty() else "Componentes no disponibles", "color": YELLOW},
				{"role": "MATERIAL", "title": str(selected.get("nombre", "Material")), "detail": str(selected.get("tipo_material", selected.get("categoria", "Categoría no indicada"))), "color": ORANGE},
				{"role": "ESTADO", "title": str(selected.get("estado_calculo", "Sin estado")), "detail": _property_summary(selected), "color": TEAL}
			]
		"estructuras":
			var parts := _related_text("structure_composition", "estructura_id", "compuesto", "", str(selected.get("id", "")))
			nodes = [
				{"role": "COMPOSICIÓN", "title": "Componentes", "detail": parts if not parts.is_empty() else "Composición no disponible", "color": YELLOW},
				{"role": "ESTRUCTURA", "title": str(selected.get("nombre", "Estructura")), "detail": str(selected.get("tipo", "Tipo no indicado")) + " · " + str(selected.get("escala", "escala no indicada")), "color": ACCENT},
				{"role": "DERIVACIÓN", "title": str(selected.get("estado_calculo", "Estado")), "detail": _property_summary(selected), "color": TEAL}
			]
		"objetos":
			var materials_text := _related_text("object_materials", "item_id", "nombre", "materiales", str(selected.get("id", "")))
			var structures_text := _related_text("object_structures", "item_id", "nombre", "estructuras", str(selected.get("id", "")))
			nodes = [
				{"role": "MATERIAL", "title": "Material", "detail": materials_text if not materials_text.is_empty() else "Material no disponible", "color": ORANGE},
				{"role": "OBJETO", "title": str(selected.get("nombre", "Objeto")), "detail": structures_text if not structures_text.is_empty() else str(selected.get("geometria_fisica", "Geometría no disponible")), "color": ACCENT},
				{"role": "PROPIEDADES", "title": str(selected.get("estado_fisico", "Estado físico")), "detail": _property_summary(selected), "color": TEAL}
			]
		"organismos":
			var systems_text := _related_text("organism_systems", "organismo_id", "nombre", "sistemas", str(selected.get("id", "")))
			var organs_text := _related_text("organism_organs", "organismo_id", "nombre", "organos", str(selected.get("id", "")))
			nodes = [
				{"role": "SISTEMAS", "title": "Sistemas", "detail": systems_text if not systems_text.is_empty() else "Sistemas no disponibles", "color": GREEN},
				{"role": "ORGANISMO", "title": str(selected.get("nombre", "Organismo")), "detail": str(selected.get("tipo_organismo", "Tipo biológico")), "color": ACCENT},
				{"role": "ÓRGANOS", "title": "Órganos", "detail": organs_text if not organs_text.is_empty() else "Órganos no disponibles", "color": TEAL}
			]
	graph.set_graph(nodes, "")


func _render_inspector() -> void:
	if not is_instance_valid(inspector_content):
		return
	_clear(inspector_content)
	if not last_rpc.is_empty():
		var response: Variant = last_rpc.get("data", {})
		var rpc_tag := str(last_rpc.get("tag", ""))
		inspector_title.text = "Respuesta del motor"
		if response is Dictionary:
			_add_detail("Estado", str(response.get("estado", "respuesta recibida")), GREEN if str(response.get("estado", "")).to_lower() in ["calculado", "simulado", "lista_para_ejecucion"] else YELLOW)
			if rpc_tag == "rpc:ium":
				_add_detail("Salidas funcionales", _pretty(response.get("salidas", [])), TEAL)
				_add_detail("Procesos candidatos", _pretty(response.get("procesos_candidatos", [])), LAVENDER)
				_add_detail("Proceso principal", str(response.get("proceso_principal", "No determinado")))
			elif rpc_tag == "rpc:eterium":
				_add_detail("Eterium de organización", str(response.get("organizacion_proceso_eterium", "No resuelto")))
				_add_detail("Demanda física", str(response.get("demanda_fisica_eterium", "No resuelta")))
				_add_detail("Coste temporal", str(response.get("costo_temporal_eterium", "No resuelto")))
				_add_detail("Eterium estable requerido", str(response.get("eterium_estable_requerido", "No resuelto")), TEAL)
				_add_detail("Eterium liberado necesario", str(response.get("eterium_liberado_necesario", "No resuelto")), GREEN)
				var organization: Variant = response.get("organizacion_proceso", {})
				if organization is Dictionary:
					var config_state := str(organization.get("configuracion_estado", "estado no indicado"))
					var config_tint: Color = GREEN if config_state in ["canonico", "canonico_formal", "validada", "vigente"] else YELLOW
					_add_detail("Configuración IUM / estado", str(organization.get("configuracion_version", "versión no indicada")) + " · " + config_state, config_tint)
					_add_detail("Organización", str(organization.get("n_iums", "—")) + " IUM · " + str(organization.get("n_uniones", "—")) + " uniones")
				_add_detail("Resolución física", _pretty(response.get("demanda_fisica", {})))
				_add_detail("Fórmulas del motor", _pretty(response.get("formulas", {})))
			else:
				for property_key in ["masa", "carga", "volumen_real", "volumen", "densidad_real", "densidad", "estabilidad", "rigidez", "flexibilidad", "dureza", "conductividad", "transparencia", "interaccion", "nota"]:
					if response.has(property_key):
						_add_detail(property_key.replace("_", " ").capitalize(), str(response[property_key]))
		return
	if selected.is_empty():
		inspector_title.text = "Explora el canon"
		_add_detail("Cómo empezar", "Elige una entidad a la izquierda. El grafo muestra sus relaciones disponibles.")
		_add_detail("Motor de materia", "En Elementos o Compuestos, selecciona dos o más registros y pulsa Resolver selección.")
		_add_detail("Criterio de rigor", "Los valores calculados proceden de la respuesta RPC; las vistas gráficas son descriptivas.")
		return

	inspector_title.text = str(selected.get("nombre", current_key.capitalize()))
	match current_key:
		"procesos":
			_add_detail("Tipo / naturaleza", str(selected.get("tipo", "—")) + " / " + str(selected.get("naturaleza_canonica", "—")))
			_add_detail("Entrada", str(selected.get("entrada", "No registrada")))
			_add_detail("Transformación", str(selected.get("transformacion", selected.get("descripcion", "No registrada"))))
			_add_detail("Salida", str(selected.get("salida", "No registrada")), GREEN)
			_add_detail("Conservación", str(selected.get("conservacion", "Sin balance descrito")))
			_add_detail("Regla / fundamento", str(selected.get("regla_clave", "—")) + " / " + str(selected.get("estado_fundamento", "—")))
			_add_detail("Revisión requerida", str(selected.get("revision_requerida", "No indicado")), YELLOW)
			var law_rows := _related_rows("process_laws", "proceso_id", str(selected.get("id", "")))
			for law in law_rows:
				var law_variables: Array[String] = []
				for variable in _related_rows("process_law_variables", "ley_id", str(law.get("id", ""))):
					var requirement := "obligatoria" if bool(variable.get("obligatorio", true)) else "opcional"
					law_variables.append(str(variable.get("variable_clave", "variable")) + " · " + requirement)
				var law_value := str(law.get("formula", law.get("descripcion", "Ley registrada")))
				law_value += "\nModelo: " + str(law.get("modelo", "No indicado"))
				if not law_variables.is_empty():
					law_value += "\nVariables: " + ", ".join(law_variables)
				_add_detail("Ley cuantitativa · " + str(law.get("clave", "sin clave")), law_value, TEAL)
			var resolution_rows := _related_rows("process_models", "proceso_id", str(selected.get("id", "")))
			for resolution in resolution_rows:
				_add_detail("Modelo de resolución · " + str(resolution.get("clave", "sin clave")), str(resolution.get("formula", resolution.get("descripcion", "Modelo registrado"))) + "\nModo: " + str(resolution.get("modo", "No indicado")) + "\nMagnitudes: " + _pretty(resolution.get("magnitudes_requeridas", {})), LAVENDER)
		"oris":
			_add_detail("Dominio", str(selected.get("dominio", "—")))
			_add_detail("Familia", str(selected.get("familia", "—")))
			_add_detail("Fórmula canónica", str(selected.get("formula", "No registrada")), TEAL)
			_add_detail("Descripción", str(selected.get("descripcion", "Sin descripción")))
			var demand := _related_row("oris_demanda", "oris_id", str(selected.get("id", "")))
			if not demand.is_empty():
				_add_detail("Demanda estructural de Eterium", _pretty(demand), LAVENDER)
		"iums":
			_add_detail("Composición declarada", str(selected.get("detalle", "—")))
			var conf := _related_row("ium_config", "ium_id", str(selected.get("id", "")))
			if not conf.is_empty():
				_add_detail("Configuración funcional", _pretty(conf), LAVENDER)
			_add_detail("Partículas registradas", _related_text("ium_particles", "ium_id", "nombre", "particulas", str(selected.get("id", ""))))
			_add_detail("Información adicional", str(selected.get("extra", "Sin información adicional")))
		"particulas":
			_add_detail("Fórmula / identidad", str(selected.get("formula", "—")))
			_add_detail("Capa canónica", str(selected.get("capa_canonica", "—")))
			_add_detail("Función canónica", str(selected.get("funcion_canonica", "—")), TEAL)
			_add_detail("Efecto canónico", str(selected.get("efecto_canonico", "—")))
			_add_detail("Vector / polaridad", str(selected.get("vector_neto", "—")) + " / " + str(selected.get("polaridad_carga", "—")))
		"elementos":
			_add_detail("Símbolo / número atómico", str(selected.get("simbolo", "—")) + " / " + str(selected.get("numero_atomico", "—")))
			_add_detail("Masa base / carga Q", str(selected.get("masa_base", "—")) + " / " + str(selected.get("carga_q", "—")))
			_add_detail("Régimen estructural", str(selected.get("regimen_estructural", "—")))
			_add_detail("Partículas por capa", _related_text("element_particles", "elemento_id", "nombre", "particulas", str(selected.get("id", ""))))
			_add_detail("Propiedades", _property_summary(selected), TEAL)
		"compuestos":
			_add_detail("Fórmula canónica", str(selected.get("formula_canonica", "—")), TEAL)
			_add_detail("Elementos", _related_text("compound_elements", "compuesto_id", "nombre", "elementos", str(selected.get("id", ""))))
			_add_detail("Propiedades derivadas", _property_summary(selected))
			_add_detail("Propiedades emergentes", _pretty(selected.get("propiedades_emergentes", {})))
		"materiales":
			_add_detail("Tipo / estado", str(selected.get("tipo_material", "—")) + " / " + str(selected.get("estado_fisico", "—")))
			_add_detail("Descripción", str(selected.get("descripcion", "—")))
			_add_detail("Componentes", _related_text("material_components", "material_id", "componente_nombre", "", str(selected.get("id", ""))))
			_add_detail("Estado del cálculo", str(selected.get("estado_calculo", "—")))
			_add_detail("Propiedades calculadas", _pretty(selected.get("propiedades_calculadas", {})), TEAL)
		"estructuras":
			_add_detail("Tipo / escala", str(selected.get("tipo", "—")) + " / " + str(selected.get("escala", "—")))
			_add_detail("Descripción", str(selected.get("descripcion", selected.get("explicacion", "—"))))
			_add_detail("Composición", _related_text("structure_composition", "estructura_id", "compuesto", "", str(selected.get("id", ""))))
			_add_detail("Estado de cálculo", str(selected.get("estado_calculo", "—")))
			_add_detail("Propiedades calculadas", _pretty(selected.get("propiedades_calculadas", {})), TEAL)
		"objetos":
			_add_detail("Estado físico", str(selected.get("estado_fisico", "—")))
			_add_detail("Descripción", str(selected.get("descripcion", "—")))
			_add_detail("Materiales", _related_text("object_materials", "item_id", "nombre", "materiales", str(selected.get("id", ""))))
			_add_detail("Estructuras", _related_text("object_structures", "item_id", "nombre", "estructuras", str(selected.get("id", ""))))
			_add_detail("Geometría", _pretty(selected.get("geometria_fisica", {})))
			_add_detail("Propiedades físicas", _pretty(selected.get("propiedades_fisicas", {})), TEAL)
		"organismos":
			_add_detail("Tipo / conciencia", str(selected.get("tipo_organismo", "—")) + " / " + str(selected.get("nivel_conciencia", "—")))
			_add_detail("Descripción", str(selected.get("descripcion", "—")))
			_add_detail("Sistemas", _related_text("organism_systems", "organismo_id", "nombre", "sistemas", str(selected.get("id", ""))))
			_add_detail("Órganos", _related_text("organism_organs", "organismo_id", "nombre", "organos", str(selected.get("id", ""))))
			_add_detail("Estado / propiedades biológicas", str(selected.get("estado_calculo", "—")) + "\n" + _pretty(selected.get("propiedades_calculadas", {})), GREEN)
	if not errors.is_empty():
		_add_detail("Avisos de acceso", str(errors.size()) + " catálogo(s) o relación(es) con error. Comprueba permisos del Data API.", YELLOW)


func _add_detail(heading: String, value: String, tint: Color = TEXT_COLOR) -> void:
	var card := PanelContainer.new()
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#151e2b")
	card_style.border_color = Color("#354359")
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(12)
	card_style.content_margin_left = 0
	card_style.content_margin_right = 0
	card_style.content_margin_top = 0
	card_style.content_margin_bottom = 0
	card.add_theme_stylebox_override("panel", card_style)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector_content.add_child(card)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 11)
	margin.add_theme_constant_override("margin_right", 11)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_child(margin)
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 5)
	block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(block)
	var title := _label(heading.to_upper(), 10, Color("#b7c5dc"))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	block.add_child(title)
	var label := _label(value if not value.is_empty() else "Sin dato registrado", 13, tint)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	block.add_child(label)


func _related_rows(relation_key: String, foreign_key: String, ident: String) -> Array:
	var matches: Array = []
	for row in relations.get(relation_key, []):
		if row is Dictionary and str(row.get(foreign_key, "")) == ident:
			matches.append(row)
	return matches


func _related_row(relation_key: String, foreign_key: String, ident: String) -> Dictionary:
	var matches := _related_rows(relation_key, foreign_key, ident)
	return matches[0] if not matches.is_empty() else {}


func _related_text(relation_key: String, foreign_key: String, field: String, nested_key: String, ident: String) -> String:
	var values: Array[String] = []
	for row in _related_rows(relation_key, foreign_key, ident):
		var value: Variant = row.get(field, "")
		if not nested_key.is_empty():
			var nested: Variant = row.get(nested_key, {})
			if nested is Dictionary:
				value = nested.get(field, "")
			elif nested is Array and not nested.is_empty() and nested[0] is Dictionary:
				value = nested[0].get(field, "")
		if str(value).is_empty():
			continue
		var amount := str(row.get("cantidad", ""))
		var suffix := " × " + amount if not amount.is_empty() and amount != "1" else ""
		var item_text := str(value) + suffix
		if not values.has(item_text):
			values.append(item_text)
	return " · ".join(values)


func _property_summary(item: Dictionary) -> String:
	var props: Variant = item.get("propiedades_calculadas", item.get("propiedades_fisicas", item.get("perfil_fisico", {})))
	if props is Dictionary and not props.is_empty():
		var output: Array[String] = []
		for key in ["estado", "modelo", "masa", "carga", "estabilidad", "rigidez", "flexibilidad", "dureza", "conductividad", "densidad", "volumen"]:
			if props.has(key):
				output.append(key + ": " + str(props[key]))
		return " · ".join(output) if not output.is_empty() else _pretty(props)
	var output: Array[String] = []
	for key in ["masa_base", "masa", "carga_q", "carga", "estabilidad", "rigidez", "flexibilidad", "dureza", "conductividad", "densidad_real", "volumen_real"]:
		if item.has(key) and item[key] != null:
			output.append(key + ": " + str(item[key]))
	return " · ".join(output) if not output.is_empty() else "No hay propiedades disponibles para mostrar."


func _pretty(value: Variant) -> String:
	if value == null:
		return "Sin dato registrado"
	if value is Dictionary or value is Array:
		var encoded := JSON.stringify(value, "  ")
		return encoded.substr(0, 697) + "…" if encoded.length() > 700 else encoded
	var result := str(value)
	return result if not result.is_empty() else "Sin dato registrado"


func _spinbox(minimum: float, maximum: float, increment: float, initial: float) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = increment
	spin.value = initial
	spin.allow_greater = false
	spin.allow_lesser = false
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spin.add_theme_stylebox_override("normal", _field_style())
	spin.add_theme_stylebox_override("focus", _field_style(true))
	spin.add_theme_color_override("font_color", TEXT_COLOR)
	return spin


func _labeled_control(title: String, control: Control) -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(_label(title, 9, MUTED))
	column.add_child(control)
	return column


func _button(text_value: String, action: Callable, active: bool = false) -> Button:
	var button := Button.new()
	button.text = text_value
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", TEXT_COLOR)
	button.add_theme_color_override("font_hover_color", TEXT_COLOR)
	button.add_theme_color_override("font_pressed_color", TEXT_COLOR)
	button.add_theme_color_override("font_disabled_color", Color("#8995aa"))
	button.add_theme_stylebox_override("normal", _button_style(active))
	var hover := _button_style(active)
	hover.bg_color = Color("#31415a") if active else Color("#222d3d")
	button.add_theme_stylebox_override("hover", hover)
	var pressed := _button_style(true)
	pressed.bg_color = Color("#3b4b68")
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", _button_style(true))
	var disabled := _button_style(false)
	disabled.bg_color = Color("#141a24")
	button.add_theme_stylebox_override("disabled", disabled)
	button.pressed.connect(action)
	return button


func _button_style(active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#283650") if active else Color("#171e2a")
	style.border_color = Color("#8ea3ff") if active else BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = SURFACE
	style.border_color = BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _field_style(focused: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = SURFACE_ALT
	style.border_color = ACCENT if focused else BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _label(value: String, font_size: int = 12, tint: Color = TEXT_COLOR) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", maxi(font_size, 11))
	label.add_theme_color_override("font_color", tint)
	return label


func _with_margin(control: Control, amount: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", amount)
	margin.add_theme_constant_override("margin_right", amount)
	margin.add_theme_constant_override("margin_top", amount)
	margin.add_theme_constant_override("margin_bottom", amount)
	margin.add_child(control)
	return margin


func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
