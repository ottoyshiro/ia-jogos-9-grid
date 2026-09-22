extends Node2D

const WORLD_WIDTH = 2400
const WORLD_HEIGHT = 1800

const GRID_SIZE = 12

const CELL_WIDTH = WORLD_WIDTH / GRID_SIZE
const CELL_HEIGHT = WORLD_HEIGHT / GRID_SIZE

var current_cell = Vector2i(-1, -1)

var active_cells = []

var previous_active_cells = []

func _ready():
	setup_areas()
	update_grid()

func _process(_delta):
	update_grid()

func update_grid():
	update_player_cell()
	update_active_cells()

func setup_areas():

	const AREA_WIDTH = 800
	const AREA_HEIGHT = 600

	for y in range(3):
		for x in range(3):

			var index = y * 3 + x
			var area = get_node("../Areas/Area" + str(index))

			area.position = Vector2(x * AREA_WIDTH, y * AREA_HEIGHT)

func update_player_cell():

	var player = get_node("../Player")
	var grid_x = floor(player.position.x / CELL_WIDTH)

	var grid_y = floor(player.position.y / CELL_HEIGHT)

	grid_x = clamp(grid_x, 0, GRID_SIZE - 1)

	grid_y = clamp(grid_y, 0, GRID_SIZE - 1)

	var new_cell = Vector2i(grid_x, grid_y)

	if new_cell != current_cell:
		current_cell = new_cell

		print("Jogador está na célula: ", current_cell)

func update_active_cells():

	active_cells.clear()

	var viewport = get_viewport()
	var camera = get_node("../Player/Camera2D")

	var camera_position = camera.global_position
	var zoom = camera.zoom
	
	var viewport_size = viewport.get_visible_rect().size
	var viewport_width = viewport_size.x / zoom.x
	var viewport_height = viewport_size.y / zoom.y
	var viewport_rect = Rect2(
		camera_position - Vector2(viewport_width, 
		viewport_height) / 2, 
		Vector2(viewport_width, viewport_height)
	)

	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):

			var cell_position = Vector2(x * CELL_WIDTH, y * CELL_HEIGHT)
			var cell_rect = Rect2(cell_position, Vector2(CELL_WIDTH, CELL_HEIGHT))

			if viewport_rect.intersects(cell_rect):
				active_cells.append(Vector2i(x, y))

	if active_cells != previous_active_cells:

		previous_active_cells = active_cells.duplicate()

		print("================================")
		print(
			"Célula do jogador: ",
			current_cell
		)
		print(
			"Células ativas: ",
			active_cells
		)
		print(
			"Quantidade: ",
			active_cells.size()
		)
		print("================================")

	queue_redraw()

func _draw():

	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):

			var cell_position = Vector2(x * CELL_WIDTH, y * CELL_HEIGHT)
			var cell_rect = Rect2(cell_position, Vector2(CELL_WIDTH, CELL_HEIGHT))
			var cell = Vector2i(x, y)

			# Célula ativa
			if cell in active_cells:
				draw_rect(cell_rect, Color(0.2, 0.8,0.2, 0.25), true)

			# Borda da célula
			draw_rect(cell_rect, Color.BLACK, false, 1.0)
