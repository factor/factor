! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.algebra combinators
combinators.short-circuit compiler.tree compiler.tree.builder
compiler.tree.normalization compiler.tree.propagation.info
compiler.tree.propagation.nodes compiler.tree.recursive effects
generic generic.math generic.single generic.standard kernel
kernel.private locals math math.order math.partial-dispatch
multi-generic namespaces quotations sequences words ;
IN: compiler.tree.propagation.inlining

: splicing-call ( #call word -- nodes )
    [ [ in-d>> ] [ out-d>> ] bi ] dip <#call> 1array ;

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

: inlining-standard-method ( #call word -- class/f method/f )
    dup "methods" word-prop assoc-empty? [ 2drop f f ] [
        2dup [ in-d>> length ] [ dispatch# ] bi* <= [ 2drop f f ] [
            [ in-d>> <reversed> ] [ [ dispatch# ] keep ] bi*
            [ swap nth value-info class>> dup ] dip
            method-for-class
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
            #call body<<
            #call propagate-body
        ] [ f ] if*
    ] if ;

: always-inline-word? ( word -- ? )
    { curry compose } member-eq? ;

: never-inline-word? ( word -- ? )
    { [ deferred? ] [ "default" word-prop ] [ \ call eq? ] } 1|| ;

: custom-inlining? ( word -- quot/f )
    "custom-inlining" word-prop ;

: inline-custom ( #call word -- ? )
    [ dup ] [ custom-inlining? ] bi*
    call( #call -- word/quot/f )
    object swap eliminate-dispatch ;

::  worst-literal-length ( methods -- len )
    methods first first length :> len
    methods 0 [
        first [ object = not ] find drop dup [ len swap - ] [ drop 0 ] if
        max
    ] reduce ;

:: inlining-multi-dispatch-method ( #call word -- classes/f method/f )
    word "hooks" word-prop empty? [
        word methods :> word-methods
        #call in-d>> >array [ value-info class>> ] map
        dup length :> stack-len
        dup [ object = ] find-last [| classes i |
            i object <array> 0 i classes replace-slice
        ] [ drop ] if :> stack-info
        word-methods empty? [ f f ] [
            word-methods first first length :> len1
            word-methods worst-literal-length :> len2
            stack-info [ object = ] reject length len2 >= [
                ! method inlining
                len1 len2 - object <array>
                stack-info [ length dup len2 - swap ] keep subseq
                append
                word-methods spec-boolean-table [
                    [ drop object ] unless
                ] 2map
                dup word ?lookup-multi-method dup [ 2drop f f ] unless
            ] [
                ! partical inline
                word "partial-inline" word-prop [
                    stack-info [ object = ] all? [ f f ] [
                        word-methods
                        word multi-math-generic? [
                            [
                                drop first2 [ multi-generic:math-class? ] both?
                            ] assoc-reject
                        ] when
                        multi-generic:sort-methods [
                            drop stack-info swap t [
                                [ drop object = ] [ class<= ] 2bi or and
                            ] 2reduce
                        ] assoc-filter [
                            [
                                stack-info [| c1 c2 |
                                    c2 object = [ c1 ] [ object ] if
                                ] 2map
                            ] dip
                        ] assoc-map prepare-methods drop
                        dup empty? [ drop f f ] [
                            word multi-dispatch-quot
                            ! declare output classes
                            word methods dup empty? [ drop ] [
                                values t [
                                    "multi-method-effect" word-prop
                                    out>> [ dup array? [ second ] [ drop object ] if ] map
                                    over t = [ nip ] [ dup swap = not [ drop f ] when ] if
                                ] reduce [
                                    dup [ object = ] all? [ drop ] [
                                        \ declare 2array >quotation append
                                    ] if
                                ] when*
                            ] if
                            #call in-d>> >array [ value-info class>> ] map swap
                        ] if
                    ] if
                ] [ f f ] if
            ] if
        ] if
    ] [ f f ] if ;

: multi-math-both-known? ( word left right -- ? )
    3dup math-op
    [ 4drop t ]
    [ drop multi-generic:math-class-max
      swap single-method-for-class >boolean ] if ;

: multi-math-method* ( word left right -- quot )
    3dup math-op [ 3nip 1quotation ] [ drop multi-math-method ] if ;

:: inlining-multi-math-method ( #call word -- class/f quot/f )
    #call word
    swap in-d>> first2
    [ value-info class>> normalize-math-class ] bi@
    3dup multi-math-both-known? [ multi-math-method* ] [ 3drop f ] if
    number swap [
        ! Extended mathematical dispatch
        drop #call word inlining-multi-dispatch-method
    ] unless* ;

: inlining-multi-standard-method ( #call word -- class/f method/f )
    dup "dispatch-type" word-prop methods>> assoc-empty?
    [ 2drop f f ] [
        2dup [ in-d>> length ] [ single-dispatch# ] bi* <=
        [ 2drop f f ] [
            [ in-d>> <reversed> ] [ [ single-dispatch# ] keep ] bi*
            [ swap nth value-info class>> dup ] dip
            single-method-for-class
        ] if
    ] if ;

: inline-multi-standard-method ( #call word -- ? )
    dupd inlining-multi-standard-method eliminate-dispatch ;

: inline-multi-math-method ( #call word -- ? )
    dupd inlining-multi-math-method eliminate-dispatch ;

: inline-multi-dispatch-method ( #call word -- ? )
    dupd inlining-multi-dispatch-method eliminate-dispatch ;

: inlining-covariant-tuple-dispatch-method ( #call word -- class/f method/f )
     dup "dispatch-type" word-prop methods>> assoc-empty? [ 2drop f f ] [
         2dup [ in-d>> length ] [ multi-generic-arity ] bi* < [ 2drop f f ] [
             [ in-d>> ] [ [ multi-generic-arity ] keep ] bi*
             [ tail* [ value-info class>> ] map <covariant-tuple> dup ] dip
             single-method-for-class
         ] if
     ] if ;

 : inline-covariant-tuple-dispatch-method ( #call word -- ? )
     dupd inlining-covariant-tuple-dispatch-method eliminate-dispatch ;

: (do-inlining) ( #call word -- ? )
    {
        { [ dup never-inline-word? ] [ 2drop f ] }
        { [ dup always-inline-word? ] [ inline-word ] }
        { [ dup standard-generic? ] [ inline-standard-method ] }
        { [ dup math-generic? ] [ inline-math-method ] }
        { [ dup multi-standard-generic? ] [ inline-multi-standard-method ] }
        { [ dup multi-math-generic? ] [ inline-multi-math-method ] }
        { [ dup multi-dispatch-generic? ] [ inline-multi-dispatch-method ] }
        { [ dup covariant-tuple-dispatch-generic? ] [ inline-covariant-tuple-dispatch-method ] }
        { [ dup inline? ] [ inline-word ] }
        [ 2drop f ]
    } cond ;

: do-inlining ( #call word -- ? )
    [
        dup custom-inlining? [ 2dup inline-custom ] [ f ] if
        [ 2drop t ] [ (do-inlining) ] if
    ] with-scope ;
