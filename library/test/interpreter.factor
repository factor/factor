USING: errors interpreter io kernel lists math math-internals
namespaces prettyprint sequences test ;
IN: temporary

: done-cf? ( -- ? ) meta-cf get not ;
: done? ( -- ? ) done-cf? meta-r get length 0 = and ;

: interpret ( quot -- )
    #! The quotation is called with each word as its executed.
    done? [ drop ] [ [ next swap call ] keep interpret ] if ;

: run ( -- ) [ do ] interpret ;

: init-interpreter ( -- )
    { } clone meta-r set
    { } clone meta-d set
    namestack meta-n set
    catchstack meta-c set
    meta-cf off
    meta-executing off ;

: test-interpreter
    init-interpreter meta-cf set run meta-d get ;

[ { 1 2 3 } ] [
    [ 1 2 3 ] test-interpreter
] unit-test

[ { "Yo" 2 } ] [
    [ 2 >r "Yo" r> ] test-interpreter
] unit-test

[ { 2 } ] [
    [ t [ 2 ] [ "hi" ] if ] test-interpreter
] unit-test

[ { "hi" } ] [
    [ f [ 2 ] [ "hi" ] if ] test-interpreter
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

[ { #{ 1 1.5 }# { } #{ 1 1.5 }# { } } ] [
    [ #{ 1 1.5 }# { } 2dup ] test-interpreter
] unit-test

[ { 4 } ] [
    [ 2 2 + ] test-interpreter
] unit-test

[ { } ] [
    [ 3 "x" set ] test-interpreter
] unit-test

[ { 3 } ] [
    [ 3 "x" set "x" get ] test-interpreter
] unit-test

[ { "hi\n" } ] [
    [ [ "hi" print ] string-out ] test-interpreter
] unit-test

[ { "4\n" } ] [
    [ [ 2 2 + . ] string-out ] test-interpreter
] unit-test
