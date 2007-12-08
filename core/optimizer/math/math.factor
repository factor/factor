! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer.math
USING: alien arrays generic hashtables kernel assocs math
math.private kernel.private sequences words parser
inference.class inference.dataflow vectors strings sbufs io
namespaces assocs quotations math.intervals sequences.private
combinators splitting layouts math.parser classes
generic.math optimizer.pattern-match optimizer.backend
optimizer.def-use generic.standard ;

{ + bignum+ float+ fixnum+fast } {
    { { number 0 } [ drop ] }
    { { 0 number } [ nip ] }
} define-identities

{ fixnum+ } {
    { { number 0 } [ drop ] }
    { { 0 number } [ nip ] }
} define-identities

{ - fixnum- bignum- float- fixnum-fast } {
    { { number 0 } [ drop ] }
    { { @ @ } [ 2drop 0 ] }
} define-identities

{ < fixnum< bignum< float< } {
    { { @ @ } [ 2drop f ] }
} define-identities

{ <= fixnum<= bignum<= float<= } {
    { { @ @ } [ 2drop t ] }
} define-identities

{ > fixnum> bignum> float>= } {
    { { @ @ } [ 2drop f ] }
} define-identities

{ >= fixnum>= bignum>= float>= } {
    { { @ @ } [ 2drop t ] }
} define-identities

{ * fixnum* bignum* float* } {
    { { number 1 } [ drop ] }
    { { 1 number } [ nip ] }
    { { number 0 } [ nip ] }
    { { 0 number } [ drop ] }
    { { number -1 } [ drop 0 swap - ] }
    { { -1 number } [ nip 0 swap - ] }
} define-identities

{ / fixnum/i bignum/i float/f } {
    { { number 1 } [ drop ] }
    { { number -1 } [ drop 0 swap - ] }
} define-identities

{ fixnum-mod bignum-mod } {
    { { number 1 } [ 2drop 0 ] }
} define-identities

{ bitand fixnum-bitand bignum-bitand } {
    { { number -1 } [ drop ] }
    { { -1 number } [ nip ] }
    { { @ @ } [ drop ] }
    { { number 0 } [ nip ] }
    { { 0 number } [ drop ] }
} define-identities

{ bitor fixnum-bitor bignum-bitor } {
    { { number 0 } [ drop ] }
    { { 0 number } [ nip ] }
    { { @ @ } [ drop ] }
    { { number -1 } [ nip ] }
    { { -1 number } [ drop ] }
} define-identities

{ bitxor fixnum-bitxor bignum-bitxor } {
    { { number 0 } [ drop ] }
    { { 0 number } [ nip ] }
    { { number -1 } [ drop bitnot ] }
    { { -1 number } [ nip bitnot ] }
    { { @ @ } [ 2drop 0 ] }
} define-identities

{ shift fixnum-shift bignum-shift } {
    { { 0 number } [ drop ] }
    { { number 0 } [ drop ] }
} define-identities

: math-closure ( class -- newclass )
    { fixnum integer rational real }
    [ class< ] curry* find nip number or ;

: fits? ( interval class -- ? )
    "interval" word-prop dup
    [ interval-subset? ] [ 2drop t ] if ;

: math-output-class ( node min -- newclass )
    #! if min is f, it means we just want to use the declared
    #! output class from the "infer-effect".
    dup [
        swap node-in-d
        [ value-class* math-closure math-class-max ] each
    ] [
        2drop f
    ] if ;

: won't-overflow? ( interval node -- ? )
    node-in-d [ value-class* fixnum class< ] all?
    swap fixnum fits? and ;

: post-process ( class interval node -- classes intervals )
    dupd won't-overflow?
    [ >r dup { f integer } member? [ drop fixnum ] when r> ] when
    [ dup [ 1array ] when ] 2apply ;

: math-output-interval-1 ( node word -- interval )
    dup [
        >r node-in-d first value-interval* dup
        [ r> execute ] [ r> 2drop f ] if
    ] [
        2drop f
    ] if ; inline

: math-output-class/interval-1 ( node min word -- classes intervals )
    pick >r
    >r over r>
    math-output-interval-1
    >r math-output-class r>
    r> post-process ; inline

{
    { 1+ integer interval-1+ }
    { 1- integer interval-1- }
    { neg integer interval-neg }
    { shift integer interval-recip }
    { bitnot fixnum interval-bitnot }
    { fixnum-bitnot f interval-bitnot }
    { bignum-bitnot f interval-bitnot }
    { 2/ fixnum interval-2/ }
    { sq integer f }
} [
    first3 [
        math-output-class/interval-1
    ] 2curry "output-classes" set-word-prop
] each

: intervals ( node -- i1 i2 )
    node-in-d first2 [ value-interval* ] 2apply ;

: math-output-interval-2 ( node word -- interval )
    dup [
        >r intervals 2dup and [ r> execute ] [ r> 3drop f ] if
    ] [
        2drop f
    ] if ; inline

: math-output-class/interval-2 ( node min word -- classes intervals )
    pick >r
    >r over r>
    math-output-interval-2
    >r math-output-class r>
    r> post-process ; inline

{
    { + integer interval+ }
    { - integer interval- }
    { * integer interval* }
    { / rational interval/ }
    { /i integer interval/i }

    { fixnum+ f interval+ }
    { fixnum+fast f interval+ }
    { fixnum- f interval- }
    { fixnum-fast f interval- }
    { fixnum* f interval* }
    { fixnum*fast f interval* }
    { fixnum/i f interval/i }

    { bignum+ f interval+ }
    { bignum- f interval- }
    { bignum* f interval* }
    { bignum/i f interval/i }
    { bignum-shift f interval-shift-safe }

    { float+ f interval+ }
    { float- f interval- }
    { float* f interval* }
    { float/f f interval/ }

    { min fixnum interval-min }
    { max fixnum interval-max }
} [
    first3 [
        math-output-class/interval-2
    ] 2curry "output-classes" set-word-prop
] each

{ fixnum-shift shift } [
    [
        dup
        node-in-d second value-interval*
        -1./0. 0 [a,b] interval-subset? fixnum integer ?
        \ interval-shift-safe
        math-output-class/interval-2
    ] "output-classes" set-word-prop
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
    { mod fixnum mod-range }
    { fixnum-mod f mod-range }
    { bignum-mod f mod-range }
    { float-mod f mod-range }

    { rem integer rem-range }

    { bitand fixnum bitand-range }
    { fixnum-bitand f bitand-range }

    { bitor fixnum f }
    { bitxor fixnum f }
} [
    first3 [
        math-output-class/interval-special
    ] 2curry "output-classes" set-word-prop
] each

: twiddle-interval ( i1 -- i2 )
    dup [
        node get node-in-d
        [ value-class* integer class< ] all?
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
        r> general-t (comparison-constraints)
        r> \ f (comparison-constraints)
    ] [
        r> r> 2drop 2drop
    ] if ; inline

{
    { < assume< assume>= }
    { <= assume<= assume> }
    { > assume> assume<= }
    { >= assume>= assume< }

    { fixnum< assume< assume>= }
    { fixnum<= assume<= assume> }
    { fixnum> assume> assume<= }
    { fixnum>= assume>= assume< }

    { bignum< assume< assume>= }
    { bignum<= assume<= assume> }
    { bignum> assume> assume<= }
    { bignum>= assume>= assume< }

    { float< assume< assume>= }
    { float<= assume<= assume> }
    { float> assume> assume<= }
    { float>= assume>= assume< }
} [
    first3
    [
        [ comparison-constraints ] with-scope
    ] 2curry "constraints" set-word-prop
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
    dup word-name {
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
    dup node-out-d first node-class fixnum class< ;

{
    { + [ fixnum+fast ] }
    { - [ fixnum-fast ] }
    { * [ fixnum*fast ] }
    { fixnum+ [ fixnum+fast ] }
    { fixnum- [ fixnum-fast ] }
    { fixnum* [ fixnum*fast ] }
    ! these are here as an optimization. if they weren't given
    ! explicitly, the same would be inferred after an extra
    ! optimization step (see optimistic-inline?)
    { 1+ [ 1 fixnum+fast ] }
    { 1- [ 1 fixnum-fast ] }
    { 2/ [ -1 fixnum-shift ] }
    { neg [ 0 swap fixnum-fast ] }
} [
    [
        [ dup remove-overflow-check? ] ,
        [ splice-quot ] curry ,
    ] { } make 1array define-optimizers
] assoc-each

! Remove redundant comparisons
: known-comparison? ( #call -- ? )
    dup dup node-in-d first node-interval
    swap dup node-in-d second node-literal real? and ;

: perform-comparison ( #call word -- result )
    >r dup dup node-in-d first node-interval
    swap dup node-in-d second node-literal r> execute ; inline

: foldable-comparison? ( #call word -- )
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

    { fixnum< interval< }
    { fixnum<= interval<= }
    { fixnum> interval> }
    { fixnum>= interval>= }

    { bignum< interval< }
    { bignum<= interval<= }
    { bignum> interval> }
    { bignum>= interval>= }

    { float< interval< }
    { float<= interval<= }
    { float> interval> }
    { float>= interval>= }
} [
    [
        dup [ dupd foldable-comparison? ] curry ,
        [ fold-comparison ] curry ,
    ] { } make 1array define-optimizers
] assoc-each

! The following words are handled in a similar way except if
! the only consumer is a >fixnum we remove the overflow check
! too
: consumed-by? ( node word -- ? )
    swap sole-consumer
    dup #call? [ node-param eq? ] [ 2drop f ] if ;

: coereced-to-fixnum? ( #call -- ? )
    \ >fixnum consumed-by? ;

{
    { fixnum+ [ fixnum+fast ] }
    { fixnum- [ fixnum-fast ] }
    { fixnum* [ fixnum*fast ] }
} [
    [
        [
            dup remove-overflow-check?
            over coereced-to-fixnum? or
        ] ,
        [ splice-quot ] curry ,
    ] { } make 1array define-optimizers
] assoc-each
