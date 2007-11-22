! Copyright (c) 2005 Mackenzie Straight.
! See http://factor.sf.net/license.txt for BSD license.
USING: arrays kernel math namespaces sequences assocs parser
prettyprint.backend trees generic ;
IN: trees.splay

TUPLE: splay ;
: <splay> ( -- splay-tree )
    splay construct-empty
    <tree> over set-delegate ;

: rotate-right ( node -- node )
    dup node-left
    [ node-right swap set-node-left ] 2keep
    [ set-node-right ] keep ;
                                                        
: rotate-left ( node -- node )
    dup node-right
    [ node-left swap set-node-right ] 2keep
    [ set-node-left ] keep ;

: link-right ( left right key node -- left right key node )
    swap >r [ swap set-node-left ] 2keep
    nip dup node-left r> swap ;

: link-left ( left right key node -- left right key node )
    swap >r rot [ set-node-right ] 2keep
    drop dup node-right swapd r> swap ;

: cmp ( key node -- obj node -1/0/1 )
    2dup node-key <=> ;

: lcmp ( key node -- obj node -1/0/1 ) 
    2dup node-left node-key <=> ;

: rcmp ( key node -- obj node -1/0/1 ) 
    2dup node-right node-key <=> ;

DEFER: (splay)

: splay-left ( left right key node -- left right key node )
    dup node-left [
        lcmp 0 < [ rotate-right ] when
        dup node-left [ link-right (splay) ] when
    ] when ;

: splay-right ( left right key node -- left right key node )
    dup node-right [
        rcmp 0 > [ rotate-left ] when
        dup node-right [ link-left (splay) ] when
    ] when ;

: (splay) ( left right key node -- left right key node )
    cmp dup 0 <
    [ drop splay-left ] [ 0 > [ splay-right ] when ] if ;

: assemble ( head left right node -- root )
    [ node-right swap set-node-left ] keep
    [ node-left swap set-node-right ] keep
    [ swap node-left swap set-node-right ] 2keep
    [ swap node-right swap set-node-left ] keep ;

: splay-at ( key node -- node )
    >r >r T{ node } clone dup dup r> r>
    (splay) nip assemble ;

: splay ( key tree -- )
    [ tree-root splay-at ] keep set-tree-root ;

: splay-split ( key tree -- node node )
    2dup splay tree-root cmp 0 < [
        nip dup node-left swap f over set-node-left
    ] [
        nip dup node-right swap f over set-node-right swap
    ] if ;

: (get-splay) ( key tree -- node ? )
    2dup splay tree-root cmp 0 = [
        nip t
    ] [
        2drop f f
    ] if ;

: get-largest ( node -- node )
    dup [ dup node-right [ nip get-largest ] when* ] when ;

: splay-largest
    dup [ dup get-largest node-key swap splay-at ] when ;

: splay-join ( n2 n1 -- node )
    splay-largest [
        [ set-node-right ] keep
    ] [
        drop f
    ] if* ;

: (remove-splay) ( key tree -- )
    tuck (get-splay) nip [
        dup tree-count 1- over set-tree-count
        dup node-right swap node-left splay-join
        swap set-tree-root
    ] [ drop ] if* ;

: (set-splay) ( value key tree -- )
    2dup (get-splay) [ 2nip set-node-value ] [
       drop dup tree-count 1+ over set-tree-count
       2dup splay-split rot
       >r node construct-boa r> set-tree-root
    ] if ;

: new-root ( value key tree -- )
    [ 1 swap set-tree-count ] keep
    >r <node> r> set-tree-root ;

M: splay set-at ( value key tree -- )
    dup tree-root [ (set-splay) ] [ new-root ] if ;

M: splay at* ( key tree -- value ? )
    dup tree-root [
        (get-splay) >r dup [ node-value ] when r>
    ] [
        2drop f f
    ] if ;

M: splay delete-at ( key tree -- )
    dup tree-root [ (remove-splay) ] [ 2drop ] if ;

M: splay new-assoc
    2drop <splay> ;

: >splay ( assoc -- splay-tree )
    T{ splay T{ tree f f 0 } } assoc-clone-like ;

: SPLAY{
    \ } [ >splay ] parse-literal ; parsing

M: splay assoc-like
    drop dup splay? [
        dup tree? [ <splay> tuck set-delegate ] [ >splay ] if
    ] unless ;

M: splay pprint-delims drop \ SPLAY{ \ } ;
