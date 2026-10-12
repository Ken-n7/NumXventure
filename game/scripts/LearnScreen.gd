extends Control

## Review hub: pre-game lessons for the three competencies. Per the design,
## this exists to study *before* the adventure, away from the timer.

var main: Control

const WRAP_W := 540.0
const GAP := 8
## Maths is set bigger than the prose, as on the posters -- and must be: an
## exponent is a digit raised beside it, and nothing renders under
## `Art.MIN_FONT` (the font's own superscripts are too small to read).
const MATH := 20
const RAISED := Art.MIN_FONT
const SUPERS := "⁰¹²³⁴⁵⁶⁷⁸⁹⁻ⁿ"
const PLAIN := "0123456789−n"

## One lesson per station. Exponents come before the order of operations
## here (client, 2026-10-12), though the adventure meets them the other way
## round. The tab is
## short (a Button's minimum size grows with its text); the heading and intro
## are the mockup's own words, verbatim, because §1 makes the PDFs a wording
## contract. The sections are the client's lesson posters (learn/, 2026-10-01)
## -- their rules and worked examples, set in our parchment rather than pasted
## in as pictures.
##
## A section is a title and its blocks, each `[kind, ...]`:
##   ["text", s]                     a paragraph
##   ["rule", s]                     a rule, set heavier
##   ["bullets", [s, ...]]
##   ["cases", [[signs, example, note], ...]]   two to a row; `signs` is
##        "+ + +" style (left, operator, right, result) or plain text
##   ["kcc", first, op, second]      Keep-Change-Change as three columns
##   ["letters", [[L, word, detail], ...]]       GEMDAS
##   ["steps", [[tag, text, result], ...]]       a worked example, line by line
##   ["numbered", [[rule, example], ...]]
##   ["card", [s, ...]]              a boxed reminder
static var LESSONS := [
	{
		"tab": "Basic Operations",
		"colour": Pal.INFO,
		"heading": "Basic Operations on Integers",
		"intro": "This involves addition, subtraction, multiplication, and division of "
			+ "positive and negative whole numbers. Understanding these operations "
			+ "and their rules will help you solve numerical expressions accurately "
			+ "and confidently.",
		"sections": [
			["Addition", [
				["rule", "Rule 1: When the integers have like signs, ADD the numbers and copy the common sign."],
				["cases", [
					["+ + + +", "8 + 5 = 13", "8 and 5 are both positive: add them and keep the +."],
					["− + − −", "(−10) + (−9) = −19", "10 and 9 are both negative: add them and keep the −."],
				]],
				["rule", "Rule 2: When the integers have unlike signs, SUBTRACT the numbers and use the sign of the number with the greater absolute value."],
				["cases", [
					["+ + − +", "4 + (−2) = 2", "Subtract 2 from 4, then copy the sign of 4: it is the bigger."],
					["+ + − −", "7 + (−9) = −2", "Subtract 7 from 9, then copy the sign of 9: it is the bigger."],
				]],
			]],
			["Subtraction", [
				["rule", "Step 1: Keep-Change-Change (KCC)"],
				["bullets", ["Keep the 1st integer the same.", "Change the subtraction sign to addition.",
					"Change the sign of the second integer."]],
				["rule", "Step 2: Follow the rules for addition"],
				["bullets", ["Same signs: ADD and keep the sign.",
					"Different signs: SUBTRACT and copy the sign of the number with the greater absolute value."]],
				["text", "Example: 7 − 3 = ?"],
				["kcc", "7", "+", "(−3)"],
				["steps", [["", "Unlike signs: subtract, then copy the sign of 7.", "→ 7 + (−3) = 4"]]],
				["text", "Example: 5 − (−2) = ?"],
				["kcc", "5", "+", "2"],
				["steps", [["", "Like signs: add and keep the +.", "→ 5 + 2 = 7"]]],
			]],
			["Multiplication", [
				["rule", "Rule 1: Two numbers with the same sign: the product is positive."],
				["cases", [
					["+ × + +", "(6)(9) = 54", ""],
					["− × − +", "(−7)(−6) = 42", ""],
				]],
				["rule", "Rule 2: Two numbers with different signs: the product is negative."],
				["cases", [
					["+ × − −", "(5)(−2) = −10", ""],
					["− × + −", "(−8)(5) = −40", ""],
				]],
				["rule", "Rule 3: Any number multiplied by 0 gives a product of 0."],
				["cases", [
					["(0)(any number) = 0", "(0)(−2) = 0", ""],
					["(any number)(0) = 0", "(−8)(0) = 0", ""],
				]],
			]],
			["Division", [
				["rule", "Rule 1: Two numbers with the same sign: the quotient is always positive."],
				["cases", [
					["+ ÷ + +", "45 ÷ 5 = 9", ""],
					["− ÷ − +", "(−51) ÷ (−3) = 17", ""],
				]],
				["rule", "Rule 2: Two numbers with different signs: the quotient is always negative."],
				["cases", [
					["+ ÷ − −", "273 ÷ (−21) = −13", ""],
					["− ÷ + −", "(−57) ÷ 19 = −3", ""],
				]],
				["rule", "Rule 3: Zero divided by a nonzero number is 0; nothing can be divided by 0."],
				["cases", [
					["0 ÷ (nonzero number) = 0", "0 ÷ 35 = 0", ""],
					["(any number) ÷ 0 = undefined", "56 ÷ 0 = undefined", ""],
				]],
			]],
		],
	},
	{
		"tab": "Exponential Notation",
		"colour": Pal.WRONG,
		"heading": "Understanding Numbers Expressed in Exponential Notation",
		"intro": "The mastery of basic multiplication facts is necessary. You should not "
			+ "multiply the base and its exponent but multiply the base by the "
			+ "number of times as shown in the exponent.",
		"sections": [
			["Remember these simple rules", [
				["numbered", [
					["Exponential form uses a base and an exponent.", "2³"],
					["The base is the number being multiplied repeatedly.", "In 2³, 2 is the base."],
					["The exponent tells how many times the base is used as a factor.", "2³ = 2 × 2 × 2"],
					["To change exponential form to expanded form, multiply the base by itself according to the exponent.", "3⁴ = 3 × 3 × 3 × 3"],
					["To change expanded form to exponential form, identify the repeated factor and count how many times it appears.", "5 × 5 × 5 = 5³"],
					["To find the value of an exponential number, perform the repeated multiplication.", "4² = 4 × 4 = 16"],
					["Do not multiply the base and exponent directly.", "3⁴ means 3 × 3 × 3 × 3, not 3 × 4."],
				]],
			]],
			["Quick reminder", [
				["card", ["Base = the number being repeated", "Exponent = the number of repetitions",
					"Value = the answer after multiplying"]],
			]],
		],
	},
	{
		"tab": "Order of Operations",
		"colour": Pal.AMBER,
		"heading": "Order of Operations on Integers",
		"intro": "Expressions can be solved by following the rules on order of "
			+ "operations. The GEMDAS rule.",
		"sections": [
			["GEMDAS", [
				["letters", [
					["G", "Grouping", "The three pairs of grouping symbols: ( ) parentheses, [ ] brackets, { } braces."],
					["E", "Exponents", ""],
					["M", "Multiplication", ""],
					["D", "Division", ""],
					["A", "Addition", ""],
					["S", "Subtraction", ""],
				]],
				["text", "Multiplication and division go together, left to right; so do addition and subtraction."],
			]],
			["Worked example", [
				["rule", "8 + (6 − 2) × 2² ÷ 4 − 3"],
				["steps", [
					["G", "Solve what is inside the parentheses first.", "(6 − 2) = 4 → 8 + 4 × 2² ÷ 4 − 3"],
					["E", "Solve the exponent next.", "2² = 4 → 8 + 4 × 4 ÷ 4 − 3"],
					["M & D", "Multiply and divide, left to right.", "4 × 4 = 16 → 8 + 16 ÷ 4 − 3"],
					["", "", "16 ÷ 4 = 4 → 8 + 4 − 3"],
					["A & S", "Add and subtract, left to right.", "8 + 4 = 12 → 12 − 3 = 9"],
				]],
				["card", ["Final answer:  9"]],
			]],
		],
	},
]

var _heading: Label
var _content: Label            # the mockup's intro: e2e reads it
var _jumps: HFlowContainer     # a chip per section
var _body: VBoxContainer       # the sections, rebuilt per lesson
var _tab_buttons: Array = []
var _tab_line: ColorRect       # under the tabs, in the open one's colour
const TAB_H := 34              # the open tab; the rest stand TAB_DROP lower
const TAB_DROP := 6
var _scroll: ScrollContainer


func setup(_data: Dictionary) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()


## A tab per station across the top, in its colour, and the lesson under them
## the panel's full width (client, 2026-10-01): the posters' two-up tables need
## the room a column of topics down the side took.
func _build() -> void:
	# No scrim: Main's moving scene is the background (Backdrop.gd).
	var box := Ui.back_panel(self, Vector2(600, 330), "Learn before you adventure",
		func() -> void: main.open("home"))
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 0)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body)

	# Folder tabs: the open one taller, filled, and joined to the line under
	# the row; the rest lower and paler, so they read as the ones to press.
	var topics := HBoxContainer.new()
	topics.add_theme_constant_override("separation", 4)
	topics.custom_minimum_size = Vector2(0, TAB_H)
	body.add_child(topics)
	for i in LESSONS.size():
		var b := Button.new()
		b.text = "%d · %s" % [i + 1, LESSONS[i].tab]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_SHRINK_END
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.add_theme_font_size_override("font_size", Art.MIN_FONT)
		b.pressed.connect(func(idx := i) -> void: _show(idx))
		Ui.click(b)
		_tab_buttons.append(b)
		topics.add_child(b)
	_tab_line = ColorRect.new()
	_tab_line.custom_minimum_size = Vector2(0, 3)
	body.add_child(_tab_line)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 6)
	body.add_child(gap)

	_scroll = ScrollContainer.new()
	DragScroll.attach(_scroll)
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(_scroll)
	var sub := VBoxContainer.new()
	sub.add_theme_constant_override("separation", GAP)
	sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(sub)
	_heading = _wrap(Art.label("", Pal.H2, Pal.TITLE))
	_content = _wrap(Art.label("", Pal.BODY, Pal.INK))
	_jumps = HFlowContainer.new()
	_jumps.add_theme_constant_override("h_separation", 6)
	_jumps.add_theme_constant_override("v_separation", 4)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", GAP)
	for c in [_heading, _jumps, _content, _body]:
		sub.add_child(c)

	_show(0)


func _show(idx: int) -> void:
	var l: Dictionary = LESSONS[idx]
	var colour: Color = l.colour
	_heading.text = l.heading
	_heading.add_theme_color_override("font_color", colour.darkened(0.2))
	_content.text = l.intro
	for c in _body.get_children() + _jumps.get_children():
		c.queue_free()
	for s: Array in l.sections:
		var at := _section(s[0], colour)
		for block: Array in s[1]:
			_block(block, colour)
		_jumps.add_child(_jump(s[0], colour, at))
	_scroll.scroll_vertical = 0
	_tab_line.color = colour
	for i in LESSONS.size():
		var b: Button = _tab_buttons[i]
		var on := i == idx
		var c: Color = LESSONS[i].colour
		b.custom_minimum_size = Vector2(0, TAB_H if on else TAB_H - TAB_DROP)
		for st in ["normal", "hover", "pressed"]:
			var face := StyleBoxFlat.new()
			face.bg_color = c.lerp(Pal.PARCHMENT, 0.35) if on \
				else Pal.PARCHMENT.darkened(0.08).lerp(c, 0.28 if st == "hover" else 0.12)
			face.border_color = c if on else Color(c, 0.7)
			face.set_border_width_all(2 if on else 1)
			face.border_width_bottom = 0
			face.corner_radius_top_left = 6
			face.corner_radius_top_right = 6
			face.content_margin_left = 6
			face.content_margin_right = 6
			b.add_theme_stylebox_override(st, face)
		for f in ["font_color", "font_hover_color", "font_pressed_color"]:
			b.add_theme_color_override(f, Pal.TITLE if on else Pal.INK_MUTED)


# --- Blocks --------------------------------------------------------------------
## A section's title, ruled off, in the station's colour. Returns the row, for
## its jump chip to scroll to.
func _section(text: String, colour: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(Art.title(Art.label(text, Pal.BODY + 2, colour.darkened(0.25))))
	var rule := ColorRect.new()
	rule.color = Color(colour, 0.5)
	rule.custom_minimum_size = Vector2(0, 2)
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(rule)
	_body.add_child(row)
	return row


## A chip under the heading that scrolls its section into view.
func _jump(text: String, colour: Color, to: Control) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", Pal.SMALL)
	for st in ["normal", "hover", "pressed"]:
		var face := StyleBoxFlat.new()
		face.bg_color = Color(colour, 0.25 if st == "hover" else 0.12)
		face.border_color = Color(colour, 0.8)
		face.set_border_width_all(1)
		face.set_corner_radius_all(10)
		face.content_margin_left = 10
		face.content_margin_right = 10
		face.content_margin_top = 2
		face.content_margin_bottom = 2
		b.add_theme_stylebox_override(st, face)
	for f in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(f, Pal.TITLE)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(func() -> void: _scroll.scroll_vertical = int(to.position.y + _body.position.y))
	Ui.click(b)
	return b


func _block(b: Array, colour: Color) -> void:
	match b[0]:
		"text":
			_body.add_child(_wrap(Art.label(b[1], Pal.BODY, Pal.INK)))
		"rule":
			_body.add_child(_text(b[1], Pal.BODY if b[1].contains(":") else MATH, Pal.TITLE))
		"bullets":
			_body.add_child(_wrap(Art.label("•  " + "\n•  ".join(b[1]), Pal.BODY, Pal.INK)))
		"cases":
			var grid := GridContainer.new()
			grid.columns = 2
			grid.add_theme_constant_override("h_separation", GAP)
			grid.add_theme_constant_override("v_separation", GAP)
			for c: Array in b[1]:
				grid.add_child(_case(c, colour))
			_body.add_child(grid)
		"kcc":
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", GAP)
			for pair in [["Keep", b[1]], ["Change", b[2]], ["Change", b[3]]]:
				var v := _card(colour, 0.08)
				v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				v.get_child(0).add_child(Art.label(pair[0], Pal.SMALL, Pal.INK_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
				v.get_child(0).add_child(Art.label(pair[1], MATH, Pal.TITLE, HORIZONTAL_ALIGNMENT_CENTER))
				row.add_child(v)
			_body.add_child(row)
		"letters":
			var list := VBoxContainer.new()
			list.add_theme_constant_override("separation", 2)
			for l: Array in b[1]:
				var row := HBoxContainer.new()
				row.add_theme_constant_override("separation", 10)
				var letter := Art.title(Art.label(l[0], 26, Pal.GOLD_DIM, HORIZONTAL_ALIGNMENT_CENTER))
				letter.custom_minimum_size = Vector2(28, 0)
				row.add_child(letter)
				var words := VBoxContainer.new()
				words.add_theme_constant_override("separation", -2)
				words.alignment = BoxContainer.ALIGNMENT_CENTER
				words.add_child(Art.label(l[1], Pal.BODY + 1, Pal.TITLE))
				if l[2] != "":
					var d := Art.label(l[2], Pal.SMALL, Pal.INK_MUTED)
					d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					d.custom_minimum_size = Vector2(WRAP_W - 40, 0)
					words.add_child(d)
				row.add_child(words)
				list.add_child(row)
			_body.add_child(list)
		"steps":
			for st: Array in b[1]:
				var row := HBoxContainer.new()
				row.add_theme_constant_override("separation", 8)
				var tag := Art.title(Art.label(st[0], Pal.BODY, colour.darkened(0.25)))
				tag.custom_minimum_size = Vector2(52, 0)
				row.add_child(tag)
				var lines := VBoxContainer.new()
				lines.add_theme_constant_override("separation", 0)
				if st[1] != "":
					lines.add_child(_text(st[1], Pal.SMALL, Pal.INK, HORIZONTAL_ALIGNMENT_LEFT, WRAP_W - 60))
				lines.add_child(_text(st[2], MATH, Pal.BRONZE, HORIZONTAL_ALIGNMENT_LEFT, WRAP_W - 60))
				row.add_child(lines)
				_body.add_child(row)
		"numbered":
			for i in b[1].size():
				var n: Array = b[1][i]
				var row := HBoxContainer.new()
				row.add_theme_constant_override("separation", 6)
				var num := Art.title(Art.label("%d." % (i + 1), Pal.BODY, colour.darkened(0.25)))
				num.custom_minimum_size = Vector2(20, 0)
				row.add_child(num)
				var lines := VBoxContainer.new()
				lines.add_theme_constant_override("separation", 0)
				lines.add_child(_text(n[0], Pal.BODY, Pal.INK, HORIZONTAL_ALIGNMENT_LEFT, WRAP_W - 26))
				lines.add_child(_text("Example: " + n[1], MATH, Pal.BRONZE, HORIZONTAL_ALIGNMENT_LEFT, WRAP_W - 26))
				row.add_child(lines)
				_body.add_child(row)
		"card":
			var c := _card(colour, 0.14)
			for s: String in b[1]:
				c.get_child(0).add_child(_text(s, Pal.BODY + 1, Pal.TITLE, HORIZONTAL_ALIGNMENT_CENTER, WRAP_W - 16))
			_body.add_child(c)


## One case of a sign rule, as the posters lay them out: the signs on top,
## the worked example under, and why.
func _case(c: Array, colour: Color) -> Control:
	var card := _card(colour, 0.06)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2((WRAP_W - GAP) / 2.0, 0)
	var v: VBoxContainer = card.get_child(0)
	var parts := String(c[0]).split(" ")
	if parts.size() == 4 and parts[0] in ["+", "−"]:
		var signs := HBoxContainer.new()
		signs.alignment = BoxContainer.ALIGNMENT_CENTER
		signs.add_theme_constant_override("separation", 5)
		signs.add_child(_sign(parts[0]))
		signs.add_child(Art.label(parts[1], Pal.BODY + 2, Pal.TITLE))
		signs.add_child(_sign(parts[2]))
		signs.add_child(Art.label("=", Pal.BODY + 2, Pal.TITLE))
		signs.add_child(_sign(parts[3]))
		v.add_child(signs)
	else:
		v.add_child(_wrap(Art.label(c[0], Pal.SMALL, Pal.INK_MUTED, HORIZONTAL_ALIGNMENT_CENTER), card.custom_minimum_size.x - 16))
	v.add_child(_text(c[1], MATH, Pal.BRONZE, HORIZONTAL_ALIGNMENT_CENTER, card.custom_minimum_size.x - 16))
	if c[2] != "":
		v.add_child(_wrap(Art.label(c[2], Pal.SMALL, Pal.INK_MUTED), card.custom_minimum_size.x - 16))
	return card


## A sign as a coloured disc: blue for positive, red for negative.
func _sign(s: String) -> Control:
	var disc := PanelContainer.new()
	var face := StyleBoxFlat.new()
	face.bg_color = Pal.INFO_DEEP if s == "+" else Pal.WRONG
	face.set_corner_radius_all(9)
	disc.add_theme_stylebox_override("panel", face)
	disc.custom_minimum_size = Vector2(18, 18)
	var l := Art.label(s, Pal.BODY, Pal.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	disc.add_child(l)
	disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return disc


## A parchment card tinted with the station's colour; its one child is the
## VBox to fill.
func _card(colour: Color, tint: float) -> PanelContainer:
	var card := PanelContainer.new()
	var face := StyleBoxFlat.new()
	face.bg_color = Pal.PARCHMENT.darkened(0.04).lerp(colour, tint)
	face.border_color = Color(colour, 0.45)
	face.set_border_width_all(1)
	face.set_corner_radius_all(4)
	face.set_content_margin_all(8)
	card.add_theme_stylebox_override("panel", face)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	card.add_child(v)
	return card


## `s` as wrapped text. With an exponent in it (2³), word by word in a flow,
## each exponent a plain digit at `RAISED` set at the top of its line.
func _text(s: String, size: int, colour: Color, align := HORIZONTAL_ALIGNMENT_LEFT, w := WRAP_W) -> Control:
	if not Array(s.split("")).any(func(ch: String) -> bool: return SUPERS.contains(ch)):
		return _wrap(Art.label(s, size, colour, align), w)
	var flow := HFlowContainer.new()
	flow.custom_minimum_size = Vector2(w, 0)
	flow.alignment = FlowContainer.ALIGNMENT_CENTER if align == HORIZONTAL_ALIGNMENT_CENTER \
		else FlowContainer.ALIGNMENT_BEGIN
	# A space as wide as the face's own, so a line with an exponent is spaced
	# like the plain lines round it.
	var face: Font = load(Art.TEXT_FONT)
	flow.add_theme_constant_override("h_separation",
		roundi(face.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x))
	flow.add_theme_constant_override("v_separation", 0)
	for word in s.split(" ", false):
		var token := HBoxContainer.new()
		token.add_theme_constant_override("separation", 0)
		var run := ""
		var up := false
		for ch in word + " ":                       # a space flushes the last run
			var k := SUPERS.find(ch)
			if (k >= 0) != up or ch == " ":
				if run != "":
					var part := Art.label(run, RAISED if up else size, colour)
					if up:
						part.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
					token.add_child(part)
				run = ""
				up = k >= 0
			if ch != " ":
				run += PLAIN[k] if k >= 0 else ch
		flow.add_child(token)
	return flow


func _wrap(l: Label, w := WRAP_W) -> Label:
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(w, 0)
	return l
