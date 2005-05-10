! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: generic inference kernel lists math namespaces
prettyprint strings words ;

! A peephole optimizer operating on the linear IR.

! The linear IR being simplified is stored in this variable.
SYMBOL: simplifying

GENERIC: simplify-node ( linear vop -- linear ? )

! The next node following this node in terms of control flow, or
! f if this is a conditional.
GENERIC: next-logical ( linear vop -- linear )

! No delegation.
M: tuple simplify-node drop f ;

: simplify-1 ( list -- list ? )
    #! Return a new linear IR.
     dup [
         dup car simplify-node
         [ uncons simplify-1 drop cons t ]
         [ uncons simplify-1 >r cons r> ] ifte
     ] [
         f
     ] ifte ;

: simplify ( linear -- linear )
    #! Keep simplifying until simplify-1 returns f.
    [
        dup simplifying set  simplify-1
    ] with-scope  [ simplify ] when ;

: label-called? ( label -- ? )
    simplifying get [ calls-label? ] some-with? ;

M: %label simplify-node ( linear vop -- linear ? )
    vop-label label-called? [ f ] [ cdr t ] ifte ;

: next-physical? ( linear class -- vop ? )
    #! If the following op has given class, remove it and
    #! return it.
    over cdr dup [
        car class = [ cdr car t ] [ f ] ifte
    ] [
        3drop f f
    ] ifte ;

M: %inc-d simplify-node ( linear vop -- linear ? )
    #! %inc-d cancels a following %inc-d.
    >r dup \ %inc-d next-physical? [
        vop-literal r> vop-literal + dup 0 = [
            drop cdr cdr f
        ] [
            %inc-d >r cdr cdr r> swons t
        ] ifte
    ] [
        r> 2drop f
    ] ifte ;

: dead-load? ( linear vop -- ? )
    #! Is the %replace-d followed by a %peek-d of the same
    #! stack slot and vreg?
    swap cdr car dup %peek-d? [
        over vop-source over vop-dest = >r
        swap vop-literal swap vop-literal = r> and
    ] [
        2drop f
    ] ifte ;

: dead-store? ( linear n -- ? )
    #! Is the %replace-d followed by a %dec-d, so the stored
    #! value is lost?
    swap \ %inc-d next-physical? [
        vop-literal + 0 <
    ] [
        2drop f
    ] ifte ;

M: %replace-d simplify-node ( linear vop -- linear ? )
    2dup dead-load? [
        drop uncons cdr cons t
    ] [
        2dup vop-literal dead-store? [
            drop cdr t
        ] [
            drop f
        ] ifte
    ] ifte ;

M: %immediate-d simplify-node ( linear vop -- linear ? )
    over 0 dead-store? [ drop cdr t ] [ drop f ] ifte ;

: pop? ( vop -- ? ) dup %inc-d? swap vop-literal -1 = and ;

: can-fast-branch? ( linear -- ? )
    unswons class fast-branch [
        unswons pop? [ car %jump-t? ] [ drop f ] ifte
    ] [
        drop f
    ] ifte ;

: fast-branch-params ( linear -- src dest label linear )
    uncons >r dup vop-source swap vop-dest r> cdr
    uncons >r vop-label r> ;

: make-fast-branch ( linear op -- linear ? )
    >r dup can-fast-branch? [
        fast-branch-params r> swap >r
        execute >r -1 %inc-d r>
        r> cons cons t
    ] [
        r> drop f
    ] ifte ;

M: fast-branch simplify-node ( linear vop -- linear ? )
    class fast-branch make-fast-branch ;

: find-label ( label -- rest )
    simplifying get [
        dup %label? [ vop-label = ] [ 2drop f ] ifte
    ] some-with? ;

M: %label next-logical ( linear vop -- linear )
    drop cdr dup car next-logical ;

M: %jump-label next-logical ( linear vop -- linear )
    nip vop-label find-label cdr ;

M: %target-label next-logical ( linear vop -- linear )
    nip vop-label find-label cdr ;

M: object next-logical ( linear vop -- linear )
    drop ;

: next-logical? ( op linear -- ? )
    dup car next-logical dup [ car class = ] [ 2drop f ] ifte ;

: reduce ( linear op new -- linear ? )
    >r over cdr next-logical? [
        dup car vop-label
        r> execute swap cdr cons t
    ] [
        r> drop f
    ] ifte ; inline

M: %call simplify-node ( linear vop -- ? )
    #! Tail call optimization.
    drop \ %return \ %jump reduce ;

M: %call-label simplify-node ( linear vop -- ? )
    #! Tail call optimization.
    drop \ %return \ %jump-label reduce ;

: double-jump ( linear op2 op1 -- linear ? )
    #! A jump to a jump is just a jump. If the next logical node
    #! is a jump of type op1, replace the jump at the car of the
    #! list with a jump of type op2.
    pick next-logical? [
        >r dup dup car next-logical car vop-label
        r> execute swap cdr cons t
    ] [
        drop f
    ] ifte ; inline

: useless-jump ( linear -- linear ? )
    #! A jump to a label immediately following is not needed.
    dup car vop-label find-label find-label
    over cdr eq? [ cdr t ] [ f ] ifte ;

: (dead-code) ( linear -- linear ? )
    #! Remove all nodes until the next #label.
    dup [
        dup car %label? [
            f
        ] [
            cdr (dead-code) t or
        ] ifte
    ] [
        f
    ] ifte ;

: dead-code ( linear -- linear ? )
    uncons (dead-code) >r cons r> ;

M: %jump-label simplify-node ( linear vop -- linear ? )
    drop
    \ %return dup double-jump [
        t
    ] [
        \ %jump-label dup double-jump [
            t
        ] [
            \ %jump dup double-jump
            [
                t
            ] [
                useless-jump [
                    t
                ] [
                    dead-code
                ] ifte
            ] ifte
        ] ifte
    ] ifte ;

M: %target-label simplify-node ( linear vop -- linear ? )
    drop
    \ %target-label \ %jump-label double-jump ;

M: %jump simplify-node ( linear vop -- linear ? )
    drop dead-code ;

M: %return simplify-node ( linear vop -- linear ? )
    drop dead-code ;

M: %end-dispatch simplify-node ( linear vop -- linear ? )
    drop dead-code ;
