USING: vlists kernel persistent.sequences arrays tools.test
namespaces accessors sequences assocs ;

{ { "hi" "there" } }
[ VL{ } "hi" swap ppush "there" swap ppush >array ] unit-test

{ VL{ "hi" "there" "foo" } VL{ "hi" "there" "bar" } t }
[
    VL{ } "hi" swap ppush "there" swap ppush "v" set
    "foo" "v" get ppush
    "bar" "v" get ppush
    dup "baz" over ppush [ vector>> ] bi@ eq?
] unit-test

{ "foo" VL{ "hi" "there" } t }
[
    VL{ "hi" "there" "foo" } dup "v" set
    [ last ] [ ppop ] bi
    dup "v" get [ vector>> ] bi@ eq?
] unit-test

[ VL{ } 3 suffix! ] must-fail

[ 4 VL{ "hi" } set-first ] must-fail

{ 5 t } [
    "rice" VA{ { "rice" 5 } { "beans" 10 } } at*
] unit-test

{ 6 t } [
    "rice" VA{ { "rice" 5 } { "beans" 10 } { "rice" 6 } } at*
] unit-test

{ 3 } [
    VA{ { "rice" 5 } { "beans" 10 } { "rice" 6 } } assoc-size
] unit-test

{ f f } [
    "meat" VA{ { "rice" 5 } { "beans" 10 } { "rice" 6 } } at*
] unit-test
