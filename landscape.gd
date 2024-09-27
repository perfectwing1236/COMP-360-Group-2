#extends Node3D

func _ready():
	noise = FastNoiseLite.new()
	noise.noise_type = 2
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5  # Higher for more detail
	noise.fractal_gain = 0.9   # Controls the amplitude of each octave
	noise.frequency = 0.01  # Lower frequency for larger, smoother hills
	
	noise.domain_warp_enabled = true
	noise.domain_warp_frequency = 0.05
	noise.domain_warp_amplitude = 30
