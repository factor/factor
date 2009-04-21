! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel arrays sequences math math.order
math.partial-dispatch generic generic.standard generic.math
classes.algebra classes.union sets quotations assocs combinators
words namespaces continuations classes fry combinators.smart hints
compiler.tree
compiler.tree.builder
compiler.tree.recursive
compiler.tree.combinators
compiler.tree.normalization
compiler.tree.propagation.info
compiler.tree.propagation.nodes ;
IN: compiler.tree.propagation.inlining

! We count nodes up-front; if there are relatively few nodes,
! we are more eager to inline
SYMBOL: node-count

: count-nodes ( nodes -- n )
    0 swap [ drop 1+ ] each-node ;

: compute-node-count ( nodes -- ) count-nodes node-count set ;

! We try not to inline the same word too many times, to avoid
! combinatorial explosion
SYMBOL: inlining-count

! Splicing nodes
GENERIC: splicing-nodes ( #call word/quot/f -- nodes )

M: word splicing-nodes
    [ [ in-d>> ] [ out-d>> ] bi ] dip #call 1array ;

M: callable splicing-nodes
    build-sub-tree analyze-recursive normalize ;

! Dispatch elimination
: eliminate-dispatch ( #call class/f word/quot/f -- ? )
    dup [
        [ >>class ] dip
        over method>> over = [ drop ] [
            2dup splicing-nodes
            [ >>method ] [ >>body ] bi*
        ] if
        body>> (propagate) t
    ] [ 2drop f >>method f >>body f >>class drop f ] if ;

: inlining-standard-method ( #call word -- class/f method/f )
    dup "methods" word-prop assoc-empty? [ 2drop f f ] [
        [ in-d>> <reversed> ] [ [ dispatch# ] keep ] bi*
        [ swap nth value-info class>> dup ] dip
        specific-method
    ] if ;

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

: inlining-math-method ( #call word -- class/f quot/f )
    swap in-d>>
    first2 [ value-info class>> normalize-math-class ] bi@
    3dup math-both-known?
    [ math-method* ] [ 3drop f ] if
    number swap ;

: inline-math-method ( #call word -- ? )
    dupd inlining-math-method eliminate-dispatch ;

: inlining-math-partial ( #call word -- class/f quot/f )
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
        ! special-case
        { [ dup { dip 2dip 3dip } memq? ] [ drop 1 ] }
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
    ] any? ;

: node-count-bias ( -- n )
    45 node-count get [-] 8 /i ;

: body-length-bias ( word -- n )
    [ flat-length ] [ inlining-count get at 0 or ] bi
    over 2 <= [ drop ] [ 2/ 1+ * ] if 24 swap [-] 4 /i ;

: inlining-rank ( #call word -- n )
    [
        [ classes-known? 2 0 ? ]
        [
            [ body-length-bias ]
            [ "specializer" word-prop 1 0 ? ]
            [ method-body? 1 0 ? ]
            tri
            node-count-bias
            loop-nesting get 0 or 2 *
        ] bi*
    ] sum-outputs ;

: should-inline? ( #call word -- ? )
    {
        { [ dup contains-breakpoints? ] [ 2drop f ] }
        { [ dup "inline" word-prop ] [ 2drop t ] }
        [ inlining-rank 5 >= ]
    } cond ;

SYMBOL: history

: remember-inlining ( word -- )
    [ inlining-count get inc-at ]
    [ history [ swap suffix ] change ]
    bi ;

: inline-word-def ( #call word quot -- ? )
    over history get memq? [ 3drop f ] [
        [
            [ remember-inlining ] dip
            [ drop ] [ splicing-nodes ] 2bi
            [ >>body drop ] [ count-nodes ] [ (propagate) ] tri
        ] with-scope node-count +@
        t
    ] if ;

: inline-word ( #call word -- ? )
    dup specialized-def inline-word-def ;

: inline-method-body ( #call word -- ? )
    2dup should-inline? [ inline-word ] [ 2drop f ] if ;

: always-inline-word? ( word -- ? )
    { curry compose } memq? ;

: never-inline-word? ( word -- ? )
    [ deferred? ]
    [ "default" word-prop ]
    [ { call execute } memq? ] tri or or ;

: custom-inlining? ( word -- ? )
    "custom-inlining" word-prop ;

: inline-custom ( #call word -- ? )
    [ dup ] [ "custom-inlining" word-prop ] bi*
    call( #call -- word/quot/f )
    object swap eliminate-dispatch ;

: inline-instance-check ( #call word -- ? )
    over in-d>> second value-info literal>> dup class?
    [ "predicate" word-prop '[ drop @ ] inline-word-def ] [ 3drop f ] if ;

: (do-inlining) ( #call word -- ? )
    #! If the generic was defined in an outer compilation unit,
    #! then it doesn't have a definition yet; the definition
    #! is built at the end of the compilation unit. We do not
    #! attempt inlining at this stage since the stack discipline
    #! is not finalized yet, so dispatch# might return an out
    #! of bounds value. This case comes up if a parsing word
    #! calls the compiler at parse time (doing so is
    #! discouraged, but it should still work.)
    {
        { [ dup never-inline-word? ] [ 2drop f ] }
        { [ dup \ instance? eq? ] [ inline-instance-check ] }
        { [ dup always-inline-word? ] [ inline-word ] }
        { [ dup standard-generic? ] [ inline-standard-method ] }
        { [ dup math-generic? ] [ inline-math-method ] }
        { [ dup method-body? ] [ inline-method-body ] }
        [ 2drop f ]
    } cond ;

: do-inlining ( #call word -- ? )
    #! Note the logic here: if there's a custom inlining hook,
    #! it is permitted to return f, which means that we try the
    #! normal inlining heuristic.
    dup custom-inlining? [ 2dup inline-custom ] [ f ] if
    [ 2drop t ] [ (do-inlining) ] if ;
