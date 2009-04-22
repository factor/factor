IN: compiler.cfg.builder.tests
USING: tools.test kernel sequences
words sequences.private fry prettyprint alien alien.accessors
math.private compiler.tree.builder compiler.tree.optimizer
compiler.cfg.builder compiler.cfg.debugger arrays locals byte-arrays
kernel.private math ;

! Just ensure that various CFGs build correctly.
: unit-test-cfg ( quot -- ) '[ _ test-cfg drop ] [ ] swap unit-test ;

{
    [ ]
    [ dup ]
    [ swap ]
    [ [ ] dip ]
    [ fixnum+ ]
    [ fixnum+fast ]
    [ 3 fixnum+fast ]
    [ fixnum*fast ]
    [ 3 fixnum*fast ]
    [ fixnum-shift-fast ]
    [ 10 fixnum-shift-fast ]
    [ -10 fixnum-shift-fast ]
    [ 0 fixnum-shift-fast ]
    [ fixnum-bitnot ]
    [ eq? ]
    [ "hi" eq? ]
    [ fixnum< ]
    [ 5 fixnum< ]
    [ float+ ]
    [ 3.0 float+ ]
    [ float<= ]
    [ fixnum>bignum ]
    [ bignum>fixnum ]
    [ fixnum>float ]
    [ float>fixnum ]
    [ 3 f <array> ]
    [ [ 1 ] [ 2 ] if ]
    [ fixnum< [ 1 ] [ 2 ] if ]
    [ float+ [ 2.0 float* ] [ 3.0 float* ] bi float/f ]
    [ { [ 1 ] [ 2 ] [ 3 ] } dispatch ]
    [ [ t ] loop ]
    [ [ dup ] loop ]
    [ [ 2 ] [ 3 throw ] if 4 ]
    [ "int" f "malloc" { "int" } alien-invoke ]
    [ "int" { "int" } "cdecl" alien-indirect ]
    [ "int" { "int" } "cdecl" [ ] alien-callback ]
} [
    unit-test-cfg
] each

: test-1 ( -- ) test-1 ;
: test-2 ( -- ) 3 . test-2 ;
: test-3 ( a -- b ) dup [ test-3 ] when ;

{
    test-1
    test-2
    test-3
} [ unit-test-cfg ] each

{
    byte-array
    simple-alien
    alien
    POSTPONE: f
} [| class |
    {
        alien-signed-1
        alien-signed-2
        alien-signed-4
        alien-unsigned-1
        alien-unsigned-2
        alien-unsigned-4
        alien-cell
        alien-float
        alien-double
    } [| word |
        { class } word '[ _ declare 10 _ execute ] unit-test-cfg
        { class fixnum } word '[ _ declare _ execute ] unit-test-cfg
    ] each
    
    {
        set-alien-signed-1
        set-alien-signed-2
        set-alien-signed-4
        set-alien-unsigned-1
        set-alien-unsigned-2
        set-alien-unsigned-4
    } [| word |
        { fixnum class } word '[ _ declare 10 _ execute ] unit-test-cfg
        { fixnum class fixnum } word '[ _ declare _ execute ] unit-test-cfg
    ] each
    
    { float class } \ set-alien-float '[ _ declare 10 _ execute ] unit-test-cfg
    { float class fixnum } \ set-alien-float '[ _ declare _ execute ] unit-test-cfg
    
    { float class } \ set-alien-double '[ _ declare 10 _ execute ] unit-test-cfg
    { float class fixnum } \ set-alien-double '[ _ declare _ execute ] unit-test-cfg
    
    { pinned-c-ptr class } \ set-alien-cell '[ _ declare 10 _ execute ] unit-test-cfg
    { pinned-c-ptr class fixnum } \ set-alien-cell '[ _ declare _ execute ] unit-test-cfg
] each
