IN: scratchpad
USE: interpreter
USE: test
USE: namespaces
USE: combinators
USE: stack
USE: math
USE: lists
USE: kernel

[ { 1 2 3 } ] [
    init-interpreter [ 1 2 3 ] run meta-d get
] unit-test

[ { "Yo" 2 } ] [
    init-interpreter [ 2 >r "Yo" r> ] run meta-d get
] unit-test

[ { 2 } ] [
    init-interpreter [ t [ 2 ] [ "hi" ] ifte ] run meta-d get
] unit-test

[ { "hi" } ] [
    init-interpreter [ f [ 2 ] [ "hi" ] ifte ] run meta-d get
] unit-test

[ { 4 } ] [
    init-interpreter [ 2 2 fixnum+ ] run meta-d get
] unit-test

[ { "Hey" "there" } ] [
    init-interpreter [ [ "Hey" | "there" ] uncons ] run meta-d get
] unit-test

[ { t } ] [
    init-interpreter [ "XYZ" "XYZ" = ] run meta-d get
] unit-test

[ { f } ] [
    init-interpreter [ "XYZ" "XuZ" = ] run meta-d get
] unit-test

[ { #{ 1 1.5 } { } #{ 1 1.5 } { } } ] [
    init-interpreter [ #{ 1 1.5 } { } 2dup ] run meta-d get
] unit-test

[ { 4 } ] [
    init-interpreter [ 2 2 + ] run meta-d get
] unit-test
