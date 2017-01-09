! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit kernel make math math.order namespaces
parser prettyprint.custom random ;
IN: trees

TUPLE: tree root { count integer } ;

<PRIVATE

: new-tree ( class -- tree )
    new
        f >>root
        0 >>count ; inline

PRIVATE>

: <tree> ( -- tree )
    tree new-tree ;

INSTANCE: tree assoc

<PRIVATE

TUPLE: node key value left right ;

: new-node ( key value class -- node )
    new
        swap >>value
        swap >>key ; inline

: <node> ( key value -- node )
    node new-node ;

SYMBOL: current-side

CONSTANT: left -1
CONSTANT: right 1

: key-side ( k1 k2 -- n )
    <=> {
        { +lt+ [ left ] }
        { +eq+ [ 0 ] }
        { +gt+ [ right ] }
    } case ;

: go-left? ( -- ? ) current-side get left eq? ;

: inc-count ( tree -- ) [ 1 + ] change-count drop ;

: dec-count ( tree -- ) [ 1 - ] change-count drop ;

: node-link@ ( node ? -- node )
    go-left? xor [ left>> ] [ right>> ] if ;

: set-node-link@ ( left parent ? -- )
    go-left? xor [ left<< ] [ right<< ] if ;

: node-link ( node -- child ) f node-link@  ;

: set-node-link ( child node -- ) f set-node-link@ ;

: node+link ( node -- child ) t node-link@ ;

: set-node+link ( child node -- ) t set-node-link@ ;

: with-side ( side quot -- )
    [ current-side ] dip with-variable ; inline

: with-other-side ( quot -- )
    current-side get neg swap with-side ; inline

: go-left ( quot -- ) left swap with-side ; inline

: go-right ( quot -- ) right swap with-side ; inline

: leaf? ( node -- ? )
    { [ left>> not ] [ right>> not ] } 1&& ;

: random-side ( -- side )
    2 random 0 eq? left right ? ;

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

M: tree at*
    root>> node-at* ;

: node-set ( value key node -- node new? )
    2dup key>> key-side dup 0 eq? [
        drop nip swap >>value f
    ] [
        [
            [ node-link [ node-set ] [ swap <node> t ] if* ] keep
            swap [ [ set-node-link ] keep ] dip
        ] with-side
    ] if ;

M: tree set-at
    [ [ node-set ] [ swap <node> t ] if* swap ] change-root
    swap [ dup inc-count ] when drop ;

: valid-node? ( node -- ? )
    [
        {
            [ dup left>> [ key>> swap key>> before? ] when* ]
            [ dup right>> [ key>> swap key>> after? ] when* ]
            [ left>> valid-node? ]
            [ right>> valid-node? ]
        } 1&&
    ] [ t ] if* ;

: valid-tree? ( tree -- ? ) root>> valid-node? ;

: (node>alist) ( node -- )
    [
        [ left>> (node>alist) ]
        [ [ key>> ] [ value>> ] bi 2array , ]
        [ right>> (node>alist) ]
        tri
    ] when* ;

M: tree >alist
    [ root>> (node>alist) ] { } make ;

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
        [ nip ] dip (prune-extremity)
    ] [
        [ delete-node swap set-node-link ] keep
    ] if* ;

: prune-extremity ( node -- new-extremity )
    ! remove and return the leftmost or rightmost child of this node.
    ! assumes at least one child
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
    ! randomised to minimise tree unbalancing
    random-side [ replace-with-extremity ] with-side ;

: delete-node ( node -- node )
    ! delete this node, returning its replacement
    dup [ right>> ] [ left>> ] bi [
        swap [
            drop delete-node-with-two-children
        ] [
            nip ! left but no right
        ] if
    ] [
        nip ! right but no left, or no children
    ] if* ;

: delete-bst-node ( key node -- node deleted? )
    2dup key>> key-side dup 0 eq? [
        drop nip delete-node t
    ] [
        [
            [ node-link delete-bst-node ]
            [ swap [ set-node-link ] dip ]
            [ swap ] tri
        ] with-side
    ] if ;

PRIVATE>

M: tree delete-at
    [ delete-bst-node swap ] change-root
    swap [ dup dec-count ] when drop ;

M: tree new-assoc
    2drop <tree> ;

<PRIVATE

: clone-nodes ( node -- node' )
    dup [
        clone
        [ clone-nodes ] change-left
        [ clone-nodes ] change-right
    ] when ;

PRIVATE>

M: tree clone (clone) [ clone-nodes ] change-root ;

: >tree ( assoc -- tree )
    T{ tree f f 0 } assoc-clone-like ;

M: tree assoc-like drop dup tree? [ >tree ] unless ;

SYNTAX: TREE{
    \ } [ >tree ] parse-literal ;

M: tree assoc-size count>> ;
M: tree pprint-delims drop \ TREE{ \ } ;
M: tree >pprint-sequence >alist ;
M: tree pprint-narrow? drop t ;

<PRIVATE

: node-height ( node -- n )
    [
        [ left>> ] [ right>> ] bi
        [ node-height ] bi@ max 1 +
    ] [ 0 ] if* ;

PRIVATE>

: height ( tree -- n )
    root>> node-height ;
