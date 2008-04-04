! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs inference inference.class
inference.dataflow inference.backend inference.state io kernel
math namespaces sequences vectors words quotations hashtables
combinators classes optimizer.def-use ;
IN: optimizer.backend

SYMBOL: class-substitutions

SYMBOL: literal-substitutions

SYMBOL: value-substitutions

SYMBOL: optimizer-changed

GENERIC: optimize-node* ( node -- node/t changed? )

: ?union ( assoc/f assoc -- hash )
    over [ union ] [ nip ] if ;

: add-node-literals ( assoc node -- )
    over assoc-empty? [
        2drop
    ] [
        [ node-literals ?union ] keep set-node-literals
    ] if ;

: add-node-classes ( assoc node -- )
    over assoc-empty? [
        2drop
    ] [
        [ node-classes ?union ] keep set-node-classes
    ] if ;

: substitute-values ( assoc node -- )
    over assoc-empty? [
        2drop
    ] [
        2dup node-in-d swap substitute-here
        2dup node-in-r swap substitute-here
        2dup node-out-d swap substitute-here
        node-out-r swap substitute-here
    ] if ;

: perform-substitutions ( node -- )
    class-substitutions get over add-node-classes
    literal-substitutions get over add-node-literals
    value-substitutions get swap substitute-values ;

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
    union [ keys ] keep
    [ dupd follow ] curry
    H{ } map>assoc ;

: update* ( assoc1 assoc2 -- )
    #! Not very efficient.
    dupd union* update ;

: compute-value-substitutions ( #return/#values #call/#merge -- assoc )
    node-out-d swap node-in-d 2array unify-lengths flip
    [ = not ] assoc-subset >hashtable ;

: cleanup-inlining ( #return/#values -- newnode changed? )
    dup node-successor dup [
        class-substitutions get pick node-classes update
        literal-substitutions get pick node-literals update
        tuck compute-value-substitutions value-substitutions get swap update*
        node-successor t
    ] [
        2drop t f
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
