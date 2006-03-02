! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: compiler-backend generic hashtables inference kernel
lists math namespaces sequences vectors ;

GENERIC: optimize-node* ( node -- node/t )

: keep-optimizing ( node -- node ? )
    dup optimize-node* dup t =
    [ drop f ] [ nip keep-optimizing t or ] if ;

DEFER: optimize-node

: optimize-children ( node -- ? )
    f swap [
        node-children [ optimize-node swap >r or r> ] map
    ] keep set-node-children ;

: optimize-node ( node -- node ? )
    #! Outputs t if any changes were made.
    keep-optimizing >r dup [
        dup optimize-children >r
        dup node-successor optimize-node >r
        over set-node-successor r> r> r> or or
    ] [ r> ] if ;

: optimize-1 ( dataflow -- dataflow ? )
    dup kill-values dup infer-classes optimize-node ;

: optimize ( dataflow -- dataflow )
    [ optimize-1 ] with-scope [ optimize ] when ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> node-successor ] [ r> drop t ] if ;
    inline

! Generic nodes
M: f optimize-node* drop t ;

M: node optimize-node* ( node -- t )
    drop t ;

! #shuffle
: can-compose? ( shuffle -- ? )
    dup shuffle-in-d length swap shuffle-in-r length +
    vregs length <= ;

: compose-shuffle-nodes ( #shuffle #shuffle -- #shuffle/t )
    [ [ node-shuffle ] 2apply compose-shuffle ] keep
    over can-compose?
    [ [ set-node-shuffle ] keep ] [ 2drop t ] if ;

M: #shuffle optimize-node*  ( node -- node/t )
    dup node-successor dup #shuffle? [
        compose-shuffle-nodes
    ] [
        drop [
            dup node-in-d over node-out-d sequence=
            >r dup node-in-r swap node-out-r sequence= r> and
        ] prune-if
    ] if ;

! #if
: static-branch? ( node -- lit ? )
    node-in-d first dup value? ;

: static-branch ( conditional n -- node )
    over drop-inputs
    [ >r swap node-children nth r> set-node-successor ] keep ;

! M: #if optimize-node* ( node -- node )
!     dup static-branch?
!     [ value-literal 0 1 ? static-branch ] [ 2drop t ] if ;

! #values
: optimize-fold ( node -- node/t )
    node-successor [ node-successor ] [ t ] if* ;

M: #values optimize-node* ( node -- node/t )
    optimize-fold ;

! #return
M: #return optimize-node* ( node -- node/t )
    optimize-fold ;
