! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: compiler generic hashtables inference io kernel
lists math namespaces sequences vectors ;

SYMBOL: optimizer-changed

GENERIC: optimize-node* ( node -- node/t )

: keep-optimizing ( node -- node ? )
    dup optimize-node* dup t =
    [ drop f ] [ nip keep-optimizing t or ] if ;

: optimize-node ( node -- node )
    [
        keep-optimizing [ optimizer-changed on ] when
    ] map-nodes ;

: optimize ( node -- node )
    dup kill-values dup infer-classes [
        optimizer-changed off
        optimize-node
        optimizer-changed get
    ] with-node-iterator [ optimize ] when ;

! Generic nodes
M: f optimize-node* drop t ;

M: node optimize-node* ( node -- t ) drop t ;

! #push
M: #push optimize-node*  ( node -- node/t )
    dup node-out-d empty? [ node-successor ] [ drop t ] if ;

! #return
M: #return optimize-node* ( node -- node/t )
    node-successor [ node-successor ] [ t ] if* ;
