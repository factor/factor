USING: accessors alien alien.accessors arrays assocs byte-arrays
combinators.short-circuit compiler.cfg compiler.cfg.builder
compiler.cfg.builder.blocks compiler.cfg.checker compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.optimizer compiler.cfg.registers
compiler.cfg.stacks.local compiler.cfg.utilities compiler.test
compiler.tree compiler.tree.builder compiler.tree.optimizer
compiler.tree.propagation.info cpu.architecture fry hashtables io
kernel kernel.private locals make math math.intervals
math.partial-dispatch math.private namespaces prettyprint sbufs
sequences sequences.private slots.private strings strings.private
tools.test vectors words ;
FROM: alien.c-types => int ;
IN: compiler.cfg.builder.tests

! Just ensure that various CFGs build correctly.
: unit-test-builder ( quot -- )
    '[
        _ test-builder [
            [
                [ optimize-cfg ] [ check-cfg ] bi
            ] with-cfg
        ] each
    ] [ ] swap unit-test ;

: blahblah ( nodes -- ? )
    { fixnum } declare [
        dup 3 bitand 1 = [ drop t ] [
            dup 3 bitand 2 = [
                blahblah
            ] [ drop f ] if
        ] if
    ] any? ; inline recursive

: more? ( x -- ? ) ;

: test-case-1 ( -- ? ) f ;

: test-case-2 ( -- )
    test-case-1 [ test-case-2 ] [ ] if ; inline recursive

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
    [ 3 swap fixnum*fast ]
    [ fixnum-shift-fast ]
    [ 10 fixnum-shift-fast ]
    [ -10 fixnum-shift-fast ]
    [ 0 fixnum-shift-fast ]
    [ 10 swap fixnum-shift-fast ]
    [ -10 swap fixnum-shift-fast ]
    [ 0 swap fixnum-shift-fast ]
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
    [ int f "malloc" { int } f alien-invoke ]
    [ int { int } cdecl alien-indirect ]
    [ int { int } cdecl [ ] alien-callback ]
    [ swap - + * ]
    [ swap slot ]
    [ blahblah ]
    [ 1000 [ dup [ reverse ] when ] times ]
    [ 1array ]
    [ 1 2 ? ]
    [ { array } declare [ ] map ]
    [ { array } declare dup 1 slot [ 1 slot ] when ]
    [ [ dup more? ] [ dup ] produce ]
    [ vector new over test-case-1 [ test-case-2 ] [ ] if ]
    [ [ [ nth-unsafe ".." = 0 ] dip set-nth-unsafe ] 2curry each-integer-from ]
    [
        { fixnum sbuf } declare 2dup 3 slot fixnum> [
            over 3 fixnum* over dup [ 2 slot resize-string ] dip 2 set-slot
        ] [ ] if
    ]
    [ [ 2 fixnum* ] when 3 ]
    [ [ 2 fixnum+ ] when 3 ]
    [ [ 2 fixnum- ] when 3 ]
    [ 10000 [ ] times ]
    [
        over integer? [
            over dup 16 <-integer-fixnum
            [ 0 >=-integer-fixnum ] [ drop f ] if [
                nip dup
                [ ] [ ] if
            ] [ 2drop f ] if
        ] [ 2drop f ] if
    ]
    [
        pick 10 fixnum>= [ [ 123 fixnum-bitand ] 2dip ] [ ] if
        set-string-nth-fast
    ]
} [
    unit-test-builder
] each

: test-1 ( -- ) test-1 ;
: test-2 ( -- ) 3 . test-2 ;
: test-3 ( a -- b ) dup [ test-3 ] when ;

{
    test-1
    test-2
    test-3
} [ unit-test-builder ] each

{
    byte-array
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
        { class } word '[ _ declare 10 _ execute ] unit-test-builder
        { class fixnum } word '[ _ declare _ execute ] unit-test-builder
    ] each

    {
        set-alien-signed-1
        set-alien-signed-2
        set-alien-signed-4
        set-alien-unsigned-1
        set-alien-unsigned-2
        set-alien-unsigned-4
    } [| word |
        { fixnum class } word '[ _ declare 10 _ execute ] unit-test-builder
        { fixnum class fixnum } word '[ _ declare _ execute ] unit-test-builder
    ] each

    { float class } \ set-alien-float '[ _ declare 10 _ execute ] unit-test-builder
    { float class fixnum } \ set-alien-float '[ _ declare _ execute ] unit-test-builder

    { float class } \ set-alien-double '[ _ declare 10 _ execute ] unit-test-builder
    { float class fixnum } \ set-alien-double '[ _ declare _ execute ] unit-test-builder

    { pinned-c-ptr class } \ set-alien-cell '[ _ declare 10 _ execute ] unit-test-builder
    { pinned-c-ptr class fixnum } \ set-alien-cell '[ _ declare _ execute ] unit-test-builder
] each

{ t } [ [ swap ] [ ##replace? ] contains-insn? ] unit-test

{ f } [ [ swap swap ] [ ##replace? ] contains-insn? ] unit-test

{ t } [
    [ { fixnum byte-array fixnum } declare set-alien-unsigned-1 ]
    [ [ ##store-memory? ] [ ##store-memory-imm? ] bi or ] contains-insn?
] unit-test

{ t } [
    [ { fixnum byte-array fixnum } declare [ dup * dup * ] 2dip set-alien-unsigned-1 ]
    [ [ ##store-memory? ] [ ##store-memory-imm? ] bi or ] contains-insn?
] unit-test

{ f } [
    [ { byte-array fixnum } declare set-alien-unsigned-1 ]
    [ [ ##store-memory? ] [ ##store-memory-imm? ] bi or ] contains-insn?
] unit-test

{ t t } [
    [ { byte-array fixnum } declare alien-cell ]
    [ [ [ ##load-memory? ] [ ##load-memory-imm? ] bi or ] contains-insn? ]
    [ [ ##box-alien? ] contains-insn? ]
    bi
] unit-test

{ f } [
    [ { byte-array integer } declare alien-cell ]
    [ [ ##load-memory? ] [ ##load-memory-imm? ] bi or ] contains-insn?
] unit-test

{ f } [
    [ 1000 [ ] times ] [ ##peek? ] contains-insn?
] unit-test

{ f t } [
    [ { fixnum alien } declare <displaced-alien> 0 alien-cell ]
    [ [ ##unbox-any-c-ptr? ] contains-insn? ]
    [ [ ##unbox-alien? ] contains-insn? ] bi
] unit-test

\ alien-float "intrinsic" word-prop [
    [ f t ] [
        [ { byte-array fixnum } declare alien-cell 4 alien-float ]
        [ [ ##box-alien? ] contains-insn? ]
        [ [ ##allot? ] contains-insn? ] bi
    ] unit-test

    [ f t ] [
        [ { byte-array fixnum } declare alien-cell { alien } declare 4 alien-float ]
        [ [ ##box-alien? ] contains-insn? ]
        [ [ ##allot? ] contains-insn? ] bi
    ] unit-test

    [ 1 ] [ [ dup float+ ] [ ##load-memory-imm? ] count-insns ] unit-test
] when

! Regression. Make sure everything is inlined correctly
{ f } [ M\ hashtable set-at [ { [ ##call? ] [ word>> \ set-slot eq? ] } 1&& ] contains-insn? ] unit-test

! Regression. Make sure branch splitting works.
{ 2 } [ [ 1 2 ? ] [ ##return? ] count-insns ] unit-test

! Make sure fast union predicates don't have conditionals.
{ f } [
    [ tag 1 swap fixnum-shift-fast ]
    [ ##compare-integer-imm-branch? ] contains-insn?
] unit-test

! begin-cfg
SYMBOL: foo

{ foo } [
    \ foo f begin-cfg word>>
] cfg-unit-test

! build-cfg
{ 5 } [
    [ dup ] build-tree optimize-tree gensym build-cfg
    first linearization-order length
] unit-test

! emit-branch
{ 77 } [
    { T{ #call { word + } } }
    V{ } 77 insns>block
    emit-branch
    first predecessors>>
    first predecessors>>
    first predecessors>>
    first  number>>
] cfg-unit-test

! emit-call
{
    V{ T{ ##call { word print } } T{ ##branch } }
} [
    <basic-block> dup set-basic-block \ print 4 emit-call
    predecessors>> first instructions>>
] cfg-unit-test

! emit-if
{ V{ 3 2 } } [
    <basic-block> dup set-basic-block ##branch,
    T{ #if
       { in-d { 9 } }
       { children
         {
             { T{ #push { literal 3 } { out-d { 6 } } } }
             { T{ #push { literal 2 } { out-d { 7 } } } }
         }
       }
       { live-branches { t t } }
    } emit-if
    predecessors>> [ instructions>> first val>> ] map
] cfg-unit-test

! emit-loop-call
{ 1 "good" } [
    V{ } 0 insns>block dup set-basic-block
    V{ } "good" insns>block swap [ emit-loop-call ] keep
    [ successors>> length ] [ successors>> first number>> ] bi
] unit-test

! emit-node

! ! #call
{
    V{
        T{ ##load-integer { dst 3 } { val 0 } }
        T{ ##add { dst 4 } { src1 3 } { src2 2 } }
        T{ ##load-memory-imm
           { dst 5 }
           { base 4 }
           { offset 0 }
           { rep int-rep }
        }
        T{ ##box-alien { dst 7 } { src 5 } { temp 6 } }
    }
} [
    f T{ #call
       { word alien-cell }
       { in-d V{ 10 20 } }
       { out-d { 30 } }
    } [ emit-node drop ] V{ } make
] cfg-unit-test

: call-node-1 ( -- node )
    T{ #call
       { word set-slot }
       { in-d V{ 1 2 3 } }
       { out-d { } }
       { info
         H{
             {
                 1
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
             {
                 2
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
             {
                 3
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
         }
       }
    } ;

{
    V{ T{ ##call { word set-slot } } T{ ##branch } }
} [
    [
         <basic-block> dup set-basic-block call-node-1 emit-node
    ] V{ } make drop
    predecessors>> first instructions>>
] cfg-unit-test

! ! #push
{
    { T{ ##load-integer { dst 78 } { val 0 } } }
} [
    77 vreg-counter set-global
    [ f T{ #push { literal 0 } { out-d { 8537399 } } } emit-node drop ] { } make
] cfg-unit-test

! ! #shuffle
{
    T{ height-state f 0 0 1 0 }
    H{ { D: -1 4 } { D: 0 4 } }
} [
    4 D: 0 replace-loc
    f T{ #shuffle
       { mapping { { 2 4 } { 3 4 } } }
       { in-d V{ 4 } }
       { out-d V{ 2 3 } }
    } emit-node drop
    height-state get
    replaces get
] cfg-unit-test

! ! #terminate

{ f } [
    <basic-block> dup set-basic-block
    T{ #terminate { in-d { } } { in-r { } } } emit-node
] cfg-unit-test

! end-word
{
    V{
        T{ ##safepoint }
        T{ ##epilogue }
        T{ ##return }
    }
} [
    <basic-block> dup set-basic-block end-word instructions>>
] unit-test

! height-changes
{ { -2 0 } } [
    T{ #shuffle { in-d { 37 81 92 } } { out-d { 20 } } } height-changes
] unit-test

! make-input-map
{
    { { 37 D: 2 } { 81 D: 1 } { 92 D: 0 } }
} [
    T{ #shuffle { in-d { 37 81 92 } } } make-input-map
] unit-test

! store-shuffle
{
    H{ { D: 2 1 } }
} [
    f T{ #shuffle { in-d { 7 3 0 } } { out-d { 55 } } { mapping { { 55 3 } } } }
    emit-node drop replaces get
] cfg-unit-test

{
    H{ { D: -1 1 } { D: 0 1 } }
} [
    f T{ #shuffle
       { in-d { 7 } }
       { out-d { 55 77 } }
       { mapping { { 55 7 } { 77 7 } } }
    } emit-node drop replaces get
] cfg-unit-test
