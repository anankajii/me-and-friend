class_name PythonCodeHighlighter
extends SyntaxHighlighter

const KEYWORDS := {
	"def": Color("f18bbd"), "if": Color("f18bbd"), "elif": Color("f18bbd"),
	"else": Color("f18bbd"), "for": Color("f18bbd"), "while": Color("f18bbd"),
	"in": Color("f18bbd"), "return": Color("f18bbd"), "import": Color("f18bbd"),
	"from": Color("f18bbd"), "class": Color("f18bbd"), "and": Color("f18bbd"),
	"or": Color("f18bbd"), "not": Color("f18bbd"), "pass": Color("f18bbd")
}
const BUILT_INS := {"print": Color("ff9f82"), "input": Color("ff9f82"), "len": Color("ff9f82"), "range": Color("ff9f82"), "str": Color("ff9f82"), "int": Color("ff9f82"), "float": Color("ff9f82")}
const CONSTANTS := {"True": Color("ffd56a"), "False": Color("ffd56a"), "None": Color("ffd56a")}

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var source := get_text_edit().get_line(line)
	var colors := {}
	var index := 0
	var expects_function_name := false

	while index < source.length():
		var character := source[index]
		if character == "#":
			colors[index] = {"color": Color("6fa987")}
			break
		if character == "\"" or character == "'":
			var quote := character
			var end := index + 1
			while end < source.length() and source[end] != quote:
				end += 1
			colors[index] = {"color": Color("88d498")}
			index = end + 1
			continue
		if character.is_valid_int():
			colors[index] = {"color": Color("ffd56a")}
			while index < source.length() and (source[index].is_valid_int() or source[index] == "."):
				index += 1
			continue
		if character == "_" or character.is_valid_identifier():
			var start := index
			while index < source.length() and (source[index] == "_" or source[index].is_valid_identifier() or source[index].is_valid_int()):
				index += 1
			var token := source.substr(start, index - start)
			if KEYWORDS.has(token):
				colors[start] = {"color": KEYWORDS[token]}
				expects_function_name = token == "def"
			elif BUILT_INS.has(token):
				colors[start] = {"color": BUILT_INS[token]}
			elif CONSTANTS.has(token):
				colors[start] = {"color": CONSTANTS[token]}
			elif expects_function_name:
				colors[start] = {"color": Color("8fc9ff")}
				expects_function_name = false
			else:
				colors[start] = {"color": Color("d9e5f2")}
			continue
		index += 1

	return colors
