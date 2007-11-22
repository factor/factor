! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic math sequences arrays io namespaces
prettyprint.private kernel.private assocs random combinators ;
IN: trees

TUPLE: tree root count ;
: <tree> ( -- tree )
    f 0 tree construct-boa ;

TUPLE: node key value left right ;
: <node> ( key value -- node )
    f f node construct-boa ;

SYMBOL: current-side

: left -1 ; inline
: right 1 ; inline

: go-left? ( -- ? ) current-side get left = ;

: node-link@ ( node ? -- node )
    go-left? xor [ node-left ] [ node-right ] if ;
: set-node-link@ ( left parent ? -- ) 
    go-left? xor [ set-node-left ] [ set-node-right ] if ;

: node-link ( node -- child ) f node-link@  ;
: set-node-link ( child node -- ) f set-node-link@ ;
: node+link ( node -- child ) t node-link@ ;
: set-node+link ( child node -- ) t set-node-link@ ;

: with-side ( side quot -- ) [ swap current-side set call ] with-scope ; inline
: with-other-side ( quot -- ) current-side get neg swap with-side ; inline
: go-left ( quot -- ) left swap with-side ; inline
: go-right ( quot -- ) right swap with-side ; inline

: change-root ( tree quot -- )
    swap [ tree-root swap call ] keep set-tree-root ; inline

: leaf? ( node -- ? )
    dup node-left swap node-right or not ;

: key-side ( k1 k2 -- side )
    #! side is -1 if k1 < k2, 0 if they are equal, or 1 if k1 > k2
    <=> sgn ;

: key< ( k1 k2 -- ? ) <=> 0 < ;
: key> ( k1 k2 -- ? ) <=> 0 > ;
: key= ( k1 k2 -- ? ) <=> zero? ;

: random-side ( -- side ) left right 2array random ;

: choose-branch ( key node -- key node-left/right )
    2dup node-key key-side [ node-link ] with-side ;

: node-at* ( key node -- value ? )
    [
        2dup node-key key= [
            nip node-value t
        ] [
            choose-branch node-at*
        ] if
    ] [ f f ] if* ;

M: tree at* ( key tree -- value ? )
    tree-root node-at* ;

: node-set ( value key node -- node )
    2dup node-key key-side dup zero? [
        drop nip [ set-node-value ] keep
    ] [
        [
            [ node-link [ node-set ] [ <node> ] if* ] keep
            [ set-node-link ] keep
        ] with-side
    ] if ;

M: tree set-at ( value key tree -- )
    [ [ node-set ] [ <node> ] if* ] change-root ;

: valid-node? ( node -- ? )
    [
        dup dup node-left [ node-key swap node-key key< ] when* >r
        dup dup node-right [ node-key swap node-key key> ] when* r> and swap
        dup node-left valid-node? swap node-right valid-node? and and
    ] [ t ] if* ;

: valid-tree? ( tree -- ? ) tree-root valid-node? ;

: tree-call ( node call -- )
    >r [ node-key ] keep node-value r> call ; inline
 
: find-node ( node quot -- key value ? )
    {
        { [ over not ] [ 2drop f f f ] }
        { [ [
              >r node-left r> find-node
            ] 2keep rot ]
          [ 2drop t ] }
        { [ >r 2nip r> [ tree-call ] 2keep rot ]
          [ drop [ node-key ] keep node-value t ] }
        { [ t ] [ >r node-right r> find-node ] }
    } cond ; inline

M: tree assoc-find ( tree quot -- key value ? )
    >r tree-root r> find-node ;

M: tree clear-assoc
    0 over set-tree-count
    f swap set-tree-root ;

M: tree assoc-size
    tree-count ;

: copy-node-contents ( new old -- )
    dup node-key pick set-node-key node-value swap set-node-value ;

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

: delete-bst-node ( key node -- node )
    2dup node-key key-side dup zero? [
        drop nip delete-node
    ] [
        [ tuck node-link delete-bst-node over set-node-link ] with-side
    ] if ;

M: tree delete-at
    [ delete-bst-node ] change-root ;
