! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic math math.parser sequences arrays io namespaces namespaces.private random layouts ;
IN: trees

TUPLE: tree root ;

: <tree> ( -- tree ) tree construct-empty ;

TUPLE: node key value left right ;

: <node> ( value key -- node )
    swap f f node construct-boa ;

SYMBOL: current-side

: left -1 ; inline
: right 1 ; inline

: go-left? ( -- ? ) current-side get left = ;

: node-link@ ( -- ? quot quot ) go-left? [ node-left ] [ node-right ] ; inline
: set-node-link@ ( -- ? quot quot ) go-left? [ set-node-left ] [ set-node-right ] ; inline

: node-link ( node -- child ) node-link@ if ;
: set-node-link ( child node -- ) set-node-link@ if ;
: node+link ( node -- child ) node-link@ swap if ;
: set-node+link ( child node -- ) set-node-link@ swap if ;

: with-side ( side quot -- ) H{ } clone >n swap current-side set call ndrop ; inline
: with-other-side ( quot -- ) current-side get neg swap with-side ; inline
: go-left ( quot -- ) left swap with-side ; inline
: go-right ( quot -- ) right swap with-side ; inline

GENERIC: create-node ( value key tree -- node )

GENERIC: copy-node-contents ( new old -- )

M: node copy-node-contents ( new old -- )
    #! copy old's key and value into new (keeping children and parent)
    dup node-key pick set-node-key node-value swap set-node-value ;

M: tree create-node ( value key tree -- node ) drop <node> ;

: key-side ( k1 k2 -- side )
    #! side is -1 if k1 < k2, 0 if they are equal, or 1 if k1 > k2
    <=> sgn ;

: key< ( k1 k2 -- ? ) <=> 0 < ;
: key> ( k1 k2 -- ? ) <=> 0 > ;
: key= ( k1 k2 -- ? ) <=> zero? ;

: random-side ( -- side ) left right 2array random ;

: choose-branch ( key node -- key node-left/right )
    2dup node-key key-side [ node-link ] with-side ;

GENERIC: node-get ( key node -- value )

: tree-get ( key tree -- value ) tree-root node-get ;

M: node node-get ( key node -- value )
    2dup node-key key= [
        nip node-value
    ] [
        choose-branch node-get
    ] if ;

M: f node-get ( key f -- f ) nip ;

GENERIC: node-get* ( key node -- value ? )

: tree-get* ( key tree -- value ? ) tree-root node-get* ;

M: node node-get* ( key node -- value ? )
    2dup node-key key= [
        nip node-value t
    ] [
        choose-branch node-get*
    ] if ;

M: f node-get* ( key f -- f f ) nip f ;

GENERIC: node-get-all ( key node -- seq )

: tree-get-all ( key tree -- seq ) tree-root node-get-all ;

M: f node-get-all ( key f -- V{} ) 2drop V{ } clone ;

M: node node-get-all ( key node -- seq )
    2dup node-key key= [
        ! duplicate keys are stored to the right because of choose-branch
        2dup node-right node-get-all >r nip node-value r> tuck push
    ] [
        choose-branch node-get-all
    ] if ;

GENERIC: node-insert ( value key node -- node ) ! can add duplicates

: tree-insert ( value key tree -- )
    [ dup tree-root [ nip node-insert ] [ create-node ] if* ] keep set-tree-root ;

GENERIC: node-set ( value key node -- node )
    #! note that this only sets the first node with this key. if more than one
    #! has been inserted then the others won't be modified. (should they be deleted?)

: tree-set ( value key tree -- )
    [ dup tree-root [ nip node-set ] [ create-node ] if* ] keep set-tree-root ;

GENERIC: node-delete ( key node -- node )

: tree-delete ( key tree -- )
    [ tree-root node-delete ] keep set-tree-root ;

GENERIC: node-delete-all ( key node -- node )

M: f node-delete-all ( key f -- f ) nip ;

: tree-delete-all ( key tree -- )
    [ tree-root node-delete-all ] keep set-tree-root ;

: node-map-link ( node quot -- node )
    over node-link swap call over set-node-link ;

: node-map ( node quot -- node )
    over [
        tuck [ node-map-link ] go-left over call swap [ node-map-link ] go-right
    ] [
        drop
    ] if ;

: tree-map ( tree quot -- )
    #! apply quot to each element of the tree, in order
    over tree-root swap node-map swap set-tree-root ;

: node>node-seq ( node -- seq )
    dup [
        dup node-left node>node-seq over 1array rot node-right node>node-seq 3append
    ] when ;

: tree>node-seq ( tree -- seq )
    tree-root node>node-seq ;

: tree-keys ( tree -- keys )
    tree>node-seq [ node-key ] map ;

: tree-values ( tree -- values )
    tree>node-seq [ node-value ] map ;

: leaf? ( node -- ? )
    dup node-left swap node-right or not ;

GENERIC: valid-node? ( node -- ? )

M: f valid-node? ( f -- t ) not ;

M: node valid-node? ( node -- ? )
    dup dup node-left [ node-key swap node-key key< ] when* >r
    dup dup node-right [ node-key swap node-key key> ] when* r> and swap
    dup node-left valid-node? swap node-right valid-node? and and ;

: valid-tree? ( tree -- ? ) tree-root valid-node? ;

DEFER: print-tree

: random-tree ( tree size -- tree )
    [ most-positive-fixnum random pick tree-set ] each ;

: increasing-tree ( tree size -- tree )
    [ dup pick tree-set ] each ;

: decreasing-tree ( tree size -- tree )
    reverse increasing-tree ;

GENERIC: print-node ( depth node -- )

M: f print-node ( depth f -- ) 2drop ;

M: node print-node ( depth node -- )
    ! not pretty, but ok for debugging
    over 1+ over node-right print-node
    over [ drop "   " write ] each dup node-key number>string print
    >r 1+ r> node-left print-node ;

: print-tree ( tree -- )
    tree-root 1 swap print-node ;

: stump? ( tree -- ? )
    #! is this tree empty?
    tree-root not ;

