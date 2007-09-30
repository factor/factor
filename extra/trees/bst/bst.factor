! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic math trees ;
IN: trees.bst

TUPLE: bst ;

: <bst> ( -- tree ) bst construct-empty <tree> over set-delegate ;

TUPLE: bst-node ;

: <bst-node> ( value key -- node )
    <node> bst-node construct-empty tuck set-delegate ;

M: bst create-node ( value key tree -- node ) drop <bst-node> ;

M: bst-node node-insert ( value key node -- node )
    2dup node-key key-side [
        [ node-link [ node-insert ] [ <bst-node> ] if* ] keep tuck set-node-link 
    ] with-side ;

M: bst-node node-set ( value key node -- node )
    2dup node-key key-side dup 0 = [
        drop nip [ set-node-value ] keep
    ] [
        [ [ node-link [ node-set ] [ <bst-node> ] if* ] keep tuck set-node-link ] with-side
    ] if ;

DEFER: delete-node

: (prune-extremity) ( parent node -- new-extremity )
    dup node-link [
        rot drop (prune-extremity)
    ] [
        tuck delete-node swap set-node-link
    ] if* ;

: prune-extremity ( node -- new-extremity )
    #! remove and return the leftmost or rightmost child of this node.
    #! assumes at least one child
    dup node-link (prune-extremity) ;

: replace-with-child ( node -- node )
    dup dup node-link copy-node-contents dup node-link delete-node over set-node-link ;

: replace-with-extremity ( node -- node )
    dup node-link dup node+link [
        ! predecessor/successor is not the immediate child
        [ prune-extremity ] with-other-side dupd copy-node-contents
    ] [
        ! node-link is the predecessor/successor
        drop replace-with-child
    ] if ;

: delete-node-with-two-children ( node -- node )
    #! randomised to minimise tree unbalancing
    random-side [ replace-with-extremity ] with-side ;

: delete-node ( node -- node )
    #! delete this node, returning its replacement
    dup node-left [
        dup node-right [
            delete-node-with-two-children
        ] [
            node-left ! left but no right
        ] if
    ] [
        dup node-right [
            node-right ! right but not left
        ] [
            drop f ! no children
        ] if
    ] if ;

M: bst-node node-delete ( key node -- node )
    2dup node-key key-side dup zero? [
        drop nip delete-node
    ] [
        [ tuck node-link node-delete over set-node-link ] with-side
    ] if ;

M: bst-node node-delete-all ( key node -- node )
    2dup node-key key-side dup zero? [
        drop delete-node node-delete-all
    ] [
        [ tuck node-link node-delete-all over set-node-link ] with-side
    ] if ;

