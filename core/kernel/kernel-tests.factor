USING: arrays byte-arrays kernel kernel.private math memory
namespaces sequences tools.test math.private quotations
continuations prettyprint io.streams.string debugger assocs
sequences.private accessors locals.backend grouping words ;
IN: kernel.tests

[ 0 ] [ f size ] unit-test
[ t ] [ [ \ = \ = ] all-equal? ] unit-test

! Don't leak extra roots if error is thrown
[ ] [ 10000 [ [ 3 throw ] ignore-errors ] times ] unit-test

[ ] [ 10000 [ [ -1 f <array> ] ignore-errors ] times ] unit-test

! Make sure we report the correct error on stack underflow
[ clear drop ] [ { "kernel-error" 11 f f } = ] must-fail-with

[ ] [ :c ] unit-test

[ 3 [ { } set-retainstack ] dip ] [ { "kernel-error" 13 f f } = ] must-fail-with

[ ] [ :c ] unit-test

: overflow-d ( -- ) 3 overflow-d ;

: (overflow-d-alt) ( -- n ) 3 ;

: overflow-d-alt ( -- ) (overflow-d-alt) overflow-d-alt ;

: overflow-r ( -- ) 3 load-local overflow-r ;

<<
{ overflow-d (overflow-d-alt) overflow-d-alt overflow-r }
[ t "no-compile" set-word-prop ] each
>>

[ overflow-d ] [ { "kernel-error" 12 f f } = ] must-fail-with

[ ] [ :c ] unit-test

[ overflow-d-alt ] [ { "kernel-error" 12 f f } = ] must-fail-with

[ ] [ [ :c ] with-string-writer drop ] unit-test

[ overflow-r ] [ { "kernel-error" 14 f f } = ] must-fail-with

[ ] [ :c ] unit-test

[ -7 <byte-array> ] must-fail

[ 2 3 4 1 ] [ 1 2 3 4 roll ] unit-test
[ 1 2 3 4 ] [ 2 3 4 1 -roll ] unit-test

[ 3 ] [ t 3 and ] unit-test
[ f ] [ f 3 and ] unit-test
[ f ] [ 3 f and ] unit-test
[ 4 ] [ 4 6 or ] unit-test
[ 6 ] [ f 6 or ] unit-test
[ f ] [ 1 2 xor ] unit-test
[ 1 ] [ 1 f xor ] unit-test
[ 2 ] [ f 2 xor ] unit-test
[ f ] [ f f xor ] unit-test

[ slip ] must-fail
[ ] [ :c ] unit-test

[ 1 slip ] must-fail
[ ] [ :c ] unit-test

[ 1 2 slip ] must-fail
[ ] [ :c ] unit-test

[ 1 2 3 slip ] must-fail
[ ] [ :c ] unit-test


[ 5 ] [ [ 2 2 + ] 1 slip + ] unit-test

[ [ ] keep ] must-fail

[ 6 ] [ 2 [ sq ] keep + ] unit-test

[ [ ] 2keep ] must-fail
[ 1 [ ] 2keep ] must-fail
[ 3 1 2 ] [ 1 2 [ 2drop 3 ] 2keep ] unit-test

[ 0 ] [ f [ sq ] [ 0 ] if* ] unit-test
[ 4 ] [ 2 [ sq ] [ 0 ] if* ] unit-test

[ 0 ] [ f [ 0 ] unless* ] unit-test
[ t ] [ t [ "Hello" ] unless* ] unit-test

[ "2\n" ] [ [ 1 2 [ . ] [ sq . ] ?if ] with-string-writer ] unit-test
[ "9\n" ] [ [ 3 f [ . ] [ sq . ] ?if ] with-string-writer ] unit-test

[ f ] [ f (clone) ] unit-test
[ -123 ] [ -123 (clone) ] unit-test

[ 6 2 ] [ 1 2 [ 5 + ] dip ] unit-test

[ ] [ callstack set-callstack ] unit-test

[ 3drop datastack ] must-fail
[ ] [ :c ] unit-test

! Doesn't compile; important
: foo ( a -- b ) ;

<< \ foo t "no-compile" set-word-prop >>

[ drop foo ] must-fail
[ ] [ :c ] unit-test

! Regression
: (loop) ( a b c d -- )
    [ pick ] dip swap [ pick ] dip swap
    < [ [ 1 + ] 3dip (loop) ] [ 2drop 2drop ] if ; inline recursive

: loop ( obj -- )
    H{ } values swap [ dup length swap ] dip 0 -roll (loop) ;

[ loop ] must-fail

! Discovered on Windows
: total-failure-1 ( -- a ) "" [ ] map unimplemented ;

[ total-failure-1 ] must-fail

[ 1 1 2 2 3 3 ] [ 1 2 3 [ dup ] tri@ ] unit-test
[ 1 4 9 ] [ 1 2 3 [ sq ] tri@ ] unit-test
[ [ sq ] tri@ ] must-infer

[ 4 ] [ 1 { [ 1 ] [ 2 ] } dispatch sq ] unit-test

! Test traceback accuracy
: last-frame ( -- pair )
    error-continuation get call>> callstack>array 4 head* 2 tail* ;

[
    { [ 1 2 [ 3 throw ] call 4 ] 3 }
] [
    [ [ 1 2 [ 3 throw ] call 4 ] call ] ignore-errors
    last-frame
] unit-test

[
    { [ 1 2 [ 3 throw ] dip 4 ] 3 }
] [
    [ [ 1 2 [ 3 throw ] dip 4 ] call ] ignore-errors
    last-frame
] unit-test

[
    { [ 1 2 3 throw [ ] call 4 ] 3 }
] [
    [ [ 1 2 3 throw [ ] call 4 ] call ] ignore-errors
    last-frame
] unit-test

[
    { [ 1 2 3 throw [ ] dip 4 ] 3 }
] [
    [ [ 1 2 3 throw [ ] dip 4 ] call ] ignore-errors
    last-frame
] unit-test

[
    { [ 1 2 3 throw [ ] [ ] if 4 ] 3 }
] [
    [ [ 1 2 3 throw [ ] [ ] if 4 ] call ] ignore-errors
    last-frame
] unit-test

[ 10 2 3 4 5 ] [ 1 2 3 4 5 [ 10 * ] 4dip ] unit-test

[ 3 -1 5/6 ] [ 1 2 3 4 5 6 [ + ] [ - ] [ / ] 2tri* ] unit-test

[ { 1 2 } { 3 4 } { 5 6 } ] [ 1 2 3 4 5 6 [ 2array ] 2tri@ ] unit-test
