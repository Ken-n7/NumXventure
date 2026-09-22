@tool
extends Sprite2D

## One baked decoration. The scatter in `BoardLayout.bake_decor()` writes these
## into the scene so they can be dragged one by one; the sprite you see here is
## the prop's own art, so the editor shows what it is without any gizmo.
##
## `anim` marks the sheets that sway (trees, water rocks). They are baked flat --
## saving a generated SpriteFrames per prop would put ~170 of them in the .tscn --
## and `BoardLayout.props()` hands the flag back so the running game rebuilds them
## through `Art.anim_sprite()` exactly as the old scatter did.
@export var anim := false
@export var fps := 3.0
@export var art := ""
