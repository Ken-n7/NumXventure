@tool
extends Node2D

## The board's authored geometry, as nodes you can drag in the editor viewport.
##
## This is the source of truth. `AdventureScreen` reads it on the way up and falls
## back to its own `ISLANDS` / `TRAILS` constants only when the scene is missing a
## handle -- which is what keeps a bare `AdventureScreen.gd.new()` (the old test
## path) still buildable.
##
## Everything is stored in world pixels, because that is what you drag. The screen
## works in normalized 0..1 coords, so the accessors convert on the way out.
##
## Expected children, all optional:
##   Islands/*   IslandHandle (Marker2D + a `Radius` child marker)
##   Trails/*    Path2D, one per island, points in world px, in walk order
##   Knight      Marker2D -- where the giant knight stands; unset = halfway
##   Lifts/*     Marker2D named `Tower0..2` -- offset of a keep from its doorstep
##   Decor/*     DecorProp sprites, written by `bake_decor()`
##
## Sibling order matters: `Islands/*` and `Trails/*` are read top to bottom, so the
## first trail is the camp's and the last is the one holding the Victory Gate.

const W := 96
const H := 54
const TILE := 32

## Ticked in the inspector to re-scatter the decoration from the seed, replacing
## whatever is under `Decor`. Untick-free: it resets itself once it has run.
@export var bake_decor := false:
	set(v):
		bake_decor = false
		if v and Engine.is_editor_hint():
			_request_bake = true

## Scatter seed. Change it for a different arrangement, then bake again.
@export var decor_seed := 90210

## Ticked to drop the three `Lifts/TowerN` markers onto wherever `_tower_lift()`
## currently puts each keep. They start at ZERO, meaning "choose for me", which is
## also where the world origin is -- so this is how they become draggable at all.
## Drag one afterwards and that keep stays where you put it.
@export var adopt_tower_lifts := false:
	set(v):
		adopt_tower_lifts = false
		if v and Engine.is_editor_hint():
			_request_adopt = true

var _request_bake := false
var _request_adopt := false


static func to_norm(p: Vector2) -> Vector2:
	return Vector2(p.x / float(W * TILE), p.y / float(H * TILE))


static func to_px(p: Vector2) -> Vector2:
	return Vector2(p.x * W * TILE, p.y * H * TILE)


## `{c, r, wobble}` per island, normalized, or [] when nothing is authored.
func islands() -> Array:
	var out: Array = []
	for n in _kids("Islands"):
		out.append({
			"c": to_norm(n.position),
			"r": to_norm(n.radius_px()) if n.has_method("radius_px") else Vector2(0.2, 0.2),
			"wobble": float(n.get("wobble")) if n.get("wobble") != null else 1.7,
		})
	return out


## One array of normalized points per trail, or [] when nothing is authored. A
## Path2D with fewer than two points cannot be walked, so it is dropped rather
## than half-honoured -- the fallback constant is better than a broken trail.
func trails() -> Array:
	var out: Array = []
	for n in _kids("Trails"):
		var c: Curve2D = n.curve
		if c == null or c.point_count < 2:
			continue
		var pts: Array[Vector2] = []
		for i in c.point_count:
			pts.append(to_norm(n.position + c.get_point_position(i)))
		out.append(pts)
	return out


## Where the knight stands, in world px, or ZERO to let the neck pick the middle.
func knight_post_px() -> Vector2:
	var n: Node2D = get_node_or_null("Knight")
	return Vector2.ZERO if n == null else n.position


## Where keep `st` stands, in world px, or ZERO to let `_tower_lift()` choose.
## Absolute rather than an offset from the doorstep, so the marker sits on the
## building it controls instead of piling up at the world origin.
func tower_keep_px(st: int) -> Vector2:
	var n: Node2D = get_node_or_null("Lifts/Tower%d" % st)
	return Vector2.ZERO if n == null else n.position


## The baked decoration, as plain data the screen rebuilds its own sprites from.
func props() -> Array:
	var out: Array = []
	for n in _kids("Decor"):
		if String(n.get("art")) == "":
			continue
		out.append({
			"art": String(n.get("art")),
			"pos": n.position,
			"scale": absf(n.scale.x),
			"flip": -1.0 if n.scale.x < 0.0 else 1.0,
			"anim": bool(n.get("anim")),
			"fps": float(n.get("fps")),
		})
	return out


func has_props() -> bool:
	var d: Node = get_node_or_null("Decor")
	return d != null and d.get_child_count() > 0


## Cheap fingerprint of everything draggable, so the editor preview knows when a
## handle has moved without listening to every node.
func fingerprint() -> String:
	var parts: Array[String] = []
	for group in ["Islands", "Trails", "Lifts", "Decor"]:
		for n in _kids(group):
			parts.append("%.1f,%.1f" % [n.position.x, n.position.y])
			for kid in n.get_children():
				parts.append("%.1f,%.1f" % [(kid as Node2D).position.x, (kid as Node2D).position.y])
			if n is Path2D and (n as Path2D).curve != null:
				var c: Curve2D = (n as Path2D).curve
				for i in c.point_count:
					parts.append("%.1f,%.1f" % [c.get_point_position(i).x, c.get_point_position(i).y])
			if n.get("wobble") != null:
				parts.append("%.3f" % float(n.get("wobble")))
	var k: Node2D = get_node_or_null("Knight")
	if k != null:
		parts.append("%.1f,%.1f" % [k.position.x, k.position.y])
	return "|".join(parts)


func take_bake_request() -> bool:
	var v := _request_bake
	_request_bake = false
	return v


func take_adopt_request() -> bool:
	var v := _request_adopt
	_request_adopt = false
	return v


func _kids(group: String) -> Array:
	var g: Node = get_node_or_null(group)
	return [] if g == null else g.get_children()
