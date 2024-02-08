USING: generalizations accessors arrays compiler.test kernel
kernel.private math hashtables.private math.private namespaces
sequences tools.test namespaces.private slots.private
sequences.private byte-arrays alien alien.accessors layouts
words definitions compiler.units io combinators vectors grouping
make alien.c-types alien.data combinators.short-circuit math.order
math.libm math.parser math.functions alien.syntax memory
stack-checker literals system ;
FROM: math => float ;
QUALIFIED: namespaces.private
IN: compiler.tests.codegen

! Originally, this file did black box testing of templating
! optimization. We now have a different codegen, but the tests
! in here are still useful.

! Oops!
{ 5000 } [ [ 5000 ] compile-call ] unit-test
{ "hi" } [ [ "hi" ] compile-call ] unit-test

{ 1 2 3 4 } [ [ 1 2 3 4 ] compile-call ] unit-test

{ 1 1 } [ 1 [ dup ] compile-call ] unit-test
{ 0 } [ 3 [ tag ] compile-call ] unit-test
{ 0 3 } [ 3 [ [ tag ] keep ] compile-call ] unit-test

{ 2 3 } [ 3 [ 2 swap ] compile-call ] unit-test

{ 2 1 3 4 } [ 1 2 [ swap 3 4 ] compile-call ] unit-test

{ 2 3 4 } [ 3 [ 2 swap 4 ] compile-call ] unit-test

{ { 1 2 3 } { 1 4 3 } 2 2 }
[ { 1 2 3 } { 1 4 3 } [ over tag over tag ] compile-call ]
unit-test

! Test literals in either side of a shuffle
{ 4 1 } [ 1 [ [ 3 fixnum+ ] keep ] compile-call ] unit-test

{ 2 } [ 1 2 [ swap fixnum/i ] compile-call ] unit-test

: foo ( -- ) ;

{ 3 3 }
[ 1.2 [ tag [ foo ] keep ] compile-call ]
unit-test

{ 1 2 2 }
[ { 1 2 } [ dup 2 slot swap 3 slot [ foo ] keep ] compile-call ]
unit-test

{ 3 }
[
    global [ 3 \ foo set ] with-variables
    \ foo [ global >n get namespaces.private:ndrop ] compile-call
] unit-test

: blech ( x -- ) drop ;

{ 3 }
[
    global [ 3 \ foo set ] with-variables
    \ foo [ global [ get ] swap blech call ] compile-call
] unit-test

{ 3 }
[
    global [ 3 \ foo set ] with-variables
    \ foo [ global [ get ] swap >n call namespaces.private:ndrop ] compile-call
] unit-test

{ 3 }
[
    global [ 3 \ foo set ] with-variables
    \ foo [ global [ get ] with-variables ] compile-call
] unit-test

{ 12 13 } [
    -12 -13 [ [ 0 swap fixnum-fast ] bi@ ] compile-call
] unit-test

{ -1 2 } [ 1 2 [ [ 0 swap fixnum- ] dip ] compile-call ] unit-test

{ 12 13 } [
    -12 -13 [ [ 0 swap fixnum- ] bi@ ] compile-call
] unit-test

{ 1 } [
    SBUF" " [ 1 slot 1 [ slot ] keep ] compile-call nip
] unit-test

! Test slow shuffles
{ 3 1 2 3 4 5 6 7 8 9 } [
    1 2 3 4 5 6 7 8 9
    [ [ [ [ [ [ [ [ [ [ 3 ] dip ] dip ] dip ] dip ] dip ] dip ] dip ] dip ] dip ]
    compile-call
] unit-test

{ 2 2 2 2 2 2 2 2 2 2 1 } [
    1 2
    [ swap [ dup dup dup dup dup dup dup dup dup ] dip ] compile-call
] unit-test

{ } [ [ 9 [ ] times ] compile-call ] unit-test

{ } [
    [
        [ 200 dup [ 200 3array ] curry map drop ] times
    ] [ ( n -- ) define-temp ] with-compilation-unit drop
] unit-test

! Test how dispatch handles the end of a basic block
: try-breaking-dispatch ( n a b -- x str )
    float+ swap { [ "hey" ] [ "bye" ] } dispatch ;

: try-breaking-dispatch-2 ( -- ? )
    1 1.0 2.5 try-breaking-dispatch "bye" = [ 3.5 = ] dip and ;

{ t } [
    10000000 [ drop try-breaking-dispatch-2 ] all-integers?
] unit-test

! Regression
: (broken) ( x -- y ) ;

{ 2.0 { 2.0 0.0 } } [
    2.0 1.0
    [ float/f 0.0 [ drop (broken) ] 2keep 2array ] compile-call
] unit-test

! Regression
: hellish-bug-1 ( a b -- ) 2drop ;

: hellish-bug-2 ( i array x -- x )
    2dup 1 slot eq? [ 2drop ] [
        2dup array-nth tombstone? [
            [
                [ array-nth ] 2keep [ 1 fixnum+fast ] dip array-nth
                pick 2dup hellish-bug-1 3drop
            ] 2keep
        ] unless [ 2 fixnum+fast ] dip hellish-bug-2
    ] if ; inline recursive

: hellish-bug-3 ( hash array -- )
    0 swap hellish-bug-2 drop ;

{ } [
    H{ { 1 2 } { 3 4 } } dup array>>
    [ 0 swap hellish-bug-2 drop ] compile-call
] unit-test

! Regression
: foox ( obj -- obj )
    dup not
    [ drop 3 ] [ dup tuple? [ drop 4 ] [ drop 5 ] if ] if ;

{ 3 } [ f foox ] unit-test

TUPLE: my-tuple ;

{ 4 } [ T{ my-tuple } foox ] unit-test

{ 5 } [ "hi" foox ] unit-test

! Making sure we don't needlessly unbox/rebox
{ t 3.0 } [ 1.0 dup [ dup 2.0 float+ [ eq? ] dip ] compile-call ] unit-test

{ t 3.0 } [ 1.0 dup [ dup 2.0 float+ ] compile-call [ eq? ] dip ] unit-test

{ t } [ 1.0 dup [ [ 2.0 float+ ] keep ] compile-call nip eq? ] unit-test

{ 1 B{ 1 2 3 4 } } [
    B{ 1 2 3 4 } [
        { byte-array } declare
        [ 0 alien-unsigned-1 ] keep
    ] compile-call
] unit-test

{ 2 1 } [
    2 1
    [ 2dup fixnum< [ [ die ] dip ] when ] compile-call
] unit-test

! Regression
: a-dummy ( a -- ) drop "hi" print ;

{ } [
    1 [
        dup 0 2 3dup pick >= [ >= ] [ 2drop f ] if [
            drop - >fixnum {
                [ a-dummy ]
                [ a-dummy ]
                [ a-dummy ]
            } dispatch
        ] [ 2drop no-case ] if
    ] compile-call
] unit-test

! Regression
: dispatch-alignment-regression ( -- c )
    { tuple vector } 3 slot { word } declare
    dup 1 slot 0 fixnum-bitand { [ ] } dispatch ;

{ t } [ \ dispatch-alignment-regression word-optimized? ] unit-test

{ vector } [ dispatch-alignment-regression ] unit-test

! Regression
: bad-value-bug ( a -- b ) [ 3 ] [ 3 ] if f <array> ;

{ { f f f } } [ t bad-value-bug ] unit-test

! PowerPC regression
TUPLE: id obj ;

: (gc-check-bug) ( a b -- c )
    { [ id boa ] [ id boa ] } dispatch ;

: gc-check-bug ( -- )
    10000000 [ "hi" 0 (gc-check-bug) drop ] times ;

{ } [ gc-check-bug ] unit-test

! New optimization
: test-1 ( a -- b ) 8 fixnum-fast { [ "a" ] [ "b" ] } dispatch ;

{ "a" } [ 8 test-1 ] unit-test
{ "b" } [ 9 test-1 ] unit-test

: test-2 ( a -- b ) 1 fixnum-fast { [ "a" ] [ "b" ] } dispatch ;

{ "a" } [ 1 test-2 ] unit-test
{ "b" } [ 2 test-2 ] unit-test

! I accidentally fixnum/i-fast on PowerPC
{ { { 1 2 } { 3 4 } } } [
    { 1 2 3 4 }
    [
        [ { array } declare 2 group [ , ] each ] compile-call
    ] { } make
] unit-test

{ 2 } [
    { 1 2 3 4 }
    [ { array } declare 2 <groups> length ] compile-call
] unit-test

! Oops with new intrinsics
: fixnum-overflow-control-flow-test ( a b -- c )
    [ 1 fixnum- ] [ 2 fixnum- ] if 3 fixnum+fast ;

{ 3 } [ 1 t fixnum-overflow-control-flow-test ] unit-test
{ 2 } [ 1 f fixnum-overflow-control-flow-test ] unit-test

! LOL
: blah ( a -- b )
    { float } declare dup 0 =
    [ drop 1 ] [
        dup 0 >=
        [ 2 double "libm" "pow" { double double } f alien-invoke ]
        [ -0.5 double "libm" "pow" { double double } f alien-invoke ]
        if
    ] if ;

{ 4.0 } [ 2.0 blah ] unit-test

{ 4 } [ 2 [ dup fixnum* ] compile-call ] unit-test
{ 7 } [ 2 [ dup fixnum* 3 fixnum+fast ] compile-call ] unit-test

TUPLE: cucumber ;

M: cucumber equal? "The cucumber has no equal" throw ;

{ t } [ [ cucumber ] compile-call cucumber eq? ] unit-test

{ 4294967295 B{ 255 255 255 255 } -1 }
[
    -1 int <ref>
    -1 int <ref>
    [ [ 0 alien-unsigned-4 swap ] [ 0 alien-signed-2 ] bi ]
    compile-call
] unit-test

! Regression found while working on global register allocation

: linear-scan-regression-1 ( a b c -- ) 3array , ;
: linear-scan-regression-2 ( a b -- ) 2array , ;

: linear-scan-regression ( a b c -- )
    [ linear-scan-regression-2 ]
    [ linear-scan-regression-1 ]
    bi-curry bi-curry interleave ;

{
    {
        { 1 "x" "y" }
        { "x" "y" }
        { 2 "x" "y" }
        { "x" "y" }
        { 3 "x" "y" }
    }
} [
    [ { 1 2 3 } "x" "y" linear-scan-regression ] { } make
] unit-test

! Regression from Doug's value numbering changes
{ t } [ 2 [ 1 swap fixnum< ] compile-call ] unit-test
{ 3 } [ 2 [ 1 swap fixnum< [ 3 ] [ 4 ] if ] compile-call ] unit-test

cell 4 = [
    { 0 } [ 101 [ dup fixnum-fast 1 fixnum+fast 20 fixnum-shift-fast 20 fixnum-shift-fast ] compile-call ] unit-test
] when

! Regression from Slava's value numbering changes
{ 1 } [ 31337 [ dup fixnum<= [ 1 ] [ 2 ] if ] compile-call ] unit-test

! Bug with ##return node construction
: return-recursive-bug ( nodes -- ? )
    { fixnum } declare <iota> [
        dup 3 bitand 1 = [ drop t ] [
            dup 3 bitand 2 = [
                return-recursive-bug
            ] [ drop f ] if
        ] if
    ] any? ; inline recursive

{ t } [ 3 [ return-recursive-bug ] compile-call ] unit-test

! Coalescing reductions
{ f } [ V{ } 0 [ [ vector? ] both? ] compile-call ] unit-test
{ f } [ 0 V{ } [ [ vector? ] both? ] compile-call ] unit-test

{ f } [
    f vector [
        [ dup [ \ vector eq? ] [ drop f ] if ] dip
        dup [ \ vector eq? ] [ drop f ] if
        over rot [ drop ] [ nip ] if
    ] compile-call
] unit-test

! Coalesing bug reduced from sequence-parser:take-sequence
: coalescing-bug-1 ( a b c d -- a b c d )
    3dup {
        [ 2drop 0 < ]
        [ [ drop ] 2dip length > ]
        [ drop > ]
    } 3|| [ 3drop f ] [ slice boa ] if swap [ 2length ] 2keep ;

{ 0 3 f { 1 2 3 } } [ { 1 2 3 } -10 3 "hello" coalescing-bug-1 ] unit-test
{ 0 3 f { 1 2 3 } } [ { 1 2 3 } 0 7 "hello" coalescing-bug-1 ] unit-test
{ 0 3 f { 1 2 3 } } [ { 1 2 3 } 3 2 "hello" coalescing-bug-1 ] unit-test
{ 2 3 T{ slice f 1 3 "hello" } { 1 2 3 } } [ { 1 2 3 } 1 3 "hello" coalescing-bug-1 ] unit-test

! Another one, found by Dan
: coalescing-bug-2 ( a -- b )
    dup dup 10 fixnum< [ 1 fixnum+fast ] when
    fixnum+fast 2 fixnum*fast 2 fixnum-fast 2 fixnum*fast 2 fixnum+fast ;

{ 10 } [ 1 coalescing-bug-2 ] unit-test
{ 86 } [ 11 coalescing-bug-2 ] unit-test

! Regression in suffix-arrays code
: coalescing-bug-3 ( from/f to/f seq -- slice )
    [
        [ drop 0 or ] [ length or ] bi-curry bi*
        [ min ] keep
    ] keep <slice> ;

{ T{ slice f 0 5 "hello" } } [ f f "hello" coalescing-bug-3 ] unit-test
{ T{ slice f 1 5 "hello" } } [ 1 f "hello" coalescing-bug-3 ] unit-test
{ T{ slice f 0 3 "hello" } } [ f 3 "hello" coalescing-bug-3 ] unit-test
{ T{ slice f 1 3 "hello" } } [ 1 3 "hello" coalescing-bug-3 ] unit-test
{ T{ slice f 3 3 "hello" } } [ 4 3 "hello" coalescing-bug-3 ] unit-test
{ T{ slice f 5 5 "hello" } } [ 6 f "hello" coalescing-bug-3 ] unit-test

! Reduction
: coalescing-bug-4 ( a b c -- a b c )
    [ [ min ] keep ] dip vector? [ 1 ] [ 2 ] if ;

{ 2 3 2 } [ 2 3 "" coalescing-bug-4 ] unit-test
{ 3 3 2 } [ 4 3 "" coalescing-bug-4 ] unit-test
{ 3 3 2 } [ 4 3 "" coalescing-bug-4 ] unit-test
{ 2 3 1 } [ 2 3 V{ } coalescing-bug-4 ] unit-test
{ 3 3 1 } [ 4 3 V{ } coalescing-bug-4 ] unit-test
{ 3 3 1 } [ 4 3 V{ } coalescing-bug-4 ] unit-test

! Global stack analysis dataflow equations are wrong
: some-word ( a -- b ) 2 + ;
: global-dcn-bug-1 ( a b -- c d )
    dup [ [ drop 1 ] dip ] [ [ some-word ] dip ] if
    dup [ [ 1 fixnum+fast ] dip ] [ [ drop 1 ] dip ] if ;

{ 2 t } [ 0 t global-dcn-bug-1 ] unit-test
{ 1 f } [ 0 f global-dcn-bug-1 ] unit-test

! Forgot a GC check
: missing-gc-check-1 ( a -- b ) { fixnum } declare <alien> ;
: missing-gc-check-2 ( -- ) 10000000 [ missing-gc-check-1 drop ] each-integer ;

{ } [ missing-gc-check-2 ] unit-test

${ 1 os macosx? "0.169967142900241" "0.16996714290024104" ? } [ 1.4 [ 1 swap fcos ] compile-call number>string ] unit-test
${ 1 os macosx? "0.169967142900241" "0.16996714290024104" ? } [ 1.4 1 [ swap fcos ] compile-call number>string ] unit-test
{ "0.169967142900241" "0.9854497299884601" } [ 1.4 [ [ fcos ] [ fsin ] bi ] compile-call [ number>string ] bi@ ] unit-test
{ 1 "0.169967142900241" "0.9854497299884601" } [ 1.4 1 [ swap >float [ fcos ] [ fsin ] bi ] compile-call [ number>string ] bi@ ] unit-test

{ 6.0 } [ 1.0 [ >float 3.0 + [ B{ 0 0 0 0 } 0 set-alien-float ] [ 2.0 + ] bi ] compile-call ] unit-test

! Bug in linearization
{ 283686952174081 } [
    B{ 1 1 1 1 } [
        { byte-array } declare
        [ 0 2 ] dip
        [
            [ drop ] 2dip
            [
                swap 1 < [ [ ] dip ] [ [ ] dip ] if
                0 alien-signed-4
            ] curry dup bi *
        ] curry each-integer
    ] compile-call
] unit-test

! Bug in CSSA construction
TUPLE: myseq { underlying1 byte-array read-only } { underlying2 byte-array read-only } ;

{ 2 } [
    little-endian?
    T{ myseq f B{ 1 0 0 0 } B{ 1 0 0 0 } }
    T{ myseq f B{ 0 0 0 1 } B{ 0 0 0 1 } } ?
    [
        { myseq } declare
        [ 0 2 ] dip dup
        [
            [
                over 1 < [ underlying1>> ] [ [ 1 - ] dip underlying2>> ] if
                swap 4 * >fixnum alien-signed-4
            ] bi-curry@ bi * +
        ] 2curry each-integer
    ] compile-call
] unit-test

! Bug in linear scan's partial sync point logic
{ t } [
    [ 1.0 100 [ fsin ] times 1.0 float+ ] compile-call
    1.168852488727981 1.e-9 ~
] unit-test

{ 65537.0 } [
    [ 2.0 4 [ 2.0 fpow ] times 1.0 float+ ] compile-call
] unit-test

! ##box-displaced-alien is a def-is-use instruction
{ ALIEN: 3e9 } [
    [
        f
        100 [ 10 swap <displaced-alien> ] times
        1 swap <displaced-alien>
    ] compile-call
] unit-test

! Forgot to two-operand shifts
{ 2 0 } [
    1 1
    [ [ 0xf bitand ] bi@ [ shift ] [ drop -3 shift ] 2bi ] compile-call
] unit-test

! Alias analysis bug
{ t } [
    [
        10 10 <byte-array> [ <displaced-alien> underlying>> ] keep eq?
    ] compile-call
] unit-test

! GC root offsets were computed wrong on x86
: gc-root-messup ( a -- b )
    dup [
        1024 (byte-array) 2array
        10 void* "libc" "malloc" { ulong } f alien-invoke
        void "libc" "free" { void* } f alien-invoke
    ] when ;

{ } [ 2000 [ "hello" clone dup gc-root-messup first eq? t assert= ] times ] unit-test

! Write barrier elimination was being done before scheduling and
! GC check insertion, and didn't take subroutine calls into
! account. Oops...
: write-barrier-elim-in-wrong-place ( -- obj )
    ! A callback used below
    void { } cdecl [ compact-gc ] alien-callback
    ! Allocate an object A in the nursery
    1 f <array>
    ! Subroutine call promotes the object to tenured
    swap void { } cdecl alien-indirect
    ! Allocate another object B in the nursery, store it into
    ! the first
    1 f <array> over set-first
    ! Now object A's card should be marked and minor GC should
    ! promote B to aging
    minor-gc
    ! Do stuff
    [ 100 [ ] times ] infer.
    ;

{ { { f } } } [ write-barrier-elim-in-wrong-place ] unit-test

! GC maps must support derived pointers
: (derived-pointer-test-1) ( -- byte-array )
    2 <byte-array> ;

: derived-pointer-test-1 ( -- byte-array )
    ! A callback used below
    void { } cdecl [ compact-gc ] alien-callback
    ! Put the construction in a word since instruction selection
    ! eliminates the untagged pointer entirely if the value is a
    ! byte array
    (derived-pointer-test-1) { c-ptr } declare
    ! Store into an array, an untagged pointer to the payload
    ! is now an available expression
    123 over 0 set-alien-unsigned-1
    ! GC, moving the array and derived pointer
    swap void { } cdecl alien-indirect
    ! Store into the array again
    231 over 1 set-alien-unsigned-1 ;

{ B{ 123 231 } } [ derived-pointer-test-1 ] unit-test

: fib-count2 ( -- x y ) 0 1 [ dup 4000000 <= ] [ [ + ] keep swap ] while ;

{ 3524578 5702887 } [ fib-count2 ] unit-test

! Stupid repro
USE: compiler.cfg.registers

reset-vreg-counter

{ fib-count2 } compile

{ 3524578 5702887 } [ fib-count2 ] unit-test
