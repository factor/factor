! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic math sequences arrays io namespaces
prettyprint.private kernel.private assocs random combinators
parser prettyprint.backend math.order accessors ;
IN: trees

MIXIN: tree-mixin

TUPLE: tree root count ;

: <tree> ( -- tree )
    f 0 tree boa ;

: construct-tree ( class -- tree )
    new <tree> over set-delegate ; inline

INSTANCE: tree tree-mixin

INSTANCE: tree-mixin assoc

TUPLE: node key value left right ;
: <node> ( key value -- node )
    f f node boa ;

SYMBOL: current-side

: left ( -- symbol ) -1 ; inline
: right ( -- symbol ) 1 ; inline

: key-side ( k1 k2 -- n )
    <=> {
        { +lt+ [ -1 ] }
        { +eq+ [ 0 ] }
        { +gt+ [ 1 ] }
    } case ;

: go-left? ( -- ? ) current-side get left eq? ;

: inc-count ( tree -- ) [ 1+ ] change-count drop ;

: dec-count ( tree -- ) [ 1- ] change-count drop ;

: node-link@ ( node ? -- node )
    go-left? xor [ left>> ] [ right>> ] if ;
: set-node-link@ ( left parent ? -- ) 
    go-left? xor [ set-node-left ] [ set-node-right ] if ;

: node-link ( node -- child ) f node-link@  ;
: set-node-link ( child node -- ) f set-node-link@ ;
: node+link ( node -- child ) t node-link@ ;
: set-node+link ( child node -- ) t set-node-link@ ;

: with-side ( side quot -- ) [ swap current-side set call ] with-scope ; inline
: with-other-side ( quot -- )
    current-side get neg swap with-side ; inline
: go-left ( quot -- ) left swap with-side ; inline
: go-right ( quot -- ) right swap with-side ; inline

: change-root ( tree quot -- )
    swap [ root>> swap call ] keep set-tree-root ; inline

: leaf? ( node -- ? )
    [ left>> ] [ right>> ] bi or not ;

: random-side ( -- side ) left right 2array random ;

: choose-branch ( key node -- key node-left/right )
    2dup node-key key-side [ node-link ] with-side ;

: node-at* ( key node -- value ? )
    [
        2dup node-key = [
            nip node-value t
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
    [ [ node-set ] [ swap <node> ] if* ] change-root ;

: valid-node? ( node -- ? )
    [
        dup dup left>> [ node-key swap node-key before? ] when* >r
        dup dup right>> [ node-key swap node-key after? ] when* r> and swap
        dup left>> valid-node? swap right>> valid-node? and and
    ] [ t ] if* ;

: valid-tree? ( tree -- ? ) root>> valid-node? ;

: tree-call ( node call -- )
    >r [ node-key ] keep node-value r> call ; inline
 
: find-node ( node quot -- key value ? )
    {
        { [ over not ] [ 2drop f f f ] }
        { [ [
              >r left>> r> find-node
            ] 2keep rot ]
          [ 2drop t ] }
        { [ >r 2nip r> [ tree-call ] 2keep rot ]
          [ drop [ node-key ] keep node-value t ] }
        [ >r right>> r> find-node ]
    } cond ; inline

M: tree-mixin assoc-find ( tree quot -- key value ? )
    >r root>> r> find-node ;

M: tree-mixin clear-assoc
    0 >>count
    f >>root drop ;

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
    2dup node-key key-side dup 0 eq? [
        drop nip delete-node
    ] [
        [ tuck node-link delete-bst-node over set-node-link ] with-side
    ] if ;

M: tree delete-at
    [ delete-bst-node ] change-root ;

M: tree new-assoc
    2drop <tree> ;

M: tree clone dup assoc-clone-like ;

: >tree ( assoc -- tree )
    T{ tree f f 0 } assoc-clone-like ;

M: tree-mixin assoc-like drop dup tree? [ >tree ] unless ;

: TREE{
    \ } [ >tree ] parse-literal ; parsing

M: tree pprint-delims drop \ TREE{ \ } ;

M: tree-mixin assoc-size count>> ;
M: tree-mixin clone dup assoc-clone-like ;
M: tree-mixin >pprint-sequence >alist ;
M: tree-mixin pprint-narrow? drop t ;
