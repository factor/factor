! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer.math
USING: alien alien.accessors arrays generic hashtables kernel
assocs math math.private kernel.private sequences words parser
inference.class inference.dataflow vectors strings sbufs io
namespaces assocs quotations math.intervals sequences.private
combinators splitting layouts math.parser classes
classes.algebra generic.math optimizer.pattern-match
optimizer.backend optimizer.def-use optimizer.inlining
optimizer.math.partial generic.standard system accessors ;

: define-math-identities ( word identities -- )
    >r all-derived-ops r> define-identities ;

\ number= {
    { { @ @ } [ 2drop t ] }
} define-math-identities

\ + {
    { { number 0 } [ drop ] }
    { { 0 number } [ nip ] }
} define-math-identities

\ - {
    { { number 0 } [ drop ] }
    { { @ @ } [ 2drop 0 ] }
} define-math-identities

\ < {
    { { @ @ } [ 2drop f ] }
} define-math-identities

\ <= {
    { { @ @ } [ 2drop t ] }
} define-math-identities

\ > {
    { { @ @ } [ 2drop f ] }
} define-math-identities

\ >= {
    { { @ @ } [ 2drop t ] }
} define-math-identities

\ * {
    { { number 1 } [ drop ] }
    { { 1 number } [ nip ] }
    { { number 0 } [ nip ] }
    { { 0 number } [ drop ] }
    { { number -1 } [ drop 0 swap - ] }
    { { -1 number } [ nip 0 swap - ] }
} define-math-identities

\ / {
    { { number 1 } [ drop ] }
    { { number -1 } [ drop 0 swap - ] }
} define-math-identities

\ mod {
    { { integer 1 } [ 2drop 0 ] }
} define-math-identities

\ rem {
    { { integer 1 } [ 2drop 0 ] }
} define-math-identities

\ bitand {
    { { number -1 } [ drop ] }
    { { -1 number } [ nip ] }
    { { @ @ } [ drop ] }
    { { number 0 } [ nip ] }
    { { 0 number } [ drop ] }
} define-math-identities

\ bitor {
    { { number 0 } [ drop ] }
    { { 0 number } [ nip ] }
    { { @ @ } [ drop ] }
    { { number -1 } [ nip ] }
    { { -1 number } [ drop ] }
} define-math-identities

\ bitxor {
    { { number 0 } [ drop ] }
    { { 0 number } [ nip ] }
    { { number -1 } [ drop bitnot ] }
    { { -1 number } [ nip bitnot ] }
    { { @ @ } [ 2drop 0 ] }
} define-math-identities

\ shift {
    { { 0 number } [ drop ] }
    { { number 0 } [ drop ] }
} define-math-identities

: math-closure ( class -- newclass )
    { null fixnum bignum integer rational float real number }
    [ class<= ] with find nip number or ;

: fits? ( interval class -- ? )
    "interval" word-prop dup
    [ interval-subset? ] [ 2drop t ] if ;

: math-output-class ( node upgrades -- newclass )
    >r
    in-d>> null [ value-class* math-closure math-class-max ] reduce
    dup r> at swap or ;

: won't-overflow? ( interval node -- ? )
    node-in-d [ value-class* fixnum class<= ] all?
    swap fixnum fits? and ;

: post-process ( class interval node -- classes intervals )
    dupd won't-overflow?
    [ >r dup { f integer } member? [ drop fixnum ] when r> ] when
    [ dup [ 1array ] when ] bi@ ;

: math-output-interval-1 ( node word -- interval )
    dup [
        >r node-in-d first value-interval* dup
        [ r> execute ] [ r> 2drop f ] if
    ] [
        2drop f
    ] if ; inline

: math-output-class/interval-1 ( node word -- classes intervals )
    [ drop { } math-output-class 1array ]
    [ math-output-interval-1 1array ] 2bi ;

{
    { bitnot interval-bitnot }
    { fixnum-bitnot interval-bitnot }
    { bignum-bitnot interval-bitnot }
} [
    [ math-output-class/interval-1 ] curry
    "output-classes" set-word-prop
] assoc-each

: intervals ( node -- i1 i2 )
    node-in-d first2 [ value-interval* ] bi@ ;

: math-output-interval-2 ( node word -- interval )
    dup [
        >r intervals 2dup and [ r> execute ] [ r> 3drop f ] if
    ] [
        2drop f
    ] if ; inline

: math-output-class/interval-2 ( node upgrades word -- classes intervals )
    pick >r
    >r over r>
    math-output-interval-2
    >r math-output-class r>
    r> post-process ; inline

{
    { + { { fixnum integer } } interval+ }
    { - { { fixnum integer } } interval- }
    { * { { fixnum integer } } interval* }
    { / { { fixnum rational } { integer rational } } interval/ }
    { /i { { fixnum integer } } interval/i }
    { shift { { fixnum integer } } interval-shift-safe }
} [
    first3 [
        [
            math-output-class/interval-2
        ] 2curry "output-classes" set-word-prop
    ] 2curry each-derived-op
] each

: real-value? ( value -- n ? )
    dup value? [ value-literal dup real? ] [ drop f f ] if ;

: mod-range ( n -- interval )
    dup neg swap (a,b) ;

: rem-range ( n -- interval )
    0 swap [a,b) ;

: bitand-range ( n -- interval )
    dup 0 < [ drop f ] [ 0 swap [a,b] ] if ;

: math-output-interval-special ( node word -- interval )
    dup [
        >r node-in-d second real-value?
        [ r> execute ] [ r> 2drop f ] if
    ] [
        2drop f
    ] if ; inline

: math-output-class/interval-special ( node min word -- classes intervals )
    pick >r
    >r over r>
    math-output-interval-special
    >r math-output-class r>
    r> post-process ; inline

{
    { mod { } mod-range }
    { rem { { fixnum integer } } rem-range }

    { bitand { } bitand-range }
    { bitor { } f }
    { bitxor { } f }
} [
    first3 [
        [
            math-output-class/interval-special
        ] 2curry "output-classes" set-word-prop
    ] 2curry each-derived-op
] each

: twiddle-interval ( i1 -- i2 )
    dup [
        node get node-in-d
        [ value-class* integer class<= ] all?
        [ integral-closure ] when
    ] when ;

: (comparison-constraints) ( i1 i2 word class -- )
    node get [
        >r execute twiddle-interval 0 `input interval,
        r> 0 `output class,
    ] set-constraints ; inline

: comparison-constraints ( node true false -- )
    >r >r dup node set intervals dup [
        2dup
        r> \ f class-not (comparison-constraints)
        r> \ f (comparison-constraints)
    ] [
        r> r> 2drop 2drop
    ] if ; inline

{
    { < assume< assume>= }
    { <= assume<= assume> }
    { > assume> assume<= }
    { >= assume>= assume< }
} [
    first3 [
        [
            [ comparison-constraints ] with-scope
        ] 2curry "constraints" set-word-prop
    ] 2curry each-derived-op
] each

{
    alien-signed-1
    alien-unsigned-1
    alien-signed-2
    alien-unsigned-2
    alien-signed-4
    alien-unsigned-4
    alien-signed-8
    alien-unsigned-8
} [
    dup name>> {
        {
            [ "alien-signed-" ?head ]
            [ string>number 8 * 1- 2^ dup neg swap 1- [a,b] ]
        }
        {
            [ "alien-unsigned-" ?head ]
            [ string>number 8 * 2^ 1- 0 swap [a,b] ]
        }
    } cond 1array
    [ nip f swap ] curry "output-classes" set-word-prop
] each

! Associate intervals to classes
\ fixnum
most-negative-fixnum most-positive-fixnum [a,b]
"interval" set-word-prop

\ array-capacity
0 max-array-capacity [a,b]
"interval" set-word-prop

{
    { >fixnum fixnum }
    { >bignum bignum }
    { >float float }
} [
    [
        over node-in-d first value-interval*
        dup pick fits? [ drop f ] unless
        rot post-process
    ] curry "output-classes" set-word-prop
] assoc-each

! Removing overflow checks
: remove-overflow-check? ( #call -- ? )
    dup out-d>> first node-class
    [ fixnum class<= ] [ null eq? not ] bi and ;

{
    { + [ fixnum+fast ] }
    { +-integer-fixnum [ fixnum+fast ] }
    { - [ fixnum-fast ] }
    { * [ fixnum*fast ] }
    { *-integer-fixnum [ fixnum*fast ] }
    { shift [ fixnum-shift-fast ] }
    { fixnum+ [ fixnum+fast ] }
    { fixnum- [ fixnum-fast ] }
    { fixnum* [ fixnum*fast ] }
    { fixnum-shift [ fixnum-shift-fast ] }
} [
    [
        [ dup remove-overflow-check? ] ,
        [ f splice-quot ] curry ,
    ] { } make 1array define-optimizers
] assoc-each

! Remove redundant comparisons
: intervals-first2 ( #call -- first second )
    dup dup node-in-d first node-interval
    swap dup node-in-d second node-interval ;

: known-comparison? ( #call -- ? )
    intervals-first2 and ;

: perform-comparison ( #call word -- result )
    >r intervals-first2 r> execute ; inline

: foldable-comparison? ( #call word -- ? )
    >r dup known-comparison? [
        r> perform-comparison incomparable eq? not
    ] [
        r> 2drop f
    ] if ; inline

: fold-comparison ( #call word -- node )
    dupd perform-comparison 1array inline-literals ;

{
    { < interval< }
    { <= interval<= }
    { > interval> }
    { >= interval>= }
} [
    [
        [
            dup [ dupd foldable-comparison? ] curry ,
            [ fold-comparison ] curry ,
        ] { } make 1array define-optimizers
    ] curry each-derived-op
] assoc-each

! The following words are handled in a similar way except if
! the only consumer is a >fixnum we remove the overflow check
! too
: consumed-by? ( node word -- ? )
    swap sole-consumer
    dup #call? [ node-param eq? ] [ 2drop f ] if ;

: coerced-to-fixnum? ( #call -- ? )
    dup dup node-in-d [ node-class integer class<= ] with all?
    [ \ >fixnum consumed-by? ] [ drop f ] if ;

{
    { + [ [ >fixnum ] bi@ fixnum+fast ] }
    { - [ [ >fixnum ] bi@ fixnum-fast ] }
    { * [ [ >fixnum ] bi@ fixnum*fast ] }
} [
    >r derived-ops r> [
        [
            [
                dup remove-overflow-check?
                over coerced-to-fixnum? or
            ] ,
            [ f splice-quot ] curry ,
        ] { } make 1array define-optimizers
    ] curry each
] assoc-each

: convert-rem-to-and? ( #call -- ? )
    dup node-in-d {
        { [ 2dup first node-class integer class<= not ] [ f ] }
        { [ 2dup second node-literal integer? not ] [ f ] }
        { [ 2dup second node-literal power-of-2? not ] [ f ] }
        [ t ]
    } cond 2nip ;

: convert-mod-to-and? ( #call -- ? )
    dup dup node-in-d first node-interval 0 [a,inf] interval-subset?
    [ convert-rem-to-and? ] [ drop f ] if ;

: convert-mod-to-and ( #call -- node )
    dup
    dup node-in-d second node-literal 1-
    [ nip bitand ] curry f splice-quot ;

\ mod [
    {
        {
            [ dup convert-mod-to-and? ]
            [ convert-mod-to-and ]
        }
    } define-optimizers
] each-derived-op

\ rem {
    {
        [ dup convert-rem-to-and? ]
        [ convert-mod-to-and ]
    }
} define-optimizers

: fixnumify-bitand? ( #call -- ? )
    dup node-in-d second node-interval fixnum fits? ;

: fixnumify-bitand ( #call -- node )
    [ [ >fixnum ] bi@ fixnum-bitand ] f splice-quot ;

\ bitand {
    {
        [ dup fixnumify-bitand? ]
        [ fixnumify-bitand ]
    }
} define-optimizers
