! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces make sequences kernel math arrays io
ui.gadgets generic combinators fry sets ;
IN: ui.traverse

TUPLE: node value children ;

: traverse-step ( path gadget -- path' gadget' )
    [ unclip ] dip children>> ?nth ;

: make-node ( quot -- ) { } make node boa , ; inline

: traverse-to-path ( topath gadget -- )
    dup not [
        2drop
    ] [
        over empty? [
            nip ,
        ] [
            [
                [ children>> swap first head-slice % ]
                [ nip ]
                [ traverse-step traverse-to-path ]
                2tri
            ] make-node
        ] if
    ] if ;

: traverse-from-path ( frompath gadget -- )
    dup not [
        2drop
    ] [
        over empty? [
            nip ,
        ] [
            [
                [ traverse-step traverse-from-path ]
                [ nip ]
                [ children>> swap first 1 + tail-slice % ]
                2tri
            ] make-node
        ] if
    ] if ;

: traverse-pre ( frompath gadget -- )
    traverse-step traverse-from-path ;

: (traverse-middle) ( frompath topath gadget -- )
    [ first 1 + ] [ first ] [ children>> ] tri* <slice> % ;

: traverse-post ( topath gadget -- )
    traverse-step traverse-to-path ;

: traverse-middle ( frompath topath gadget -- )
    [
        3dup nip traverse-pre
        3dup (traverse-middle)
        2dup traverse-post
        2nip
    ] make-node ;

DEFER: (gadget-subtree)

: traverse-child ( frompath topath gadget -- )
    [ 2nip ] 3keep
    [ [ rest-slice ] 2dip traverse-step (gadget-subtree) ]
    make-node ;

: (gadget-subtree) ( frompath topath gadget -- )
    {
        { [ dup not ] [ 3drop ] }
        { [ pick empty? pick empty? and ] [ 2nip , ] }
        { [ pick empty? ] [ traverse-to-path drop ] }
        { [ over empty? ] [ nip traverse-from-path ] }
        { [ pick first pick first = ] [ traverse-child ] }
        [ traverse-middle ]
    } cond ;

: gadget-subtree ( frompath topath gadget -- seq )
    [ (gadget-subtree) ] { } make ;

M: node gadget-text*
    [ children>> ] [ value>> ] bi gadget-seq-text ;

: gadget-text-range ( frompath topath gadget -- str )
    gadget-subtree gadget-text ;

: gadget-at-path ( parent path -- gadget )
    [ swap nth-gadget ] each ;

GENERIC# leaves* 1 ( tree set -- )

M: node leaves* [ children>> ] dip leaves* ;

M: array leaves* '[ _ leaves* ] each ;

M: gadget leaves* adjoin ;

: leaves ( tree -- set ) HS{ } clone [ leaves* ] keep ;
