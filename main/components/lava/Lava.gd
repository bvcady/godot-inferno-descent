extends Node2D

@export var smokeColor = Color.WHITE_SMOKE
var particles = []

func _ready():
	var img = Image.create(32, 32, true, Image.FORMAT_RGBA8)
	
	var w = img.get_width()
	var h = img.get_height()
	var middle = Vector2(w, h)/2
	var radius = 4
	for i in w:
		for j in h:
			var p = Vector2(i, j);
			if(p.distance_to(middle) < radius):
				img.set_pixelv(p, smokeColor)
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(12,12,0)
	
	var v_texture = CurveTexture.new();
	var v_curve = Curve.new();
	v_curve.add_point(Vector2(0, 6))
	v_curve.add_point(Vector2(0.3, 20))
	v_curve.add_point(Vector2(1, 0))
	v_texture.curve = v_curve
	material.velocity_limit_curve = v_texture
	
	
	var sv_texture = CurveTexture.new()
	var sv_curve = Curve.new();
	sv_curve.add_point(Vector2(0, 0.3))
	sv_curve.add_point(Vector2(0.4, 0.6))
	sv_curve.add_point(Vector2(0.75, 1))
	sv_curve.add_point(Vector2(1, 0.3))
	sv_texture.curve = sv_curve;
	material.scale_curve = sv_texture
	
	material.gravity = Vector3(0, 0, 0)
	
	var tur_texture = CurveTexture.new();
	var tur_curve = Curve.new();
	tur_curve.add_point(Vector2(0, 0));
	tur_curve.add_point(Vector2(0.3, 0.33));
	tur_curve.add_point(Vector2(1, 0.66));
	tur_texture.curve = tur_curve
	
	material.alpha_curve = sv_curve
	
	material.turbulence_enabled = false;
	material.turbulence_influence_over_life = tur_texture
	
	material.turbulence_noise_strength = 0.1
	
	
	#var color_texture = GradientTexture1D.new();
	#var color_gradient = Gradient.new();
	#color_gradient.add_point(0.0, Color.BLACK);
	#color_gradient.add_point(100.0, Color.WHITE);
	#color_gradient.add_point(256.0, Color.WHITE);
	#color_texture.gradient = color_gradient
	
	#material.color_ramp = color_texture;
	
	#material.color = smokeColor

	$CanvasGroup/LavaParticles.process_material = material
	$CanvasGroup/LavaParticles.lifetime = 7.0;
	$CanvasGroup/LavaParticles.preprocess = 7.0;
	$CanvasGroup/LavaParticles.draw_order = 2;
	$CanvasGroup/LavaParticles.amount = 10;
	
	var img_texture = ImageTexture.create_from_image(img);
	$CanvasGroup/LavaParticles.texture = img_texture
	
	var ashMaterial = material.duplicate();
	
	ashMaterial.scale_curve = null;
	
	$CanvasGroup/AshParticles.process_material = material
	$CanvasGroup/AshParticles.lifetime = 7.0;
	$CanvasGroup/AshParticles.preprocess = 7.0;
	$CanvasGroup/AshParticles.amount = 10;
	
	$ColorRect.color = smokeColor
