extends Control

## Review hub: pre-game lessons for the three competencies. Per the design,
## this exists to study *before* the adventure, away from the timer.

var main: Control

const WRAP_W := 380.0

## `[tab, heading, intro, bullets, examples, rule]`. The tab is short because a
## Button's minimum size grows with its text and the mockup's headings run to
## 54 characters; the heading itself is shown in the body, where the wording
## contract actually matters.
##
## The three topics, in the mockups' order and their words: headings and the
## opening paragraph are taken verbatim from the Learn screen, because §1 makes
## the PDFs a wording contract even though the art is ours. The bullets and
## examples below each are ours -- they teach the rule rather than restate the
## heading, and no PDF contradicts them.
##
## Still owed (Q13): the mockup shows a gallery of instructional images under
## each heading. Nobody has said who supplies them.
static var LESSONS := [
	[
		"Basic Operations",
		"Basic Operations on Integers",
		"This involves addition, subtraction, multiplication, and division of "
		+ "positive and negative whole numbers. Understanding these operations "
		+ "and their rules will help you solve numerical expressions accurately "
		+ "and confidently.",
		[
			"Addition: same signs → add, keep the sign. Different signs → subtract the smaller from the bigger, keep the bigger's sign.",
			"Subtraction: rewrite as adding the opposite: a − b = a + (−b).",
			"Multiplication / Division: same signs → positive; different signs → negative.",
			"Dividing only works evenly: −24 ÷ 6 = −4.",
		],
		["8 + (−3) = 5", "5 − (−7) = 12", "(−6) × 4 = −24"],
		QuestionGen.RULES.add,
	],
	[
		"Exponential Notation",
		"Understanding Numbers Expressed in Exponential Notation",
		"The mastery of basic multiplication facts is necessary. You should not "
		+ "multiply the base and its exponent but multiply the base by the "
		+ "number of times as shown in the exponent.",
		[
			"bⁿ means b multiplied by itself n times (n ≥ 2 in this adventure).",
			"The base is the number being multiplied; the exponent is the little power number.",
			"2³ = 2 × 2 × 2 = 8, not 2 × 3.",
			"A negative base to an odd exponent stays negative: (−2)³ = −8.",
		],
		["2³ = 2 × 2 × 2 = 8", "5² = 25", "(−3)² = (−3) × (−3) = 9"],
		QuestionGen.RULES.exp,
	],
	[
		"Order of Operations",
		"Order of Operations on Integers",
		"Expressions can be solved by following the rules on order of "
		+ "operations. The GEMDAS rule.",
		[
			"Grouping symbols first: (2 + 3) × 4 = 5 × 4 = 20.",
			"Then exponents: 3 + 2² = 3 + 4 = 7.",
			"Then Multiply / Divide, left to right.",
			"Finally Add / Subtract, left to right: 3 + 6 × 2 = 3 + 12 = 15.",
		],
		["10 − (5 − 2) = 10 − 3 = 7", "16 ÷ 4 × 2 = 8", "3 + 2² = 7"],
		QuestionGen.RULES.pemdas,
	],
]

## Which station teaches each topic, for its colour: basics are Station 1
## (blue), exponents Station 3 (red), order of operations Station 2 (yellow).
const TOPIC_COLOUR := [Pal.INFO, Pal.WRONG, Pal.AMBER]

var _heading: Label
var _content: Label
var _examples: Label
var _rule: Label
var _tab_buttons: Array = []
var _scroll: ScrollContainer


func setup(_data: Dictionary) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()


## Topics down the left as cards in their station's colour, the lesson in a
## reading pane beside them. The tabs across the top were three equal buttons
## (one of them always red, whichever was open) over a pane that scrolled
## 150px of text; a column of topics leaves the reading its full height.
func _build() -> void:
	# No scrim: Main's moving scene is the background (Backdrop.gd).
	var box := Ui.back_panel(self, Vector2(600, 330), "Learn before you adventure",
		func() -> void: main.open("home"))
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body)

	var topics := VBoxContainer.new()
	topics.custom_minimum_size = Vector2(160, 0)
	topics.add_theme_constant_override("separation", 6)
	body.add_child(topics)
	for i in LESSONS.size():
		var b := Button.new()
		b.text = LESSONS[i][0]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(160, 44)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", Pal.SMALL)
		b.pressed.connect(func(idx := i) -> void: _show(idx))
		Ui.click(b)
		_tab_buttons.append(b)
		topics.add_child(b)

	_scroll = ScrollContainer.new()
	DragScroll.attach(_scroll)
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(_scroll)
	var sub := VBoxContainer.new()
	sub.add_theme_constant_override("separation", 8)
	sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(sub)
	_heading = Art.label("", Pal.H2, Pal.TITLE)
	_content = Art.label("", Pal.BODY, Pal.INK)
	_examples = Art.label("", Pal.LABEL, Pal.BRONZE)
	_rule = Art.label("", Pal.SMALL, Pal.INFO)
	for l in [_heading, _content, _examples, _rule]:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(WRAP_W, 0)
	sub.add_child(_heading)
	sub.add_child(_content)
	# Worked examples on a card of their own: the part a student looks back at.
	var card := PanelContainer.new()
	var face := StyleBoxFlat.new()
	face.bg_color = Pal.PARCHMENT.darkened(0.06)
	face.set_corner_radius_all(4)
	face.set_content_margin_all(8)
	card.add_theme_stylebox_override("panel", face)
	card.add_child(_examples)
	sub.add_child(card)
	sub.add_child(_rule)

	_show(0)


func _show(idx: int) -> void:
	var l: Array = LESSONS[idx]
	var bullets := ""
	for gd in l[3]:
		bullets += "•  " + gd + "\n"
	_heading.text = l[1]
	_heading.add_theme_color_override("font_color", TOPIC_COLOUR[idx].darkened(0.2))
	_content.text = "%s\n\n%s" % [l[2], bullets.strip_edges()]
	_examples.text = "Worked examples\n" + "\n".join(l[4])
	_rule.text = "Rule reminder: " + l[5]
	_scroll.scroll_vertical = 0
	# The open topic filled in its colour; the rest edged in theirs.
	for i in LESSONS.size():
		var b: Button = _tab_buttons[i]
		var on := i == idx
		for st in ["normal", "hover", "pressed", "focus"]:
			var face := StyleBoxFlat.new()
			face.bg_color = Color(TOPIC_COLOUR[i], 0.22 if on else (0.1 if st == "hover" else 0.04))
			face.border_color = TOPIC_COLOUR[i]
			face.border_width_left = 6
			face.set_border_width(SIDE_TOP, 2 if on else 1)
			face.set_border_width(SIDE_RIGHT, 2 if on else 1)
			face.set_border_width(SIDE_BOTTOM, 2 if on else 1)
			face.set_corner_radius_all(4)
			face.content_margin_left = 12
			face.content_margin_right = 6
			b.add_theme_stylebox_override(st, face)
		for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(c, Pal.TITLE if on else Pal.INK)
