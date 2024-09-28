extends Node3D

func _ready():
	var land = MeshInstance3D.new()
	
	var noise = _heightmap(256, 256)
	var st = _quadgrid(5, 5)
	
	var material = StandardMaterial3D.new()
	material.albedo_texture = ImageTexture.create_from_image(noise)
	
	st.generate_normals() # normals point perpendicular up from each face
	var mesh = st.commit() # arranges mesh data structures into arrays for us
	land.mesh = mesh
	add_child(land)
	
	pass

func _quad(st : SurfaceTool, pt : Vector3, count : Array[int]):
	st.set_uv( Vector2(0, 0) )
	st.add_vertex( pt + Vector3(0, 0, 0) ) # vertex 0
	count[0] += 1
	st.set_uv( Vector2(1, 0) )
	st.add_vertex( pt + Vector3(1, 0, 0) ) # vertex 1
	count[0] += 1
	st.set_uv( Vector2(1, 1) )
	st.add_vertex( pt + Vector3(1, 0, 1) ) # vertex 2
	count[0] += 1
	st.set_uv( Vector2(0, 1) )
	st.add_vertex( pt + Vector3(0, 0, 1) ) # vertex 3
	count[0] += 1
	
	st.add_index(count[0] - 4) # make the first triangle
	st.add_index(count[0] - 3)
	st.add_index(count[0] - 2)
	
	st.add_index(count[0] - 4) # make the second triangle
	st.add_index(count[0] - 2)
	st.add_index(count[0] - 1)
	
	pass

func _heightmap(x: int, y: int) -> Image:
# return image of noise with dimensions (x, y)
	var noise = FastNoiseLite.new()
	noise.noise_type = 2
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5  # Higher for more detail
	noise.fractal_gain = 0.9   # Controls the amplitude of each octave
	noise.frequency = 0.01  # Lower frequency for larger, smoother hills
	noise.domain_warp_enabled = true
	noise.domain_warp_frequency = 0.05
	noise.domain_warp_amplitude = 30
	
	return noise.get_image(x, y)
	
func _quadgrid(x: int, z: int) -> SurfaceTool:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES) # mode controls kind of geometry
	var count : Array[int] = [0]
	
	for u in range(x): # corner of grid is at x, z
		for v in range(z):
			_quad(st, Vector3(u, 0, v), count)
	
	return st
