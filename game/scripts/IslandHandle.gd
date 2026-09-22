@tool
extends Marker2D

## One island's shape, as two things you can drag in the editor viewport: this
## marker is the centre, and its `Radius` child's local offset is the ellipse's
## half-width and half-height. Dragging the child resizes the island; dragging
## this one moves it.
##
## `wobble` has no handle because it is noise, not geometry -- it only shifts the
## coastline ripple so two islands of the same size do not come out as the same
## shape rotated. Type a different number and the preview redraws.
@export var wobble := 1.7

## `_stamp_path()` stamps land under the walk regardless, so a trail may push a
## little past this outline; the outline is what the coast is drawn from.
func radius_px() -> Vector2:
	var r: Marker2D = get_node_or_null("Radius")
	return Vector2(64, 64) if r == null else r.position.abs().max(Vector2(32, 32))
