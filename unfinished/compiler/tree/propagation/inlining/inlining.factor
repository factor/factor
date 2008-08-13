! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel arrays sequences math math.order
math.partial-dispatch generic generic.standard classes.algebra
classes.union sets quotations assocs combinators words
namespaces
compiler.tree
compiler.tree.builder
compiler.tree.normalization
compiler.tree.propagation.info
compiler.tree.propagation.nodes ;
IN: compiler.tree.propagation.inlining

! Splicing nodes
GENERIC: splicing-nodes ( #call word/quot/f -- nodes )

M: word splicing-nodes
    [ [ in-d>> ] [ out-d>> ] bi ] dip #call 1array ;

M: quotation splicing-nodes
    build-sub-tree normalize ;

: propagate-body ( #call -- )
    body>> (propagate) ;

! Dispatch elimination
: eliminate-dispatch ( #call word/quot/f -- ? )
    [
        over method>> over = [ drop ] [
            2dup splicing-nodes
            [ >>method ] [ >>body ] bi*
        ] if
        propagate-body t
    ] [ f >>method f >>body drop f ] if* ;

: inlining-standard-method ( #call word -- method/f )
    [ in-d>> <reversed> ] [ [ dispatch# ] keep ] bi*
    [ swap nth value-info class>> ] dip
    specific-method ;

: inline-standard-method ( #call word -- ? )
    dupd inlining-standard-method eliminate-dispatch ;

: normalize-math-class ( class -- class' )
    {
        null
        fixnum bignum integer
        ratio rational
        float real
        complex number
        object
    } [ class<= ] with find nip ;

: inlining-math-method ( #call word -- quot/f )
    swap in-d>>
    first2 [ value-info class>> normalize-math-class ] bi@
    3dup math-both-known? [ math-method* ] [ 3drop f ] if ;

: inline-math-method ( #call word -- ? )
    dupd inlining-math-method eliminate-dispatch ;

: inlining-math-partial ( #call word -- quot/f )
    [ "derived-from" word-prop first inlining-math-method ]
    [ nip 1quotation ] 2bi
    [ = not ] [ drop ] 2bi and ;

: inline-math-partial ( #call word -- ? )
    dupd inlining-math-partial eliminate-dispatch ;

! Method body inlining
SYMBOL: recursive-calls
DEFER: (flat-length)

: word-flat-length ( word -- n )
    {
        ! not inline
        { [ dup inline? not ] [ drop 1 ] }
        ! recursive and inline
        { [ dup recursive-calls get key? ] [ drop 10 ] }
        ! inline
        [ [ recursive-calls get conjoin ] [ def>> (flat-length) ] bi ]
    } cond ;

: (flat-length) ( seq -- n )
    [
        {
            { [ dup quotation? ] [ (flat-length) 2 + ] }
            { [ dup array? ] [ (flat-length) ] }
            { [ dup word? ] [ word-flat-length ] }
            [ drop 0 ]
        } cond
    ] sigma ;

: flat-length ( word -- n )
    H{ } clone recursive-calls [
        [ recursive-calls get conjoin ]
        [ def>> (flat-length) 5 /i ]
        bi
    ] with-variable ;

: classes-known? ( #call -- ? )
    in-d>> [
        value-info class>>
        [ class-types length 1 = ]
        [ union-class? not ]
        bi and
    ] contains? ;

: inlining-rank ( #call word -- n )
    [ classes-known? 2 0 ? ]
    [
        {
            [ flat-length 24 swap [-] 4 /i ]
            [ "default" word-prop -4 0 ? ]
            [ "specializer" word-prop 1 0 ? ]
            [ method-body? 1 0 ? ]
        } cleave
    ] bi* + + + + ;

: should-inline? ( #call word -- ? )
    inlining-rank 5 >= ;

SYMBOL: history

: remember-inlining ( word -- )
    history get [ swap suffix ] change ;

: inline-word ( #call word -- )
    dup history get memq? [
        2drop
    ] [
        [
            dup remember-inlining
            dupd def>> splicing-nodes >>body
            propagate-body
        ] with-scope
    ] if ;

: inline-method-body ( #call word -- ? )
    2dup should-inline? [ inline-word t ] [ 2drop f ] if ;

: always-inline-word? ( word -- ? )
    { curry compose } memq? ;

: always-inline-word ( #call word -- ? ) inline-word t ;
