! Copyright (c) 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
IN: splay-trees
USING: kernel math sequences ;

TUPLE: splay-tree r ;
TUPLE: splay-node v k l r ;

C: splay-tree ;

: rotate-right
    dup splay-node-l
    [ splay-node-r swap set-splay-node-l ] 2keep
    [ set-splay-node-r ] keep ;

: rotate-left
    dup splay-node-r
    [ splay-node-l swap set-splay-node-r ] 2keep
    [ set-splay-node-l ] keep ;

: link-right ( left right key node -- left right key node )
    swap >r [ swap set-splay-node-l ] 2keep
    nip dup splay-node-l r> swap ;

: link-left ( left right key node -- left right key node )
    swap >r rot [ set-splay-node-r ] 2keep
    drop dup splay-node-r swapd r> swap ;

: cmp 2dup splay-node-k <=> ;

: lcmp 2dup splay-node-l splay-node-k <=> ;

: rcmp 2dup splay-node-r splay-node-k <=> ;

DEFER: (splay)

: splay-left
    dup splay-node-l [
        lcmp 0 < [ rotate-right ] when
        dup splay-node-l [ link-right (splay) ] when
    ] when ;

: splay-right
    dup splay-node-r [
        rcmp 0 > [ rotate-left ] when
        dup splay-node-r [ link-left (splay) ] when
    ] when ;

: (splay) ( left right key node -- )
    cmp dup 0 <
    [ drop splay-left ] [ 0 > [ splay-right ] when ] if ;

: assemble ( head left right node -- root )
    [ splay-node-r swap set-splay-node-l ] keep
    [ splay-node-l swap set-splay-node-r ] keep
    [ swap splay-node-l swap set-splay-node-r ] 2keep
    [ swap splay-node-r swap set-splay-node-l ] keep ;

: splay-at ( key node -- node )
    >r >r T{ splay-node } dup dup r> r> (splay) nip assemble ;

: splay ( key tree -- )
    [ splay-tree-r splay-at ] keep set-splay-tree-r ;

: splay-split ( key tree -- node node )
    2dup splay splay-tree-r cmp 0 < [
        nip dup splay-node-l swap f over set-splay-node-l
    ] [
        nip dup splay-node-r swap f over set-splay-node-r swap
    ] if ;

: (get-splay) ( key tree -- node )
    2dup splay splay-tree-r cmp 0 = [ nip ] [ 2drop f ] if ;

: get-largest
    dup [ dup splay-node-r [ nip get-largest ] when* ] when ;

: splay-largest
    dup [ dup get-largest splay-node-k swap splay-at ] when ;

: splay-join ( n2 n1 -- node )
    splay-largest [ [ set-splay-node-r ] keep ] [ drop f ] if* ;

: (remove-splay) ( key tree -- )
    tuck (get-splay) [
        dup splay-node-r swap splay-node-l splay-join
        swap set-splay-tree-r
    ] [ drop ] if* ;

: (set-splay) ( value key tree -- )
    2dup (get-splay) [ 2nip set-splay-node-v ] [
       2dup splay-split rot >r <splay-node> r> set-splay-tree-r
    ] if* ;

: new-root ( value key tree -- )
    >r f f <splay-node> r> set-splay-tree-r ;

: set-splay ( value key tree -- )
    dup splay-tree-r [ (set-splay) ] [ new-root ] if ;

: get-splay ( key tree -- value )
    dup splay-tree-r [
        (get-splay) dup [ splay-node-v ] when
    ] [
        2drop f
    ] if ;

: remove-splay ( key tree -- )
    dup splay-tree-r [ (remove-splay) ] [ 2drop ] if ;

USING: namespaces words ;

<splay-tree> "foo" set
all-words [ dup word-name "foo" get set-splay ] each
all-words [ word-name "foo" get get-splay drop ] each

PROVIDE: splay-trees ;
