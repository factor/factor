IN: scratchpad
USE: interpreter
USE: test
USE: namespaces
USE: stdio
USE: prettyprint
USE: math
USE: math-internals
USE: lists
USE: kernel

: test-interpreter
    init-interpreter run meta-d get ;

[ { 1 2 3 } ] [
    [ 1 2 3 ] test-interpreter
] unit-test

[ { "Yo" 2 } ] [
    [ 2 >r "Yo" r> ] test-interpreter
] unit-test

[ { 2 } ] [
    [ t [ 2 ] [ "hi" ] ifte ] test-interpreter
] unit-test

[ { "hi" } ] [
    [ f [ 2 ] [ "hi" ] ifte ] test-interpreter
] unit-test

[ { 4 } ] [
    [ 2 2 fixnum+ ] test-interpreter
] unit-test

[ { "Hey" "there" } ] [
    [ [[ "Hey" "there" ]] uncons ] test-interpreter
] unit-test

[ { t } ] [
    [ "XYZ" "XYZ" = ] test-interpreter
] unit-test

[ { f } ] [
    [ "XYZ" "XuZ" = ] test-interpreter
] unit-test

[ { #{ 1 1.5 } { } #{ 1 1.5 } { } } ] [
    [ #{ 1 1.5 } { } 2dup ] test-interpreter
] unit-test

[ { 4 } ] [
    [ 2 2 + ] test-interpreter
] unit-test

[ { "4\n" } ] [
    [ [ 2 2 + . ] with-string ] test-interpreter
] unit-test
