! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: alien arrays errors generic hashtables inference kernel
assocs math math-internals kernel-internals sequences words
parser class-inference vectors strings sbufs io namespaces
assocs quotations intervals sequences-internals ;

{ + bignum+ float+ fixnum+fast } {
    { { @ 0 } [ drop ] }
    { { 0 @ } [ nip ]  }
} define-identities

{ fixnum+ } {
    { { @ 0 } [ drop ] }
    { { 0 @ } [ nip ]  }
} define-identities

{ - fixnum- bignum- float- fixnum-fast } {
    { { @ 0 } [ drop ]    }
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
    { { @ 1 }  [ drop ]          }
    { { 1 @ }  [ nip ]           }
    { { @ 0 }  [ nip ]           }
    { { 0 @ }  [ drop ]          }
    { { @ -1 } [ drop 0 swap - ] }
    { { -1 @ } [ nip 0 swap - ]  }
} define-identities

{ / fixnum/i bignum/i float/f } {
    { { @ 1 }  [ drop ]          }
    { { @ -1 } [ drop 0 swap - ] }
} define-identities

{ fixnum-mod bignum-mod } {
    { { @ 1 }  [ 2drop 0 ] }
} define-identities

{ bitand fixnum-bitand bignum-bitand } {
    { { @ -1 } [ drop ] }
    { { -1 @ } [ nip  ] }
    { { @ @ }  [ drop ] }
    { { @ 0 }  [ nip  ] }
    { { 0 @ }  [ drop ] }
} define-identities

{ bitor fixnum-bitor bignum-bitor } {
    { { @ 0 }  [ drop ] }
    { { 0 @ }  [ nip  ] }
    { { @ @ }  [ drop ] }
    { { @ -1 } [ nip  ] }
    { { -1 @ } [ drop ] }
} define-identities

{ bitxor fixnum-bitxor bignum-bitxor } {
    { { @ 0 }  [ drop ]        }
    { { 0 @ }  [ nip  ]        }
    { { @ -1 } [ drop bitnot ] }
    { { -1 @ } [ nip  bitnot ] }
    { { @ @ }  [ 2drop 0 ]     }
} define-identities

{ shift fixnum-shift bignum-shift } {
    { { 0 @ } [ drop ] }
    { { @ 0 } [ drop ] }
} define-identities

: math-closure ( class -- newclass )
    { fixnum integer rational real number object }
    [ class< ] find-with nip ;

: fits? ( interval class -- ? )
    "interval" word-prop dup
    [ interval-subset? ] [ 2drop t ] if ;

: math-output-class ( node min -- newclass )
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
    [ >r dup integer eq? [ drop fixnum ] when r> ] when
    [ dup [ 1array ] when ] 2apply ;

: math-output-interval-1 ( node word -- interval )
    >r node-in-d first value-interval* r>
    2dup and [ execute ] [ 2drop f ] if ;

: math-output-class/interval-1 ( node min word -- classes intervals )
    pick >r
    >r over r>
    math-output-interval-1
    >r math-output-class r>
    r> post-process ;

{
    { 1+ integer interval-1+ }
    { 1- integer interval-1- }
    { neg integer interval-neg }
    { shift integer interval-recip }
    { bitnot fixnum interval-bitnot }
    { fixnum-bitnot f interval-bitnot }
    { bignum-bitnot f interval-bitnot }
    { 2/ fixnum interval-2/ }
} [
    first3 [
        math-output-class/interval-1
    ] curry curry "output-classes" set-word-prop
] each

: intervals ( node -- i1 i2 )
    node-in-d first2 [ value-interval* ] 2apply ;

: math-output-interval-2 ( node word -- interval )
    >r intervals r> 3dup and and [ execute ] [ 3drop f ] if ;

: math-output-class/interval-2 ( node min word -- classes intervals )
    pick >r
    >r over r>
    math-output-interval-2
    >r math-output-class r>
    r> post-process ;

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
    ] curry curry "output-classes" set-word-prop
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

: math-output-interval-special ( node word -- )
    >r node-in-d second real-value? r> and
    [ execute ] [ drop f ] if* ;

: math-output-class/interval-special ( node min word -- classes intervals )
    pick >r
    >r over r>
    math-output-interval-special
    >r math-output-class r>
    r> post-process ;

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
    ] curry curry "output-classes" set-word-prop
] each

: twiddle-interval ( i1 -- i2 )
    node get node-in-d
    [ value-class* fixnum class< ] all?
    [ integral-closure ] when ;

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
    ] curry curry "constraints" set-word-prop
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

! The following words are handled in a similar way except if
! the only consumer is a >fixnum we remove the overflow check
! too
: consumed-by? ( node word -- ? )
    swap node-out-d first used-by dup length 1 = [
        first dup #call? >r node-param eq? r> and
    ] [
        2drop f
    ] if ;

: coreced-to-fixnum? ( #call -- ? )
    \ >fixnum consumed-by? ;

{
    { fixnum+ [ fixnum+fast ] }
    { fixnum- [ fixnum-fast ] }
    { fixnum* [ fixnum*fast ] }
} [
    [
        [
            dup remove-overflow-check?
            over coreced-to-fixnum? or
        ] ,
        [ splice-quot ] curry ,
    ] { } make 1array define-optimizers
] assoc-each
