! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel effects accessors math math.private
math.integers.private math.floats.private math.partial-dispatch
math.intervals math.parser math.order math.functions math.libm
layouts words sequences sequences.private arrays assocs classes
classes.algebra combinators generic.math splitting fry locals
classes.tuple alien.accessors classes.tuple.private
slots.private definitions strings.private vectors hashtables
generic quotations alien
stack-checker.dependencies
compiler.tree.comparisons
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.slots
compiler.tree.propagation.simple
compiler.tree.propagation.constraints
compiler.tree.propagation.call-effect
compiler.tree.propagation.transforms
compiler.tree.propagation.simd ;
FROM: alien.c-types => (signed-interval) (unsigned-interval) ;
IN: compiler.tree.propagation.known-words

{ + - * / }
[ { number number } "input-classes" set-word-prop ] each

{ /f < > <= >= u< u> u<= u>= }
[ { real real } "input-classes" set-word-prop ] each

{ /i mod /mod }
[ { rational rational } "input-classes" set-word-prop ] each

{ bitand bitor bitxor bitnot shift }
[ { integer integer } "input-classes" set-word-prop ] each

\ bitnot { integer } "input-classes" set-word-prop

: math-closure ( class -- newclass )
    { fixnum bignum integer rational float real number object }
    [ class<= ] with find nip ;

: fits-in-fixnum? ( interval -- ? )
    fixnum-interval interval-subset? ;

: won't-overflow? ( class interval -- ? )
    [ fixnum class<= ] [ fits-in-fixnum? ] bi* and ;

: may-overflow ( class interval -- class' interval' )
    over null-class? [
        2dup won't-overflow?
        [ [ integer math-class-max ] dip ] unless
    ] unless ;

: may-be-rational ( class interval -- class' interval' )
    over null-class? [
        [ rational math-class-max ] dip
    ] unless ;

: ensure-math-class ( class must-be -- class' )
    [ class<= ] most ;

: number-valued ( class interval -- class' interval' )
    [ number ensure-math-class ] dip ;

: fixnum-valued ( class interval -- class' interval' )
    over null-class? [
        [ drop fixnum ] dip
    ] unless ;

: integer-valued ( class interval -- class' interval' )
    [ integer ensure-math-class ] dip ;

: real-valued ( class interval -- class' interval' )
    [ real ensure-math-class ] dip ;

: float-valued ( class interval -- class' interval' )
    over null-class? [
        [ drop float ] dip
    ] unless ;

: unary-op-class ( info -- newclass )
    class>> dup null-class? [ drop null ] [ math-closure ] if ;

: unary-op-interval ( info quot -- newinterval )
    [
        dup class>> real classes-intersect?
        [ interval>> ] [ drop full-interval ] if
    ] dip call ; inline

: unary-op ( word interval-quot post-proc-quot -- )
    '[
        [ unary-op-class ] [ _ unary-op-interval ] bi
        @
        <class/interval-info>
    ] "outputs" set-word-prop ;

{ bitnot fixnum-bitnot bignum-bitnot } [
    [ interval-bitnot ] [ integer-valued ] unary-op
] each

\ abs [ interval-abs ] [ may-overflow real-valued ] unary-op

\ absq [ interval-absq ] [ may-overflow real-valued ] unary-op

: binary-op-class ( info1 info2 -- newclass )
    [ class>> ] bi@
    2dup [ null-class? ] either? [ 2drop null ] [
        [ math-closure ] bi@ math-class-max
    ] if ;

: binary-op-interval ( info1 info2 quot -- newinterval )
    [ [ interval>> ] bi@ ] dip call ; inline

: binary-op ( word interval-quot post-proc-quot -- )
    '[
        [ binary-op-class ] [ _ binary-op-interval ] 2bi
        @
        <class/interval-info>
    ] "outputs" set-word-prop ;

\ + [ [ interval+ ] [ may-overflow number-valued ] binary-op ] each-derived-op
\ + [ [ interval+ ] [ number-valued ] binary-op ] each-fast-derived-op

\ - [ [ interval- ] [ may-overflow number-valued ] binary-op ] each-derived-op
\ - [ [ interval- ] [ number-valued ] binary-op ] each-fast-derived-op

\ * [ [ interval* ] [ may-overflow number-valued ] binary-op ] each-derived-op
\ * [ [ interval* ] [ number-valued ] binary-op ] each-fast-derived-op

\ / [ [ interval/-safe ] [ may-be-rational number-valued ] binary-op ] each-derived-op
\ /i [ [ interval/i ] [ may-overflow integer-valued ] binary-op ] each-derived-op
\ /f [ [ interval/f ] [ float-valued ] binary-op ] each-derived-op

\ mod [ [ interval-mod ] [ real-valued ] binary-op ] each-derived-op
\ rem [ [ interval-rem ] [ may-overflow real-valued ] binary-op ] each-derived-op

{ /mod fixnum/mod } [
    \ /i \ mod
    [ "outputs" word-prop ] bi@
    '[ _ _ 2bi ] "outputs" set-word-prop
] each

: shift-op-class ( info1 info2 -- newclass )
    [ class>> ] bi@
    2dup [ null-class? ] either? [ 2drop null ] [ drop math-closure ] if ;

: shift-op ( word interval-quot post-proc-quot -- )
    '[
        [ shift-op-class ] [ _ binary-op-interval ] 2bi
        @
        <class/interval-info>
    ] "outputs" set-word-prop ;

\ shift [ [ interval-shift-safe ] [ may-overflow integer-valued ] shift-op ] each-derived-op
\ shift [ [ interval-shift-safe ] [ integer-valued ] shift-op ] each-fast-derived-op

\ bitand [ [ interval-bitand ] [ integer-valued ] binary-op ] each-derived-op
\ bitor [ [ interval-bitor ] [ integer-valued ] binary-op ] each-derived-op
\ bitxor [ [ interval-bitxor ] [ integer-valued ] binary-op ] each-derived-op

:: (comparison-constraints) ( in1 in2 op -- constraint )
    in1 value-info interval>> :> i1
    in2 value-info interval>> :> i2
    in1 i1 i2 op assumption is-in-interval
    in2 i2 i1 op swap-comparison assumption is-in-interval
    /\ ;

:: comparison-constraints ( in1 in2 out op -- constraint )
    in1 in2 op (comparison-constraints) out t-->
    in1 in2 op negate-comparison (comparison-constraints) out f--> /\ ;

: define-comparison-constraints ( word op -- )
    '[ _ comparison-constraints ] "constraints" set-word-prop ;

comparison-ops
[ dup '[ _ define-comparison-constraints ] each-derived-op ] each

! Remove redundant comparisons
: fold-comparison ( info1 info2 word -- info )
    [ [ interval>> ] bi@ ] dip interval-comparison {
        { incomparable [ object-info ] }
        { t [ t <literal-info> ] }
        { f [ f <literal-info> ] }
    } case ;

comparison-ops [
    dup '[
        [ _ fold-comparison ] "outputs" set-word-prop
    ] each-derived-op
] each

generic-comparison-ops [
    dup specific-comparison
    '[ _ fold-comparison ] "outputs" set-word-prop
] each

: maybe-or-never ( ? -- info )
    [ object-info ] [ f <literal-info> ] if ;

: info-intervals-intersect? ( info1 info2 -- ? )
    2dup [ class>> real class<= ] both?
    [ [ interval>> ] bi@ intervals-intersect? ] [ 2drop t ] if ;

{ number= bignum= float= } [
    [
        info-intervals-intersect? maybe-or-never
    ] "outputs" set-word-prop
] each

: info-classes-intersect? ( info1 info2 -- ? )
    [ class>> ] bi@ classes-intersect? ;

\ eq? [
    over value-info literal>> fixnum? [
        [ value-info literal>> is-equal-to ] dip t-->
    ] [ 3drop f ] if
] "constraints" set-word-prop

\ eq? [
    [ info-intervals-intersect? ]
    [ info-classes-intersect? ]
    2bi and maybe-or-never
] "outputs" set-word-prop

\ both-fixnums? [
    [ class>> ] bi@ {
        { [ 2dup [ fixnum classes-intersect? not ] either? ] [ f <literal-info> ] }
        { [ 2dup [ fixnum class<= ] both? ] [ t <literal-info> ] }
        [ object-info ]
    } cond 2nip
] "outputs" set-word-prop

{
    { >fixnum fixnum }
    { bignum>fixnum fixnum }

    { >bignum bignum }
    { fixnum>bignum bignum }
    { float>bignum bignum }

    { >float float }
    { fixnum>float float }
    { bignum>float float }

    { >integer integer }
} [
    '[ _ swap interval>> <class/interval-info> ] "outputs" set-word-prop
] assoc-each

{ numerator denominator }
[ [ drop integer <class-info> ] "outputs" set-word-prop ] each

{ (log2) fixnum-log2 bignum-log2 } [
    [
        [ class>> ] [ interval>> interval-log2 ] bi <class/interval-info>
    ] "outputs" set-word-prop
] each

\ string-nth [
    2drop fixnum 0 23 2^ [a,b] <class/interval-info>
] "outputs" set-word-prop

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
        { [ "alien-signed-" ?head ] [ string>number (signed-interval) ] }
        { [ "alien-unsigned-" ?head ] [ string>number (unsigned-interval) ] }
    } cond [a,b]
    [ fits-in-fixnum? fixnum integer ? ] keep <class/interval-info>
    '[ 2drop _ ] "outputs" set-word-prop
] each

\ alien-cell [
    2drop alien \ f class-or <class-info>
] "outputs" set-word-prop

{ <tuple> <tuple-boa> } [
    [
        literal>> dup array? [ first ] [ drop tuple ] if <class-info>
        [ clear ] dip
    ] "outputs" set-word-prop
] each

\ new [
    literal>> dup tuple-class? [ drop tuple ] unless <class-info>
] "outputs" set-word-prop

! the output of clone has the same type as the input
: cloned-value-info ( value-info -- value-info' )
    clone f >>literal f >>literal?
    [ [ dup [ cloned-value-info ] when ] map ] change-slots ;

{ clone (clone) } [
    [ cloned-value-info ] "outputs" set-word-prop
] each

\ slot [
    dup literal?>>
    [ literal>> swap value-info-slot ] [ 2drop object-info ] if
] "outputs" set-word-prop

\ instance? [
    [ value-info ] dip over literal>> class? [
        [ literal>> ] dip predicate-constraints
    ] [ 3drop f ] if
] "constraints" set-word-prop

\ instance? [
    ! We need to force the caller word to recompile when the class
    ! is redefined, since now we're making assumptions but the
    ! class definition itself.
    dup literal>> class?
    [
        literal>>
        [ inlined-dependency depends-on ]
        [ predicate-output-infos ]
        bi
    ] [ 2drop object-info ] if
] "outputs" set-word-prop

{ facos fasin fatan fatan2 fcos fsin ftan fcosh fsinh ftanh fexp
flog fpow fsqrt facosh fasinh fatanh } [
    { float } "default-output-classes" set-word-prop
] each

! Find a less repetitive way of doing this
\ float-min { float float } "input-classes" set-word-prop
\ float-min [ interval-min ] [ float-valued ] binary-op

\ float-max { float float } "input-classes" set-word-prop
\ float-max [ interval-max ] [ float-valued ] binary-op

\ fixnum-min { fixnum fixnum } "input-classes" set-word-prop
\ fixnum-min [ interval-min ] [ fixnum-valued ] binary-op

\ fixnum-max { fixnum fixnum } "input-classes" set-word-prop
\ fixnum-max [ interval-max ] [ fixnum-valued ] binary-op
