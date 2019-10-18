IN: scratchpad
USE: compiler
USE: namespaces
USE: stdio
USE: streams
USE: strings
USE: test
USE: words
USE: vocabularies

"Testing string words." print

[ [ 2 1 0 0 ] ] [ [ fill ] ] [ balance>list ] test-word
[ "         " ] [ 9 " " ] [ fill ] test-word
[ ""          ] [ 0 "X" ] [ fill ] test-word

: strstream-test ( -- )
    1024 <string-output-stream> "strstream" set
    "Hello " "strstream" get fwrite
    "world." "strstream" get fwrite
    "strstream" get stream>str ;

[ "Hello world." ] [ ] [ strstream-test ] test-word

[ [ 1 1 0 0 ] ] [ [ cat ] ] [ balance>list ] test-word
[ "abc" ] [ [ "a" "b" "c" ] ] [ cat ] test-word

[ [ 1 1 0 0 ] ] [ [ str-length ] ] [ balance>list ] test-word
"str-length" [ "strings" ] search must-compile

[ [ 1 1 0 0 ] ] [ [ >char ] ] [ balance>list ] test-word
">char" [ "strings" ] search must-compile

"String tests done." print
