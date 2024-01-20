extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var baseLava = preload('res://Lava.tres');
	var uniqueMaterial = baseLava.duplicate();
	
	var firstNoiseTexture = preload('res://FirstNoiseTexture.tres')
	var firstLavaNoise = preload('res://FirstLavaNoise.tres')
	
	var secondaryNoiseTexture = preload('res://FirstNoiseTexture.tres')
	var secondaryLavaNoise = preload('res://FirstLavaNoise.tres')
		
	firstNoiseTexture.set_noise(firstLavaNoise);

	uniqueMaterial.set_shader_parameter('seed', randf())
	
	uniqueMaterial.set_shader_parameter('scrollSpeed', Vector2(randf_range(0.02, 0.04), randf_range(0.02, 0.04)))
	uniqueMaterial.set_shader_parameter('secondaryScrollSpeed', Vector2(randf_range(0.02, 0.04), randf_range(0.02, 0.04)))
	
	uniqueMaterial.set_shader_parameter('rotationSpeed', randf_range(30, 60))
	
	uniqueMaterial.set_shader_parameter('noise', firstNoiseTexture)
	uniqueMaterial.set_shader_parameter('secondaryNoise', secondaryNoiseTexture)
	material = uniqueMaterial;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

#func copy_base (base, unique, param):
	#var before = (base as ShaderMaterial).get_shader_parameter(param as String)
	#(unique as ShaderMaterial).set_shader_parameter(param, before);
	#return
	
func _process(delta):
	pass
