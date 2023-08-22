! Copyright (c) 2005 Mackenzie Straight.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators kernel math.order parser
prettyprint.custom sequences trees trees.private typed ;
IN: trees.splay

TUPLE: splay < tree ;

: <splay> ( -- tree )
    \ splay new-tree ;

<PRIVATE

TYPED: rotate-right ( node: node -- node )
    dup left>> [ >>left ] change-right ;

TYPED: rotate-left ( node: node -- node )
    dup right>> [ >>right ] change-left ;

TYPED: link-right ( left right key node: node -- left right key node )
    swap [
        [ swap left<< ] [ ] [ left>> ] tri
    ] dip swap ;

TYPED: link-left ( left right key node: node -- left right key node )
    swap [
        [ rot right<< ] [ ] [ right>> ] tri swapd
    ] dip swap ;

: cmp ( key node -- key node <=> )
    2dup key>> <=> ; inline

: lcmp ( key node -- key node <=> )
    2dup left>> key>> <=> ; inline

: rcmp ( key node -- key node <=> )
    2dup right>> key>> <=> ; inline

DEFER: (splay)

TYPED: splay-left ( left right key node: node -- left right key node )
    dup left>> [
        lcmp +lt+ = [ rotate-right ] when
        dup left>> [ link-right (splay) ] when
    ] when ;

TYPED: splay-right ( left right key node: node -- left right key node )
    dup right>> [
        rcmp +gt+ = [ rotate-left ] when
        dup right>> [ link-left (splay) ] when
    ] when ;

TYPED: (splay) ( left right key node: node -- left right key node )
    cmp {
        { +lt+ [ splay-left ] }
        { +gt+ [ splay-right ] }
        { +eq+ [ ] }
    } case ;

TYPED: assemble ( head left right node: node -- root )
    {
        [ right>> swap left<< ]
        [ left>> swap right<< ]
        [ over left>> swap right<< ]
        [ swap right>> swap left<< ]
        [ ]
    } cleave ;

TYPED: splay-at ( key node: node -- node )
    [ T{ node } clone dup dup ] 2dip (splay) nip assemble ;

TYPED: do-splay ( key tree: splay -- )
    [ root>> splay-at ] keep root<< ;

TYPED: splay-split ( key tree: splay -- node node )
    2dup do-splay root>> cmp +lt+ = [
        nip [ left>> ] [ f >>left ] bi
    ] [
        nip [ right>> ] [ f >>right ] bi swap
    ] if ;

TYPED: get-splay ( key tree: splay -- node ? )
    2dup do-splay root>> cmp +eq+ = [
        nip t
    ] [
        2drop f f
    ] if ;

: get-largest ( node -- node )
    dup [ dup right>> [ nip get-largest ] when* ] when ;

: splay-largest ( node -- node )
    dup [ dup get-largest key>> swap splay-at ] when ;

: splay-join ( n2 n1 -- node )
    splay-largest [ [ right<< ] keep ] when* ;

TYPED: remove-splay ( key tree: splay -- )
    2dup get-splay [
        [ right>> ] [ left>> ] bi splay-join
        >>root dec-count drop
    ] [
        3drop
    ] if ;

TYPED: set-splay ( value key tree: splay -- )
    2dup get-splay [
        2nip value<<
    ] [
        drop dup inc-count
        2dup splay-split rot
        [ [ swap ] 2dip node boa ] dip root<<
    ] if ;

TYPED: new-root ( value key tree: splay -- )
    [ swap <node> ] [ 1 >>count root<< ] bi* ;

M: splay set-at
    dup root>> [ set-splay ] [ new-root ] if ;

M: splay at*
    dup root>> [
        get-splay [ dup [ value>> ] when ] dip
    ] [
        2drop f f
    ] if ;

M: splay delete-at
    dup root>> [ remove-splay ] [ 2drop ] if ;

M: splay new-assoc
    2drop <splay> ;

M: splay assoc-clone-like
    [ dup tree? [ >bfs-alist reverse ] when ] dip call-next-method ;

PRIVATE>

: >splay ( assoc -- tree )
    T{ splay f f 0 } assoc-clone-like ;

SYNTAX: SPLAY{
    \ } [ >splay ] parse-literal ;

M: splay assoc-like
    drop dup splay? [ >splay ] unless ;

M: splay pprint-delims drop \ SPLAY{ \ } ;
