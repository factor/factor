! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators fry generic io kernel locals
make math namespaces sequences sets ui.gadgets ;
IN: ui.traverse

TUPLE: node value children ;

: traverse-step ( path gadget -- path' gadget' )
    [ unclip-slice ] dip children>> ?nth ;

: make-node ( value quot -- node ) { } make node boa ; inline

:: traverse-to-path ( topath gadget -- )
    gadget [
        topath empty? [
            [
                gadget children>> topath first head-slice %
                topath gadget traverse-step traverse-to-path
            ] make-node
        ] unless ,
    ] when* ;

:: traverse-from-path ( frompath gadget -- )
    gadget [
        frompath empty? [
            [
                frompath gadget traverse-step traverse-from-path
                gadget children>> frompath first 1 + tail-slice %
            ] make-node
        ] unless ,
    ] when* ;

: traverse-pre ( frompath gadget -- )
    traverse-step traverse-from-path ;

: traverse-post ( topath gadget -- )
    traverse-step traverse-to-path ;

:: traverse-middle ( frompath topath gadget -- )
    gadget [
        frompath gadget traverse-pre
        frompath first 1 + topath first gadget children>> <slice> %
        topath gadget traverse-post
    ] make-node , ;

DEFER: gadget-subtree%

:: traverse-child ( frompath topath gadget -- )
    gadget [
        frompath rest-slice
        topath gadget traverse-step
        gadget-subtree%
    ] make-node , ;

: gadget-subtree% ( frompath topath gadget -- )
    {
        { [ dup not ] [ 3drop ] }
        { [ pick empty? pick empty? and ] [ 2nip , ] }
        { [ pick empty? ] [ traverse-to-path drop ] }
        { [ over empty? ] [ nip traverse-from-path ] }
        { [ pick first pick first = ] [ traverse-child ] }
        [ traverse-middle ]
    } cond ;

: gadget-subtree ( frompath topath gadget -- seq )
    [ gadget-subtree% ] { } make ;

M: node gadget-text*
    [ children>> ] [ value>> ] bi gadget-seq-text ;

: gadget-text-range ( frompath topath gadget -- str )
    gadget-subtree gadget-text ;

: gadget-at-path ( parent path -- gadget )
    [ swap nth-gadget ] each ;

GENERIC#: leaves* 1 ( tree set -- )

M: node leaves* [ children>> ] dip leaves* ;

M: array leaves* '[ _ leaves* ] each ;

M: gadget leaves* adjoin ;

: leaves ( tree -- set ) HS{ } clone [ leaves* ] keep ;
