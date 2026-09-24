extends Control

## Review hub: pre-game lessons for the three competencies. Per the design,
## this exists to study *before* the adventure, away from the timer.

var main: Control

const WRAP_W := 540.0

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

var _content: Label
var _examples: Label
var _rule: Label
var _tab_buttons: Array = []


func setup(_data: Dictionary) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()


func _build() -> void:
	Ui.dim(self)
	var box := Ui.screen_panel(self, Vector2(600, 320), "Learn before you adventure")
	box.add_theme_constant_override("separation", 8)

	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 8)
	for i in LESSONS.size():
		var b := Ui.button(LESSONS[i][0], 150, Ui.H, Ui.SMALL_RED if i == 1 else Ui.SMALL)
		b.pressed.connect(func(idx := i) -> void: _show(idx))
		_tab_buttons.append(b)
		tabs.add_child(b)
	box.add_child(tabs)

	var scroll := Ui.scroll(box, 150)

	var sub := VBoxContainer.new()
	sub.add_theme_constant_override("separation", 10)
	sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub.custom_minimum_size = Vector2(WRAP_W, 0)
	_content = Art.label("", Pal.BODY, Pal.INK)
	_examples = Art.label("", Pal.H2, Pal.BRONZE, HORIZONTAL_ALIGNMENT_CENTER)
	_rule = Art.label("", Pal.TINY, Pal.INFO, HORIZONTAL_ALIGNMENT_CENTER)
	for l in [_content, _examples, _rule]:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(WRAP_W, 0)
		sub.add_child(l)
	scroll.add_child(sub)

	var back := Ui.button("Back", Ui.W_WIDE, Ui.H, Ui.RED)
	back.pressed.connect(func() -> void: main.open("home"))
	Ui.centre_row(box, back)

	_show(0)


func _show(idx: int) -> void:
	var l: Array = LESSONS[idx]
	var bullets := ""
	for gd in l[3]:
		bullets += "•  " + gd + "\n"
	_content.text = "%s\n%s\n\n%s" % [l[1], l[2], bullets]
	_examples.text = "Worked examples:\n" + "\n".join(l[4])
	_rule.text = "Rule reminder: " + l[5]
	for i in LESSONS.size():
		_tab_buttons[i].add_theme_color_override("font_color",
				Pal.CREAM if i == idx else Color(1, 1, 1, 0.96))