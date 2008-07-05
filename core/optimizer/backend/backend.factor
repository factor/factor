! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs inference inference.class
inference.dataflow inference.backend inference.state io kernel
math namespaces sequences vectors words quotations hashtables
combinators classes optimizer.def-use accessors ;
IN: optimizer.backend

SYMBOL: class-substitutions

SYMBOL: literal-substitutions

SYMBOL: value-substitutions

SYMBOL: optimizer-changed

GENERIC: optimize-node* ( node -- node/t changed? )

: ?union ( assoc assoc/f -- assoc' )
    dup assoc-empty? [ drop ] [ swap assoc-union ] if ;

: add-node-literals ( node assoc -- )
    [ ?union ] curry change-literals drop ;

: add-node-classes ( node assoc -- )
    [ ?union ] curry change-classes drop ;

: substitute-values ( node assoc -- )
    dup assoc-empty? [
        2drop
    ] [
        {
            [ >r  in-d>> r> substitute-here ]
            [ >r  in-r>> r> substitute-here ]
            [ >r out-d>> r> substitute-here ]
            [ >r out-r>> r> substitute-here ]
        } 2cleave
    ] if ;

: perform-substitutions ( node -- )
    [   class-substitutions get add-node-classes  ]
    [ literal-substitutions get add-node-literals ]
    [   value-substitutions get substitute-values ]
    tri ;

DEFER: optimize-nodes

: optimize-children ( node -- )
    [ optimize-nodes ] map-children ;

: optimize-node ( node -- node )
    dup [
        dup perform-substitutions
        dup optimize-node* [
            nip optimizer-changed on optimize-node
        ] [
            dup t eq? [
                drop dup optimize-children
            ] [
                nip optimize-node
            ] if
        ] if
    ] when ;

: optimize-nodes ( node -- newnode )
    [
        class-substitutions [ clone ] change
        literal-substitutions [ clone ] change
        [ optimize-node ] transform-nodes
        optimizer-changed get
    ] with-scope optimizer-changed set ;

M: node optimize-node* drop t f ;

! Post-inlining cleanup
: follow ( key assoc -- value )
    2dup at* [ swap follow nip ] [ 2drop ] if ;

: union* ( assoc1 assoc2 -- assoc )
    assoc-union [ keys ] keep
    [ dupd follow ] curry
    H{ } map>assoc ;

: update* ( assoc1 assoc2 -- )
    #! Not very efficient.
    dupd union* update ;

: compute-value-substitutions ( #call/#merge #return/#values -- assoc )
    [ out-d>> ] [ in-d>> ] bi* 2array unify-lengths flip
    [ = not ] assoc-filter >hashtable ;

: cleanup-inlining ( #return/#values -- newnode changed? )
    dup node-successor [
        [ node-successor ] keep
        {
            [ nip classes>> class-substitutions get swap update ]
            [ nip literals>> literal-substitutions get swap update ]
            [ compute-value-substitutions value-substitutions get swap update* ]
            [ drop node-successor ]
        } 2cleave t
    ] [
        drop t f
    ] if ;

! #return
M: #return optimize-node* cleanup-inlining ;

! #values
M: #values optimize-node* cleanup-inlining ;

M: f set-node-successor 2drop ;

: splice-node ( old new -- )
    dup splice-def-use last-node set-node-successor ;

: drop-inputs ( node -- #shuffle )
    node-in-d clone \ #shuffle in-node ;

: optimizer-hooks ( node -- conditions )
    param>> "optimizer-hooks" word-prop ;

: optimizer-hook ( node -- pair/f )
    dup optimizer-hooks [ first call ] find 2nip ;

: optimize-hook ( node -- )
    dup optimizer-hook second call ;

: define-optimizers ( word optimizers -- )
    "optimizer-hooks" set-word-prop ;
