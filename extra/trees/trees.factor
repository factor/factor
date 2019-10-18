! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic math sequences arrays io namespaces
prettyprint.private kernel.private assocs random combinators
parser math.order accessors deques make prettyprint.custom 
shuffle ;
IN: trees

TUPLE: tree root count ;

: new-tree ( class -- tree )
    new
        f >>root
        0 >>count ; inline

: <tree> ( -- tree )
    tree new-tree ;

INSTANCE: tree assoc

TUPLE: node key value left right ;

: new-node ( key value class -- node )
    new
        swap >>value
        swap >>key ;

: <node> ( key value -- node )
    node new-node ;

SYMBOL: current-side

CONSTANT: left -1
CONSTANT: right 1

: key-side ( k1 k2 -- n )
    <=> {
        { +lt+ [ -1 ] }
        { +eq+ [ 0 ] }
        { +gt+ [ 1 ] }
    } case ;

: go-left? ( -- ? ) current-side get left eq? ;

: inc-count ( tree -- ) [ 1 + ] change-count drop ;

: dec-count ( tree -- ) [ 1 - ] change-count drop ;

: node-link@ ( node ? -- node )
    go-left? xor [ left>> ] [ right>> ] if ;

: set-node-link@ ( left parent ? -- ) 
    go-left? xor [ (>>left) ] [ (>>right) ] if ;

: node-link ( node -- child ) f node-link@  ;

: set-node-link ( child node -- ) f set-node-link@ ;

: node+link ( node -- child ) t node-link@ ;

: set-node+link ( child node -- ) t set-node-link@ ;

: with-side ( side quot -- )
    [ swap current-side set call ] with-scope ; inline

: with-other-side ( quot -- )
    current-side get neg swap with-side ; inline

: go-left ( quot -- ) left swap with-side ; inline

: go-right ( quot -- ) right swap with-side ; inline

: leaf? ( node -- ? )
    [ left>> ] [ right>> ] bi or not ;

: random-side ( -- side )
    left right 2array random ;

: choose-branch ( key node -- key node-left/right )
    2dup key>> key-side [ node-link ] with-side ;

: node-at* ( key node -- value ? )
    [
        2dup key>> = [
            nip value>> t
        ] [
            choose-branch node-at*
        ] if
    ] [ drop f f ] if* ;

M: tree at* ( key tree -- value ? )
    root>> node-at* ;

: node-set ( value key node -- node )
    2dup key>> key-side dup 0 eq? [
        drop nip swap >>value
    ] [
        [
            [ node-link [ node-set ] [ swap <node> ] if* ] keep
            [ set-node-link ] keep
        ] with-side
    ] if ;

M: tree set-at ( value key tree -- )
    [ [ node-set ] [ swap <node> ] if* ] change-root drop ;

: valid-node? ( node -- ? )
    [
        dup dup left>> [ key>> swap key>> before? ] when*
        [
        dup dup right>> [ key>> swap key>> after? ] when* ] dip and swap
        dup left>> valid-node? swap right>> valid-node? and and
    ] [ t ] if* ;

: valid-tree? ( tree -- ? ) root>> valid-node? ;

: (node>alist) ( node -- )
    [
        [ left>> (node>alist) ]
        [ [ key>> ] [ value>> ] bi 2array , ]
        [ right>> (node>alist) ]
        tri
    ] when* ;

M: tree >alist [ root>> (node>alist) ] { } make ;

M: tree clear-assoc
    0 >>count
    f >>root drop ;

: copy-node-contents ( new old -- new )
    [ key>> >>key ]
    [ value>> >>value ] bi ;

! Deletion
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
    dup node-link copy-node-contents dup node-link delete-node over set-node-link ;

: replace-with-extremity ( node -- node )
    dup node-link dup node+link [
        ! predecessor/successor is not the immediate child
        [ prune-extremity ] with-other-side copy-node-contents
    ] [
        ! node-link is the predecessor/successor
        drop replace-with-child
    ] if ;

: delete-node-with-two-children ( node -- node )
    #! randomised to minimise tree unbalancing
    random-side [ replace-with-extremity ] with-side ;

: delete-node ( node -- node )
    #! delete this node, returning its replacement
    dup left>> [
        dup right>> [
            delete-node-with-two-children
        ] [
            left>> ! left but no right
        ] if
    ] [
        dup right>> [
            right>> ! right but not left
        ] [
            drop f ! no children
        ] if
    ] if ;

: delete-bst-node ( key node -- node )
    2dup key>> key-side dup 0 eq? [
        drop nip delete-node
    ] [
        [ tuck node-link delete-bst-node over set-node-link ] with-side
    ] if ;

M: tree delete-at
    [ delete-bst-node ] change-root drop ;

M: tree new-assoc
    2drop <tree> ;

M: tree clone dup assoc-clone-like ;

: >tree ( assoc -- tree )
    T{ tree f f 0 } assoc-clone-like ;

M: tree assoc-like drop dup tree? [ >tree ] unless ;

SYNTAX: TREE{
    \ } [ >tree ] parse-literal ;
                                                        
M: tree assoc-size count>> ;
M: tree pprint-delims drop \ TREE{ \ } ;
M: tree >pprint-sequence >alist ;
M: tree pprint-narrow? drop t ;
