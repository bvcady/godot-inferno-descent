@tool
extends Node2D

@export var smokeColor = Color.WHITE_SMOKE
var particles = []

func _ready():
	var img = Image.create(32, 32, true, Image.FORMAT_RGBA8)
	
	
	var w = img.get_width()
	var h = img.get_height()
	var middle = Vector2(w, h)/2
	var radius = 12
	for i in w:
		for j in h:
			var p = Vector2(i, j);
			if(p.distance_to(middle) < radius):
				img.set_pixelv(p, Color.ALICE_BLUE)
	

	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(1,1,0)
	
	var v_texture = CurveTexture.new();
	var v_curve = Curve.new();
	v_curve.add_point(Vector2(0, 6))
	v_curve.add_point(Vector2(0.3, 20))
	v_curve.add_point(Vector2(1, 0))
	v_texture.curve = v_curve
	material.velocity_limit_curve = v_texture
	
	
	var sv_texture = CurveTexture.new()
	var sv_curve = Curve.new();
	sv_curve.add_point(Vector2(0, 0))
	sv_curve.add_point(Vector2(0.4, 0.6))
	sv_curve.add_point(Vector2(0.75, 1))
	sv_curve.add_point(Vector2(1, 0))
	sv_texture.curve = sv_curve;
	material.scale_curve = sv_texture
	
	material.gravity = Vector3(0, -9.81, 0)
	
	var tur_texture = CurveTexture.new();
	var tur_curve = Curve.new();
	tur_curve.add_point(Vector2(0, 0));
	tur_curve.add_point(Vector2(0.3, 0.33));
	tur_curve.add_point(Vector2(1, 0.66));
	tur_texture.curve = tur_curve
	
	
	material.turbulence_enabled = true;
	material.turbulence_influence_over_life = tur_texture
	
	material.turbulence_noise_strength = 0.1

	$CanvasGroup/SmokeParticles.process_material = material
	$CanvasGroup/SmokeParticles.lifetime = 7.0;
	$CanvasGroup/SmokeParticles.preprocess = 7.0;
	
	var img_texture = ImageTexture.create_from_image(img);
	$CanvasGroup/SmokeParticles.texture = img_texture
