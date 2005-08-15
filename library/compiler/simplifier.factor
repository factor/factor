! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: generic inference kernel lists math namespaces
prettyprint sequences strings words ;

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
    simplifying get [ calls-label? ] contains-with? ;

M: %label simplify-node ( linear vop -- linear ? )
    vop-label label-called? [ f ] [ cdr t ] ifte ;

: next-physical? ( linear class -- vop ? )
    #! If the following op has given class, remove it and
    #! return it.
    over cdr dup [
        car class = [ second t ] [ f ] ifte
    ] [
        3drop f f
    ] ifte ;

M: %inc-d simplify-node ( linear vop -- linear ? )
    #! %inc-d cancels a following %inc-d.
    dup vop-in-1 0 = [
        drop cdr t
    ] [
        >r dup \ %inc-d next-physical? [
            vop-in-1 r> vop-in-1 + 
            %inc-d >r cdr cdr r> swons t
        ] [
            r> 2drop f
        ] ifte
    ] ifte ;

: operands= ( vop vop -- ? )
    over vop-inputs over vop-inputs =
    >r swap vop-outputs swap vop-outputs = r> and ;

: cancel ( linear class -- linear ? )
    dupd next-physical?
    [ over first operands= [ cdr cdr t ] [ f ] ifte ]
    [ drop f ] ifte ;

M: %retag-fixnum simplify-node ( linear vop -- linear ? )
    drop \ %untag-fixnum cancel ;

: basic-block ( linear quot -- | quot: vop -- ? )
    #! Keep applying the quotation to each VOP until either a
    #! VOP answering f to basic-block?, or the quotation answers
    #! f.
    over car basic-block? [
        >r uncons r> tuck >r >r call [
            r> r> basic-block
        ] [
            r> r> 2drop
        ] ifte
    ] [
        2drop
    ] ifte ; inline

: reads-vreg? ( vreg linear -- ? )
    #! Tests if the vreg is read before being written in the
    #! current basic block. Outputs a true value if the vreg
    #! is not read or written before the end of the basic block.
    [
        2dup vop-inputs member? [
            ! we are reading the vreg
            2drop t f
        ] [
            2dup vop-outputs member? [
                ! we are writing the vreg
                2drop f f
            ] [
                ! keep checking
                drop t
            ] ifte
        ] ifte
    ] basic-block ;

: dead-load ( vreg linear -- linear ? )
    #! If the vreg is not read before being written, drop
    #! the current VOP.
    tuck cdr reads-vreg? [ f ] [ cdr t ] ifte ;

M: %peek-d simplify-node ( linear vop -- linear ? )
    vop-out-1 swap dead-load ;

M: %immediate simplify-node ( linear vop -- linear ? )
    vop-out-1 swap dead-load ;

M: %indirect simplify-node ( linear vop -- linear ? )
    vop-out-1 swap dead-load ;

: dead-peek? ( linear vop -- ? )
    #! Is the %replace-d followed by a %peek-d of the same
    #! stack slot and vreg?
    swap second dup %peek-d? [
        over vop-in-2 over vop-out-1 = >r
        swap vop-in-1 swap vop-in-1 = r> and
    ] [
        2drop f
    ] ifte ;

: dead-replace? ( linear n -- ? )
    #! Is the %replace-d followed by a %dec-d, so the stored
    #! value is lost?
    swap \ %inc-d next-physical? [
        vop-in-1 + 0 <
    ] [
        2drop f
    ] ifte ;

M: %replace-d simplify-node ( linear vop -- linear ? )
    2dup dead-peek? [
        drop uncons cdr cons t
    ] [
        dupd vop-in-1 dead-replace? [ cdr t ] [ f ] ifte
    ] ifte ;

: pop? ( vop -- ? ) dup %inc-d? swap vop-in-1 -1 = and ;

: can-fast-branch? ( linear -- ? )
    unswons class fast-branch [
        unswons pop? [ car %jump-t? ] [ drop f ] ifte
    ] [
        drop f
    ] ifte ;

: fast-branch-params ( linear -- src dest label linear )
    uncons >r dup vop-in-1 swap vop-out-1 r> cdr
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

: ?label ( symbol linear -- ? )
    car dup %label? [ vop-label = ] [ 2drop f ] ifte ;

: (find-label) ( label linear -- linear )
    dup
    [ 2dup ?label [ nip ] [ cdr (find-label) ] ifte ]
    [ 2drop f ] ifte ;

: find-label ( label -- rest )
    simplifying get (find-label) ;

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

: collapse ( linear op new -- linear ? )
    >r over cdr next-logical? [
        dup car vop-label
        r> execute swap cdr cons t
    ] [
        r> drop f
    ] ifte ; inline

M: %call simplify-node ( linear vop -- ? )
    #! Tail call optimization.
    drop \ %return \ %jump collapse ;

M: %call-label simplify-node ( linear vop -- ? )
    #! Tail call optimization.
    drop \ %return \ %jump-label collapse ;

: double-jump ( linear op2 op1 -- linear ? )
    #! A jump to a jump is just a jump. If the next logical node
    #! is a jump of type op1, replace the jump at the car of the
    #! list with a jump of type op2.
    pick next-logical? [
        >r dup dup car next-logical car vop-label
        r> execute swap cdr cons t
    ] [ drop f ] ifte ; inline

: useless-jump ( linear -- linear ? )
    #! A jump to a label immediately following is not needed.
    dup car vop-label find-label find-label
    over cdr eq? [ cdr t ] [ f ] ifte ;

: (dead-code) ( linear -- linear ? )
    #! Remove all nodes until the next #label.
    dup [
        dup car %label?
        [ f ] [ cdr (dead-code) t or ] ifte
    ] [ f ] ifte ;

: dead-code ( linear -- linear ? )
    uncons (dead-code) >r cons r> ;

M: %jump-label simplify-node ( linear vop -- linear ? )
    drop {
        { [ \ %return dup double-jump ] [ t ] }
        { [ \ %jump-label dup double-jump ] [ t ] }
        { [ \ %jump dup double-jump ] [ t ] }
        { [ useless-jump ] [ t ] }
        { [ t ] [ dead-code ] }
    } cond ;

M: %target-label simplify-node ( linear vop -- linear ? )
    drop
    \ %target-label \ %jump-label double-jump ;

M: %jump simplify-node ( linear vop -- linear ? )
    drop dead-code ;

M: %return simplify-node ( linear vop -- linear ? )
    drop dead-code ;

M: %end-dispatch simplify-node ( linear vop -- linear ? )
    drop dead-code ;
