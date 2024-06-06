! Copyright (C) 2007 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit deques dlists kernel make math
math.order namespaces parser prettyprint.custom random sequences
vectors ;
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

: node>entry ( node -- entry ) [ key>> ] [ value>> ] bi 2array ;

: entry, ( node -- ) node>entry , ;

: (node>alist) ( node -- )
    [
        [ left>> (node>alist) ]
        [ entry, ]
        [ right>> (node>alist) ]
        tri
    ] when* ;

M: tree >alist
    [ root>> (node>alist) ] { } make ;

:: (node>subalist-right) ( to-key node end-comparator: ( key1 key2 -- ? ) -- )
    node [
        node key>> to-key end-comparator call :> node-left?

        node left>> node-left? [ (node>alist) ] [
            [ to-key ] dip end-comparator (node>subalist-right)
        ] if

        node-left? [
            node [ entry, ] [
                right>> [ to-key ] dip
                end-comparator (node>subalist-right)
            ] bi
        ] when
    ] when ; inline recursive

:: (node>subalist-left) ( from-key node start-comparator: ( key1 key2 -- ? ) -- )
    node [
        node key>> from-key start-comparator call :> node-right?

        node-right? [
            node [
                left>> [ from-key ] dip
                start-comparator (node>subalist-left)
            ] [ entry, ] bi
        ] when

        node right>> node-right? [ (node>alist) ] [
            [ from-key ] dip start-comparator (node>subalist-left)
        ] if
    ] when ; inline recursive

:: (node>subalist) ( from-key to-key node start-comparator: ( key1 key2 -- ? ) end-comparator: ( key1 key2 -- ? ) -- )
    node [
        node key>> from-key start-comparator call :> node-right?
        node key>> to-key end-comparator call :> node-left?

        node-right? [
            from-key node left>> node-left?
            [ start-comparator (node>subalist-left) ]
            [
                [ to-key ] dip start-comparator
                end-comparator (node>subalist)
            ] if
        ] when

        node-right? node-left? and [ node entry, ] when

        node-left? [
            to-key node right>> node-right?
            [ end-comparator (node>subalist-right) ]
            [
                [ from-key ] 2dip start-comparator
                end-comparator (node>subalist)
            ] if
        ] when
    ] when ; inline recursive

PRIVATE>

: subtree>alist[) ( from-key to-key tree -- alist )
    [ root>> [ after=? ] [ before? ] (node>subalist) ] { } make ;

: subtree>alist(] ( from-key to-key tree -- alist )
    [ root>> [ after? ] [ before=? ] (node>subalist) ] { } make ;

: subtree>alist[] ( from-key to-key tree -- alist )
    [ root>> [ after=? ] [ before=? ] (node>subalist) ] { } make ;

: subtree>alist() ( from-key to-key tree -- alist )
    [ root>> [ after? ] [ before? ] (node>subalist) ] { } make ;

: headtree>alist[) ( to-key tree -- alist )
    [ root>> [ before? ] (node>subalist-right) ] { } make ;

: headtree>alist[] ( to-key tree -- alist )
    [ root>> [ before=? ] (node>subalist-right) ] { } make ;

: tailtree>alist[] ( from-key tree -- alist )
    [ root>> [ after=? ] (node>subalist-left) ] { } make ;

: tailtree>alist(] ( from-key tree -- alist )
    [ root>> [ after? ] (node>subalist-left) ] { } make ;

<PRIVATE

: (nodepath-at) ( key node -- )
    [
        dup ,
        2dup key>> = [
            2drop
        ] [
            choose-branch (nodepath-at)
        ] if
    ] [ drop ] if* ;

: nodepath-at ( key tree -- path )
    [ root>> (nodepath-at) ] { } make ;

: right-extremity ( node -- node' )
    [ dup right>> ] [ nip ] while* ;

: left-extremity ( node -- node' )
    [ dup left>> ] [ nip ] while* ;

: lower-node-in-child? ( key node -- ? )
    [ nip left>> ] [ key>> = ] 2bi and ;

: higher-node-in-child? ( key node -- ? )
    [ nip right>> ] [ key>> = ] 2bi and ;

: lower-node ( key tree -- node )
    dupd nodepath-at
    [ drop f ] [
        reverse 2dup first lower-node-in-child?
        [ nip first left>> right-extremity ]
        [ [ key>> after? ] with find nip ] if
    ] if-empty ;

: higher-node ( key tree -- node )
    dupd nodepath-at
    [ drop f ] [
        reverse 2dup first higher-node-in-child?
        [ nip first right>> left-extremity ]
        [ [ key>> before? ] with find nip ] if
    ] if-empty ;

: floor-node ( key tree -- node )
    dupd nodepath-at [ drop f ] [
        reverse [ key>> after=? ] with find nip
    ] if-empty ;

: ceiling-node ( key tree -- node )
    dupd nodepath-at [ drop f ] [
        reverse [ key>> before=? ] with find nip
    ] if-empty ;

: first-node ( tree -- node ) root>> [ left-extremity ] ?call ;

: last-node ( tree -- node ) root>> [ right-extremity ] ?call ;

PRIVATE>

: lower-entry ( key tree -- pair/f ) lower-node [ node>entry ] ?call ;

: higher-entry ( key tree -- pair/f ) higher-node [ node>entry ] ?call ;

: floor-entry ( key tree -- pair/f ) floor-node [ node>entry ] ?call ;

: ceiling-entry ( key tree -- pair/f ) ceiling-node [ node>entry ] ?call ;

: first-entry ( tree -- pair/f ) first-node [ node>entry ] ?call ;

: last-entry ( tree -- pair/f ) last-node [ node>entry ] ?call ;

: lower-key ( key tree -- key/f ) lower-node [ key>> ] ?call ;

: higher-key ( key tree -- key/f ) higher-node [ key>> ] ?call ;

: floor-key ( key tree -- key/f ) floor-node [ key>> ] ?call ;

: ceiling-key ( key tree -- key/f ) ceiling-node [ key>> ] ?call ;

: first-key ( tree -- key/f ) first-node [ key>> ] ?call ;

: last-key ( tree -- key/f ) last-node [ key>> ] ?call ;

<PRIVATE

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
        nipd (prune-extremity)
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

M: tree delete-at
    [ delete-bst-node swap ] change-root
    swap [ dup dec-count ] when drop ;

M: tree new-assoc
    2drop <tree> ;

: clone-nodes ( node -- node' )
    dup [
        clone
        [ clone-nodes ] change-left
        [ clone-nodes ] change-right
    ] when ;

M: tree clone (clone) [ clone-nodes ] change-root ;

: ?push-children ( node queue -- )
    [ [ left>> ] [ right>> ] bi ]
    [ [ over [ push-front ] [ 2drop ] if ] curry bi@ ] bi* ;

: each-bfs-node ( tree quot: ( ... entry -- ... ) -- ... )
    [ root>> <dlist> [ push-front ] keep dup ] dip
    [
        [ drop node>entry ] prepose
        [ ?push-children ] 2bi
    ] 2curry slurp-deque ; inline

: >bfs-alist ( tree -- alist )
    dup assoc-size <vector> [
        [ push ] curry each-bfs-node
    ] keep ;

M: tree assoc-clone-like
    [ dup tree? [ >bfs-alist ] when ] dip call-next-method ;

PRIVATE>

: >tree ( assoc -- tree )
    T{ tree f f 0 } assoc-clone-like ;

SYNTAX: TREE{
    \ } [ >tree ] parse-literal ;

<PRIVATE

M: tree assoc-like drop dup tree? [ >tree ] unless ;

M: tree assoc-size count>> ;
M: tree pprint-delims drop \ TREE{ \ } ;
M: tree >pprint-sequence >alist ;
M: tree pprint-narrow? drop t ;

: node-height ( node -- n )
    [
        [ left>> ] [ right>> ] bi
        [ node-height ] bi@ max 1 +
    ] [ 0 ] if* ;

PRIVATE>

: height ( tree -- n )
    root>> node-height ;

<PRIVATE

: pop-tree-extremity ( tree node/f -- node/f )
    dup [
        [ key>> swap delete-at ] keep node>entry
    ] [ nip ] if ;

:: slurp-tree ( tree quot: ( ... entry -- ... ) getter: ( tree -- node ) -- ... )
    [ tree count>> 0 = ]
    [ tree getter call quot call ] until ; inline

PRIVATE>

: pop-tree-left ( tree -- node/f )
    dup first-node pop-tree-extremity ;

: pop-tree-right ( tree -- node/f )
    dup last-node pop-tree-extremity ;

: slurp-tree-left ( tree quot: ( ... entry -- ... ) -- ... )
    [ pop-tree-left ] slurp-tree ; inline

: slurp-tree-right ( tree quot: ( ... entry -- ... ) -- ... )
    [ pop-tree-right ] slurp-tree ; inline
