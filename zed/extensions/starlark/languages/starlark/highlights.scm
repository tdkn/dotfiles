; Identifiers
(identifier) @variable

((identifier) @constant
 (#match? @constant "^[A-Z][A-Z_0-9]*$"))

((identifier) @type
 (#match? @type "^[A-Z].*[a-z]"))

((identifier) @constant.builtin
 (#match? @constant.builtin "^__[a-zA-Z0-9_]*__$"))

(attribute
  attribute: (identifier) @property)

; Definitions and calls
(function_definition
  name: (identifier) @function)

(call
  function: (identifier) @function)

(call
  function: (attribute
    attribute: (identifier) @function))

((call
  function: (identifier) @keyword
  arguments: (argument_list))
 (#eq? @keyword "load")
 (#set! "priority" 101))

; Parameters
(parameters
  (identifier) @variable.parameter)

(lambda_parameters
  (identifier) @variable.parameter)

(lambda_parameters
  (tuple_pattern
    (identifier) @variable.parameter))

(keyword_argument
  name: (identifier) @variable.parameter)

(default_parameter
  name: (identifier) @variable.parameter)

(typed_parameter
  (identifier) @variable.parameter)

(typed_default_parameter
  (identifier) @variable.parameter)

(parameters
  (list_splat_pattern
    (identifier) @variable.parameter))

(parameters
  (dictionary_splat_pattern
    (identifier) @variable.parameter))

; Literals
(none) @constant.builtin
[(true) (false)] @boolean

(integer) @number
(float) @number

(string) @string
[
  (escape_sequence)
  (escape_interpolation)
] @string.escape

(comment) @comment

; Operators
[
  "-"
  "-="
  ":="
  "!="
  "*"
  "**"
  "**="
  "*="
  "/"
  "//"
  "//="
  "/="
  "&"
  "&="
  "%"
  "%="
  "^"
  "^="
  "+"
  "+="
  "<"
  "<<"
  "<<="
  "<="
  "<>"
  "="
  "=="
  ">"
  ">="
  ">>"
  ">>="
  "@"
  "@="
  "|"
  "|="
  "~"
  "->"
] @operator

[
  "and"
  "in"
  "not"
  "or"
] @operator

; Keywords
[
  "def"
  "lambda"
  "pass"
  "return"
  "if"
  "elif"
  "else"
  "for"
  "break"
  "continue"
] @keyword

; Punctuation
["(" ")" "[" "]" "{" "}"] @punctuation.bracket

(interpolation
  "{" @punctuation.special
  "}" @punctuation.special)

["," "." ":" ";" (ellipsis)] @punctuation.delimiter

; Starlark-specific grammar nodes
(assert_keyword) @keyword
(assert_builtin) @function

((call
  function: (identifier) @_func
  arguments: (argument_list
    (keyword_argument
      name: (identifier) @property)))
 (#eq? @_func "struct"))
