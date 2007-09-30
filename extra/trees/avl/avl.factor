! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel generic math math.functions math.parser namespaces io
sequences trees ;
IN: trees.avl

TUPLE: avl-tree ;

: <avl-tree> ( -- tree )
    avl-tree construct-empty <tree> over set-delegate ;

TUPLE: avl-node balance ;

: <avl-node> ( value key -- node )
    <node> 0 avl-node construct-boa tuck set-delegate ;

M: avl-tree create-node ( value key tree -- node ) drop <avl-node> ;

GENERIC: valid-avl-node? ( obj -- height valid? )

M: f valid-avl-node? ( f -- height valid? ) drop 0 t ;

: check-balance ( node left-height right-height -- node height valid? )
    2dup max 1+ >r swap - over avl-node-balance = r> swap ;

M: avl-node valid-avl-node? ( node -- height valid? )
    #! check that this avl node has the right balance marked, and that it isn't unbalanced.
    dup node-left valid-avl-node? >r over node-right valid-avl-node? >r
    check-balance r> r> and and
    rot avl-node-balance abs 2 < and ;

: valid-avl-tree? ( tree -- valid? ) tree-root valid-avl-node? nip ;

: change-balance ( node amount -- )
    over avl-node-balance + swap set-avl-node-balance ;

: rotate ( node -- node )
    dup node+link dup node-link pick set-node+link tuck set-node-link ;    

: single-rotate ( node -- node )
    0 over set-avl-node-balance 0 over node+link set-avl-node-balance rotate ;

: pick-balances ( a node -- balance balance )
    avl-node-balance {
        { [ dup zero? ] [ 2drop 0 0 ] }
        { [ over = ] [ neg 0 ] }
        { [ t ] [ 0 swap ] }
    } cond ;

: double-rotate ( node -- node )
    [
        node+link [
            node-link current-side get neg over pick-balances rot 0 swap set-avl-node-balance
        ] keep set-avl-node-balance
    ] keep tuck set-avl-node-balance
    dup node+link [ rotate ] with-other-side over set-node+link rotate ;

: select-rotate ( node -- node )
    dup node+link avl-node-balance current-side get = [ double-rotate ] [ single-rotate ] if ;

: balance-insert ( node -- node taller? )
    dup avl-node-balance {
        { [ dup zero? ] [ drop f ] }
        { [ dup abs 2 = ] [ sgn neg [ select-rotate ] with-side f ] }
        { [ drop t ] [ t ] } ! balance is -1 or 1, tree is taller
    } cond ;

DEFER: avl-insert

: avl-set ( value key node -- node taller? )
    2dup node-key key= [
        -rot pick set-node-key over set-node-value f
    ] [ avl-insert ] if ;

: avl-insert-or-set ( value key node -- node taller? )
    "setting" get [ avl-set ] [ avl-insert ] if ;

: (avl-insert) ( value key node -- node taller? )
    [ avl-insert-or-set ] [ <avl-node> t ] if* ;

: avl-insert ( value key node -- node taller? )
    2dup node-key key< left right ? [
        [ node-link (avl-insert) ] keep swap
        >r tuck set-node-link r> [ dup current-side get change-balance balance-insert ] [ f ] if
    ] with-side ;

M: avl-node node-insert ( value key node -- node )
    [ f "setting" set avl-insert-or-set ] with-scope drop ;

M: avl-node node-set ( value key node -- node )
    [ t "setting" set avl-insert-or-set ] with-scope drop ;

: delete-select-rotate ( node -- node shorter? )
    dup node+link avl-node-balance zero? [
        current-side get neg over set-avl-node-balance
        current-side get over node+link set-avl-node-balance rotate f
    ] [
        select-rotate t
    ] if ;

: rebalance-delete ( node -- node shorter? )
    dup avl-node-balance {
        { [ dup zero? ] [ drop t ] }
        { [ dup abs 2 = ] [ sgn neg [ delete-select-rotate ] with-side ] }
        { [ drop t ] [ f ] } ! balance is -1 or 1, tree is not shorter
    } cond ;

: balance-delete ( node -- node shorter? )
    current-side get over avl-node-balance {
        { [ dup zero? ] [ drop neg over set-avl-node-balance f ] }
        { [ dupd = ] [ drop 0 over set-avl-node-balance t ] }
        { [ t ] [ dupd neg change-balance rebalance-delete ] }
    } cond ;

: avl-replace-with-extremity ( to-replace node -- node shorter? )
    dup node-link [
        swapd avl-replace-with-extremity >r over set-node-link r> [ balance-delete ] [ f ] if
    ] [
        tuck copy-node-contents node+link t
    ] if* ;

: replace-with-a-child ( node -- node shorter? )
    #! assumes that node is not a leaf, otherwise will recurse forever
    dup node-link [
        dupd [ avl-replace-with-extremity ] with-other-side >r over set-node-link r> [
            balance-delete
        ] [
            f
        ] if
    ] [
        [ replace-with-a-child ] with-other-side
    ] if* ;

: avl-delete-node ( node -- node shorter? )
    #! delete this node, returning its replacement, and whether this subtree is
    #! shorter as a result
    dup leaf? [
        drop f t
    ] [
        random-side [ replace-with-a-child ] with-side ! random not necessary, just for fun
    ] if ;

GENERIC: avl-delete ( key node -- node shorter? deleted? )

M: f avl-delete ( key f -- f f f ) nip f f ;

: (avl-delete) ( key node -- node shorter? deleted? )
    tuck node-link avl-delete >r >r over set-node-link r> [ balance-delete r> ] [ f r> ] if ;

M: avl-node avl-delete ( key node -- node shorter? deleted? )
    2dup node-key key-side dup zero? [
        drop nip avl-delete-node t
    ] [
        [
            (avl-delete)
        ] with-side
    ] if ;

M: avl-node node-delete ( key node -- node ) avl-delete 2drop ;

M: avl-node node-delete-all ( key node -- node )
    #! deletes until there are no more. not optimal.
    dupd [ avl-delete nip ] with-scope [
        node-delete-all
    ] [
        nip
    ] if ;

M: avl-node print-node ( depth node -- )
    over 1+ over node-right print-node
    over [ drop "   " write ] each
    dup avl-node-balance number>string write " " write dup node-key number>string print
    >r 1+ r> node-left print-node ;

