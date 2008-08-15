! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel effects accessors math math.private math.libm
math.partial-dispatch math.intervals math.parser math.order
layouts words sequences sequences.private arrays assocs classes
classes.algebra combinators generic.math splitting fry locals
classes.tuple alien.accessors classes.tuple.private slots.private
compiler.tree.comparisons
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.slots
compiler.tree.propagation.simple
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.known-words

\ fixnum
most-negative-fixnum most-positive-fixnum [a,b]
+interval+ set-word-prop

\ array-capacity
0 max-array-capacity [a,b]
+interval+ set-word-prop

{ + - * / }
[ { number number } "input-classes" set-word-prop ] each

{ /f < > <= >= }
[ { real real } "input-classes" set-word-prop ] each

{ /i mod /mod }
[ { rational rational } "input-classes" set-word-prop ] each

{ bitand bitor bitxor bitnot shift }
[ { integer integer } "input-classes" set-word-prop ] each

\ bitnot { integer } "input-classes" set-word-prop

{
    fcosh
    flog
    fsinh
    fexp
    fasin
    facosh
    fasinh
    ftanh
    fatanh
    facos
    fpow
    fatan
    fatan2
    fcos
    ftan
    fsin
    fsqrt
} [
    dup stack-effect
    [ in>> length real <repetition> "input-classes" set-word-prop ]
    [ out>> length float <repetition> "default-output-classes" set-word-prop ]
    2bi
] each

: ?change-interval ( info quot -- quot' )
    over interval>> [ [ clone ] dip change-interval ] [ 2drop ] if ; inline

{ bitnot fixnum-bitnot bignum-bitnot } [
    [ [ interval-bitnot ] ?change-interval ] +outputs+ set-word-prop
] each

\ abs [ [ interval-abs ] ?change-interval ] +outputs+ set-word-prop

: math-closure ( class -- newclass )
    { fixnum bignum integer rational float real number object }
    [ class<= ] with find nip ;

: fits? ( interval class -- ? )
    +interval+ word-prop interval-subset? ;

: binary-op-class ( info1 info2 -- newclass )
    [ class>> ] bi@
    2dup [ null-class? ] either? [ 2drop null ] [
        [ math-closure ] bi@ math-class-max
    ] if ;

: binary-op-interval ( info1 info2 quot -- newinterval )
    [ [ interval>> ] bi@ ] dip call ; inline

: won't-overflow? ( class interval -- ? )
    [ fixnum class<= ] [ fixnum fits? ] bi* and ;

: may-overflow ( class interval -- class' interval' )
    over null-class? [
        2dup won't-overflow?
        [ [ integer math-class-max ] dip ] unless
    ] unless ;

: may-be-rational ( class interval -- class' interval' )
    over null-class? [
        [ rational math-class-max ] dip
    ] unless ;

: number-valued ( class interval -- class' interval' )
    [ number math-class-min ] dip ;

: integer-valued ( class interval -- class' interval' )
    [ integer math-class-min ] dip ;

: real-valued ( class interval -- class' interval' )
    [ real math-class-min ] dip ;

: float-valued ( class interval -- class' interval' )
    over null-class? [
        [ drop float ] dip
    ] unless ;

: binary-op ( word interval-quot post-proc-quot -- )
    '[
        [ binary-op-class ] [ , binary-op-interval ] 2bi
        @
        <class/interval-info>
    ] +outputs+ set-word-prop ;

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

\ shift [ [ interval-shift-safe ] [ may-overflow integer-valued ] binary-op ] each-derived-op
\ shift [ [ interval-shift-safe ] [ integer-valued ] binary-op ] each-fast-derived-op

\ bitand [ [ interval-bitand ] [ integer-valued ] binary-op ] each-derived-op
\ bitor [ [ interval-bitor ] [ integer-valued ] binary-op ] each-derived-op
\ bitxor [ [ interval-bitxor ] [ integer-valued ] binary-op ] each-derived-op

:: (comparison-constraints) ( in1 in2 op -- constraint )
    [let | i1 [ in1 value-info interval>> ]
           i2 [ in2 value-info interval>> ] |
       in1 i1 i2 op assumption is-in-interval
       in2 i2 i1 op swap-comparison assumption is-in-interval
       /\
    ] ;

:: comparison-constraints ( in1 in2 out op -- constraint )
    in1 in2 op (comparison-constraints) out t-->
    in1 in2 op negate-comparison (comparison-constraints) out f--> /\ ;

: define-comparison-constraints ( word op -- )
    '[ , comparison-constraints ] +constraints+ set-word-prop ;

comparison-ops
[ dup '[ , define-comparison-constraints ] each-derived-op ] each

generic-comparison-ops [
    dup specific-comparison
    '[ , , define-comparison-constraints ] each-derived-op
] each

! Remove redundant comparisons
: fold-comparison ( info1 info2 word -- info )
    [ [ interval>> ] bi@ ] dip interval-comparison {
        { incomparable [ object-info ] }
        { t [ t <literal-info> ] }
        { f [ f <literal-info> ] }
    } case ;

comparison-ops [
    dup '[
        [ , fold-comparison ] +outputs+ set-word-prop
    ] each-derived-op
] each

generic-comparison-ops [
    dup specific-comparison
    '[ , fold-comparison ] +outputs+ set-word-prop
] each

: maybe-or-never ( ? -- info )
    [ object-info ] [ f <literal-info> ] if ;

: info-intervals-intersect? ( info1 info2 -- ? )
    [ interval>> ] bi@ intervals-intersect? ;

{ number= bignum= float= } [
    [
        info-intervals-intersect? maybe-or-never
    ] +outputs+ set-word-prop
] each

: info-classes-intersect? ( info1 info2 -- ? )
    [ class>> ] bi@ classes-intersect? ;

\ eq? [
    over value-info literal>> fixnum? [
        [ value-info literal>> is-equal-to ] dip t-->
    ] [ 3drop f ] if
] +constraints+ set-word-prop

\ eq? [
    [ info-intervals-intersect? ]
    [ info-classes-intersect? ]
    2bi or maybe-or-never
] +outputs+ set-word-prop

{
    { >fixnum fixnum }
    { >bignum bignum }
    { >float float }
} [
    '[
        ,
        [ nip ] [
            [ interval>> ] [ class-interval ] bi*
            interval-intersect
        ] 2bi
        <class/interval-info>
    ] +outputs+ set-word-prop
] assoc-each

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
    } cond
    [ fixnum fits? fixnum bignum ? ] keep <class/interval-info>
    [ 2nip ] curry +outputs+ set-word-prop
] each

{ <tuple> <tuple-boa> } [
    [
        literal>> dup tuple-layout? [ class>> ] [ drop tuple ] if <class-info>
        [ clear ] dip
    ] +outputs+ set-word-prop
] each

\ new [
    literal>> dup tuple-class? [ drop tuple ] unless <class-info>
] +outputs+ set-word-prop

! the output of clone has the same type as the input
{ clone (clone) } [ [ ] +outputs+ set-word-prop ] each

\ slot [
    dup literal?>>
    [ literal>> swap value-info-slot ] [ 2drop object-info ] if
] +outputs+ set-word-prop

\ instance? [
    [ value-info ] dip over literal>> class? [
        [ literal>> ] dip predicate-constraints
    ] [ 3drop f ] if
] +constraints+ set-word-prop

\ instance? [
    dup literal>> class?
    [ literal>> predicate-output-infos ] [ 2drop object-info ] if
] +outputs+ set-word-prop
