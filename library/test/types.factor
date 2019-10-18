IN: scratchpad
USE: arithmetic
USE: compiler
USE: lists
USE: stack
USE: stdio
USE: strings
USE: test

"Checking type coercion." print

[ 32 ] [ " " ] [ >char >number ] test-word
[ 32 ] [ " " ] [ >char >fixnum ] test-word

"Type coercion checks done." print
