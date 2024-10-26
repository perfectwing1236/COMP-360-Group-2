extends Node3D

@onready var glider = $glider2
@onready var cam = $Camera3D
@onready var marker = $marker
@onready var scape = $Landscape

var path : Path3D
var pfollow : PathFollow3D
var n : int
var t : float
var pts : PackedVector3Array
var curr : Vector3
var next : Vector3
var forward : Vector3
var skip : int

# New variables for interpolation and rolling
var tangent_curr : Vector3
var tangent_next : Vector3
var roll_angle : float = 0.0

func _ready():
	skip = 0
	_setup_path()
	_create_path_image()
	pfollow.loop = true     #enable looping for the glider path
	
func _create_path_image():
	
	var image = Image.create_empty(100, 100, false, Image.FORMAT_RGBA8)
	
	for x in range(100):
		for y in range(100):
			image.set_pixel(x, y, Color.TRANSPARENT)
	
	for pt in pts:
		image.set_pixel(pt.x, pt.z, Color.RED)
		
	var pathplane = MeshInstance3D.new()
	
	var pathmaterial = StandardMaterial3D.new()
	pathmaterial.albedo_texture = ImageTexture.create_from_image(image)
	pathmaterial.transparency = 1
	pathmaterial.texture_filter = 0
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES) # mode controls kind of geometry
	st.set_uv(Vector2(0, 0))
	st.add_vertex(Vector3(0, 0, 0))
	st.set_uv(Vector2(1, 0))
	st.add_vertex(Vector3(1, 0, 0))
	st.set_uv(Vector2(1, 1))
	st.add_vertex(Vector3(1, 0, 1))
	st.set_uv(Vector2(0, 1))
	st.add_vertex(Vector3(0, 0, 1))
	st.add_index(0)
	st.add_index(1)
	st.add_index(2)
	st.add_index(0)
	st.add_index(2)
	st.add_index(3)
	st.generate_normals()
	var normals = st.commit()
	pathplane.mesh = normals
	pathplane.material_override = pathmaterial
	add_child(pathplane)
	pathplane.scale = Vector3(100, 16, 100)
	pathplane.position = Vector3(0, 35, 0)
	
func _setup_path():
	
	var curve = _create_spline(Hilbert.new(100, 100, 4))
	
	pts = curve.get_baked_points()
	
	path = Path3D.new()
	path.transform = Transform3D.IDENTITY
	path.curve = curve

	scape.scale = Vector3(16, 16, 16)
	scape.position = Vector3(-30, 0, -30)
	pfollow = PathFollow3D.new()
	#glider.transform = Transform3D.IDENTITY
	glider.scale = Vector3(0.03, 0.03, 0.03)
	#cam.transform = Transform3D.IDENTITY
	cam.position = Vector3(.10,.25,-.30)
	cam.look_at(glider.position)
	cam.reparent(glider)
	glider.rotate_y(PI)
	glider.reparent(pfollow)
	path.add_child(pfollow)
	pfollow.transform = Transform3D.IDENTITY
	add_child(path)

func _process(delta):
	t = fmod(t + delta, 10)  # Keep increasing t with time, looping it between 0 and 10.
	pfollow.progress_ratio = t / 10.0  # Set how far the glider has moved along the path (0 is the start, 1 is the end).

	#skip += 1  # Increase the skip counter every frame.
	#var roll_amount = 0.0  # Start with no rolling for the glider.

	#if (skip % 10 == 0):  # Only do the following every 10 frames to save processing time.
		#var k = int(n * t / 10.0)  # Calculate which section of the path the glider is currently in.
		#curr = pts[pts.size() - 1] if k > pts.size() - 2 else pts[k]  # Get the current position.
		#next = pts[0] if k > pts.size() - 2 else pts[k + 1]  # Get the next position on the path.
		#forward = (next - curr).normalized()  # Find the direction from the current point to the next.

		# Calculate the direction (tangent) between the current and next points.
		#tangent_curr = (pts[k + 1] - pts[k]).normalized() if k < pts.size() - 1 else forward
		#tangent_next = (pts[k + 2] - pts[k + 1]).normalized() if k < pts.size() - 2 else forward

		# Find how far along the current section of the path the glider is.
		#var percent_traveled = fposmod(pfollow.progress_ratio * n, 1.0)
		# Smoothly blend (interpolate) between the current and next direction based on how far we are.
		#var interpolated_tangent = tangent_curr.lerp(tangent_next, percent_traveled)

		# Calculate how far apart the current point and the next are.
		#var handle_length_curr = (pts[k + 1] - pts[k]).length()
		# Calculate the distance between the next two points.
		#var handle_length_next = (pts[k + 2] - pts[k + 1]).length() if k < pts.size() - 2 else handle_length_curr

		# Find the cross product of these two distances. It helps determine how much to roll the glider.
		#var handle_cross = Vector3(handle_length_curr, 0, 0).cross(Vector3(handle_length_next, 0, 0))

		# Multiply the cross product’s length by 0.1 to get the amount of rolling.
		#roll_amount = handle_cross.length() * 0.1  # (0.1 is just a factor to scale the effect).

		# Make the roll amount depend on how far along the section the glider has moved.
		#var roll_adjustment = interpolated_tangent.length() * 0.1  # Use the tangent’s length to scale it.
		#roll_amount = roll_amount * roll_adjustment  # Adjust the roll based on this scaling factor.

	# Apply the rolling effect to the glider:
	#roll_angle = roll_amount * sin(t * 2 * PI / 5)  # Calculate the roll angle, making it oscillate with time.
	#var rolling_axis = forward  # The glider will roll around its forward direction.
	#glider.rotate_object_local(rolling_axis, roll_angle)  # Apply the rotation (roll) to the glider.

	# Adjust the glider's orientation (basis) for its rolling motion.
	glider.basis = Basis(Vector3.UP, PI) * Transform3D.IDENTITY.basis  # Reset and rotate around the UP axis.
	glider.basis = Basis(Vector3(0, 0, 1), sin(t * 2 * PI / 5) * -PI / 8.0) * glider.basis  # Add a rotation around Z-axis.

func _create_spline(curve):
	var newcurve := Curve3D.new()
	
# Choose every 20th point from the old curve to create our spline
	var ptlist = PackedVector3Array()
	for ptnum in range(1, len(curve.curve)):
		if ceil(ptnum/20.0) == floor(ptnum/20.0):
			var newpt = Vector3(curve.curve[ptnum].y, 35, curve.curve[ptnum].x)
			ptlist.append(newpt)
			newcurve.add_point(newpt)
	newcurve.add_point(newcurve.get_baked_points()[0])
	
# Set in and out angle for each point to angle between previous and next point
	assert(len(ptlist) > 1)
	for pt in range(len(ptlist)+1):
		if pt != 0 and pt != len(ptlist):
			var angout = ptlist[pt-1].direction_to(ptlist[(pt+1)%len(ptlist)])/0.2
			newcurve.set_point_in(pt, -angout)
			newcurve.set_point_out(pt, angout)
# First and last points of the curve are the same in order to loop,
# use second and last points from ptlist to calculate angles, since ptlist does
# not contain the (duplicate) last point from the curve
		else:
			var angout = ptlist[-1].direction_to(ptlist[1])/0.2
			newcurve.set_point_in(pt, -angout)
			newcurve.set_point_out(pt, angout)
	return newcurve
