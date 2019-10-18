! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences kernel math arrays io gadgets
generic ;
IN: gadgets-traverse

TUPLE: node value children ;

: traverse-step ( path gadget -- path' gadget' )
    >r unclip r> gadget-children ?nth ;

: make-node ( quot -- ) { } make <node> , ; inline

: traverse-to-path ( topath gadget -- )
    over empty? over not or [
        2drop
    ] [
        [
            2dup gadget-children swap first head-slice %
            tuck traverse-step traverse-to-path
        ] make-node
    ] if ;

: traverse-from-path ( frompath gadget -- )
    dup not [
        2drop
    ] [
        over empty? [
            nip ,
        ] [
            [
                2dup traverse-step traverse-from-path
                tuck gadget-children swap first 1+ tail-slice %
            ] make-node
        ] if
    ] if ;

: traverse-pre ( frompath gadget -- )
    traverse-step traverse-from-path ;

: (traverse-middle) ( frompath topath gadget -- )
    >r >r first r> first 2dup = [ >r 1+ r> ] unless r>
    gadget-children <slice> % ;

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
    dup -roll [
        >r >r 1 tail-slice r> r> traverse-step (gadget-subtree)
    ] make-node ;

: (gadget-subtree) ( frompath topath gadget -- )
    {
        { [ dup not ] [ 3drop ] }
        { [ pick empty? pick empty? and ] [ 3drop ] }
        { [ pick empty? ] [ rot drop traverse-to-path ] }
        { [ over empty? ] [ nip traverse-from-path ] }
        { [ pick first pick first = ] [ traverse-child ] }
        { [ t ] [ traverse-middle ] }
    } cond ;

: gadget-subtree ( frompath topath gadget -- seq )
    [ (gadget-subtree) ] { } make ;

M: node gadget-text*
    dup node-children swap node-value gadget-seq-text ;

: gadget-text-range ( frompath topath gadget -- str )
    gadget-subtree gadget-text ;

: index-in-parent ( gadget -- n )
    dup gadget-parent gadget-children index ;

: (gadget-path) ( parent gadget -- )
    #! Outputs f if the gadget is not a child of the parent.
    2dup eq? [
        2drop
    ] [
        tuck gadget-parent (gadget-path) index-in-parent ,
    ] if ;

: gadget-path ( parent gadget -- path )
    dup [ [ (gadget-path) ] { } make ] [ 2drop f ] if ;

: gadget-at-path ( parent path -- gadget )
    [ swap gadget-children nth ] each ;
