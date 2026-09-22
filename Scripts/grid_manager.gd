extends Node2D

const WORLD_WIDTH = 2400
const WORLD_HEIGHT = 1800

const GRID_SIZE = 12

const CELL_WIDTH = WORLD_WIDTH / GRID_SIZE
const CELL_HEIGHT = WORLD_HEIGHT / GRID_SIZE

var current_cell = Vector2i(-1, -1)
var active_cells = []

func _ready():
	setup_areas()

func _process(_delta):
	var cell_index = update_player_cell()
	var current_area = get_area_from_cell_index(cell_index)
	#print("Área Atual: ", current_area, " | Vizinhos: ", get_neighbors(current_cell))
	update_enemies_activity(current_area)

func get_neighbors(check_cell: Vector2i) -> Array[int]:
	if check_cell == Vector2i(-1, -1):
		return []

	# 1. Primeiro, descobrimos em qual área (0 a 8) a célula enviada está
	var player_cell_index = check_cell.y * GRID_SIZE + check_cell.x
	var current_area = get_area_from_cell_index(player_cell_index)
	
	# 2. Convertemos o ID da área (0-8) para coordenadas X e Y numa grade 3x3
	var area_x = current_area % 3
	var area_y = current_area / 3

	var neighbors: Array[int] = []
	
	# Direções das extremidades (Cima, Baixo, Esquerda, Direita)
	var directions = [
		Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)
	]
	
	for dir in directions:
		# Aplica a direção na grade 3x3
		var target_area_x = area_x + dir.x
		var target_area_y = area_y + dir.y
		
		# Verifica se o vizinho está dentro dos limites da grade de áreas (0 a 2)
		if target_area_x >= 0 and target_area_x < 3 and target_area_y >= 0 and target_area_y < 3:
			# 3. Converte a coordenada 3x3 de volta para o ID de área de 0 a 8
			var neighbor_area_id = target_area_y * 3 + target_area_x
			neighbors.append(neighbor_area_id)
			
	return neighbors

func update_player_cell() -> int:
	var player = get_node("../Player")
	
	var grid_x = floor(player.position.x / CELL_WIDTH)
	var grid_y = floor(player.position.y / CELL_HEIGHT)

	grid_x = clamp(grid_x, 0, GRID_SIZE - 1)
	grid_y = clamp(grid_y, 0, GRID_SIZE - 1)

	var new_cell = Vector2i(grid_x, grid_y)

	if new_cell != current_cell:
		current_cell = new_cell
		
		# 1. Pega o ID da área atual e a lista de vizinhos (0 a 8)
		var player_cell_index = current_cell.y * GRID_SIZE + current_cell.x
		var current_area_id = get_area_from_cell_index(player_cell_index)
		var neighbor_areas = get_neighbors(new_cell)
		
		# 2. Varre todas as 9 áreas do jogo
		for i in range(9):
			var area_node = get_node("../Areas/Area" + str(i))
			
			# Se for a área do player OU estiver na lista de vizinhos, ATIVA
			if i == current_area_id or i in neighbor_areas:
				area_node.process_mode = PROCESS_MODE_INHERIT # Roda normalmente
				area_node.visible = true # Opcional: mostra a área
			else:
				# Se estiver longe, DESATIVA tudo dentro dela (incluindo inimigos)
				area_node.process_mode = PROCESS_MODE_DISABLED # Congela tudo

	return current_cell.y * GRID_SIZE + current_cell.x

func update_enemies_activity(current_area_id: int):
	var neighbor_areas = get_neighbors(current_cell)
	
	# Garante que todas as áreas fiquem sempre ativas na hierarquia (PROCESS_MODE_INHERIT)
	# para permitir que os inimigos se movam livremente entre elas sem bugar.
	for i in range(9):
		var area_node = get_node("../Areas/Area" + str(i))
		area_node.process_mode = PROCESS_MODE_INHERIT

	# Encontra todos os inimigos usando um grupo (Adicione o grupo "enemies" no nó do seu Inimigo)
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if enemy is CharacterBody2D:
			# 1. Calcula em qual célula 12x12 o INIMIGO está fisicamente agora
			var enemy_grid_x = floor(enemy.global_position.x / CELL_WIDTH)
			var enemy_grid_y = floor(enemy.global_position.y / CELL_HEIGHT)
			enemy_grid_x = clamp(enemy_grid_x, 0, GRID_SIZE - 1)
			enemy_grid_y = clamp(enemy_grid_y, 0, GRID_SIZE - 1)
			
			var enemy_cell_index = enemy_grid_y * GRID_SIZE + enemy_grid_x
			# 2. Transforma na área 0-8 do inimigo
			var enemy_area = get_area_from_cell_index(enemy_cell_index)
			
			# 3. Se a área real do INIMIGO for a do player ou vizinha, ele se move!
			if enemy_area == current_area_id or enemy_area in neighbor_areas:
				enemy.process_mode = PROCESS_MODE_INHERIT
				enemy.visible = true
			else:
				enemy.process_mode = PROCESS_MODE_DISABLED
				#enemy.visible = false

func get_area_from_cell_index(cell_index: int) -> int:
	var cell_x = cell_index % 12
	var cell_y = cell_index / 12
	
	var area_x = cell_x / 4
	var area_y = cell_y / 4
	
	var area_id = area_y * 3 + area_x
	return area_id

func setup_areas():
	const AREA_WIDTH = 800
	const AREA_HEIGHT = 600

	for y in range(3):
		for x in range(3):
			var index = y * 3 + x
			var area = get_node("../Areas/Area" + str(index))
			area.position = Vector2(x * AREA_WIDTH, y * AREA_HEIGHT)

func _draw():
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var cell_position = Vector2(x * CELL_WIDTH, y * CELL_HEIGHT)
			var cell_rect = Rect2(cell_position, Vector2(CELL_WIDTH, CELL_HEIGHT))
			draw_rect(cell_rect, Color.BLACK, false, 1.0)
