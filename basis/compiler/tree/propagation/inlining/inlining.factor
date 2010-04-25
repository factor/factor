! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel arrays sequences math math.order
math.partial-dispatch generic generic.standard generic.single generic.math
classes.algebra classes.union sets quotations assocs combinators
combinators.short-circuit words namespaces continuations classes
fry hints locals
compiler.tree
compiler.tree.builder
compiler.tree.recursive
compiler.tree.combinators
compiler.tree.normalization
compiler.tree.propagation.info
compiler.tree.propagation.nodes ;
IN: compiler.tree.propagation.inlining

! Splicing nodes
: splicing-call ( #call word -- nodes )
    [ [ in-d>> ] [ out-d>> ] bi ] dip #call 1array ;

: open-code-#call ( #call word/quot -- nodes/f )
    [ [ in-d>> ] [ out-d>> ] bi ] dip build-sub-tree ;

: splicing-body ( #call quot/word -- nodes/f )
    open-code-#call dup [ analyze-recursive normalize ] when ;

! Dispatch elimination
: undo-inlining ( #call -- ? )
    f >>method f >>body f >>class drop f ;

: propagate-body ( #call -- ? )
    body>> (propagate) t ;

GENERIC: splicing-nodes ( #call word/quot -- nodes/f )

M: word splicing-nodes splicing-call ;

M: callable splicing-nodes splicing-body ;

: eliminate-dispatch ( #call class/f word/quot/f -- ? )
    dup [
        [ >>class ] dip
        over method>> over = [ drop propagate-body ] [
            2dup splicing-nodes dup [
                [ >>method ] [ >>body ] bi* propagate-body
            ] [ 2drop undo-inlining ] if
        ] if
    ] [ 2drop undo-inlining ] if ;

ERROR: bad-splitting class generic ;

:: split-code ( class generic -- quot/f )
    class generic method-for-class
    [ class generic bad-splitting ] unless
    [
        dup class instance?
        [ generic execute ]
        [ generic no-method ] if
    ] ;

:: find-method-call ( class generic -- subclass/f )
    generic method-classes [ f ] [
        f swap [| last-class new-class |
            class new-class classes-intersect? [
                last-class [ f f ] [ new-class t ] if
            ] [ last-class t ] if
        ] all? swap and
    ] if-empty ;

:: split-method-call ( class generic -- quot/f )
    class generic find-method-call
    [ generic split-code ] [ f ] if* ;

: inlining-standard-method ( #call word -- class/f method/f )
    dup "methods" word-prop assoc-empty? [ 2drop f f ] [
        2dup [ in-d>> length ] [ dispatch# ] bi* <= [ 2drop f f ] [
            [ in-d>> <reversed> ] [ [ dispatch# ] keep ] bi*
            [ swap nth value-info class>> dup ] dip
            { [ method-for-class ] [ split-method-call ] } 2||
        ] if
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

! Method body inlining
SYMBOL: history

: already-inlined? ( obj -- ? ) history get member-eq? ;

: add-to-history ( obj -- ) history [ swap suffix ] change ;

:: inline-word ( #call word -- ? )
    word already-inlined? [ f ] [
        #call word splicing-body [
            word add-to-history
            #call (>>body)
            #call propagate-body
        ] [ f ] if*
    ] if ;

: always-inline-word? ( word -- ? )
    { curry compose } member-eq? ;

: never-inline-word? ( word -- ? )
    { [ deferred? ] [ "default" word-prop ] [ \ call eq? ] } 1|| ;

: custom-inlining? ( word -- ? )
    "custom-inlining" word-prop ;

: inline-custom ( #call word -- ? )
    [ dup ] [ "custom-inlining" word-prop ] bi*
    call( #call -- word/quot/f )
    object swap eliminate-dispatch ;

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
        { [ dup always-inline-word? ] [ inline-word ] }
        { [ dup standard-generic? ] [ inline-standard-method ] }
        { [ dup math-generic? ] [ inline-math-method ] }
        { [ dup inline? ] [ inline-word ] }
        [ 2drop f ]
    } cond ;

: do-inlining ( #call word -- ? )
    #! Note the logic here: if there's a custom inlining hook,
    #! it is permitted to return f, which means that we try the
    #! normal inlining heuristic.
    [
        dup custom-inlining? [ 2dup inline-custom ] [ f ] if
        [ 2drop t ] [ (do-inlining) ] if
    ] with-scope ;
