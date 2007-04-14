! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs inference inference.class
inference.dataflow inference.backend inference.state io kernel
math namespaces sequences vectors words quotations hashtables
combinators classes classes.algebra generic.math continuations
optimizer.def-use optimizer.backend generic.standard ;
IN: optimizer.control

! ! ! Rudimentary CFA

! A LOOP
!
!          #label A
!             |
!            #if ----> #merge ----> #return
!             |
!       -------------
!       |           |
! #call-label A     |
!       |          ...
!    #values
!
! NOT A LOOP (call to A not in tail position):
!
!
!          #label A
!             |
!            #if ----> ... ----> #merge ----> #return
!             |
!       -------------
!       |           |
! #call-label A     |
!       |          ...
!      ...
!       |
!    #values
!
! NOT A LOOP (call to A nested inside another label which is
! not a loop):
!
!
!          #label A
!             |
!            #if ----> #merge ----> ... ----> #return
!             |
!       -------------
!       |           |
!      ...      #label B
!                   |
!                  #if -> ...
!                   |
!               ---------
!               |       |
!         #call-label A |
!               |       |
!           #values     |
!                 #call-label B
!                       |
!                      ...

! Mapping word => { node { nesting tail? }+ height }
! We record all calls to a label, their control nesting and
! whether it is a tail call or not
SYMBOL: label-info

GENERIC: collect-label-info* ( node -- )

M: #label collect-label-info*
    [ V{ } clone node-stack get length 3array ] keep
    node-param label-info get set-at ;

USE: prettyprint

M: #call-label collect-label-info*
    node-param label-info get at
    node-stack get over third tail
    [ [ #label? ] subset [ node-param ] map ] keep
    [ node-successor #tail? ] all? 2array
    swap second push ;

M: node collect-label-info*
    drop ;

: collect-label-info ( node -- )
    H{ } clone label-info set
    [ collect-label-info* ] each-node ;

! Mapping word => label
SYMBOL: potential-loops

: remove-non-tail-calls ( -- )
    label-info get
    [ nip second [ second ] all? ] assoc-subset
    [ first ] assoc-map
    potential-loops set ;

: remove-non-loop-calls ( -- )
    ! Boolean is set to t if something changed.
    !  We recurse until a fixed point is reached.
    f label-info get [
        ! If label X is called from within a label Y that is
        ! no longer a potential loop, then X is no longer a
        ! potential loop either.
        over potential-loops get key? [
            second [ first ] map concat
            potential-loops get [ key? ] curry all?
            [ drop ] [ potential-loops get delete-at t or ] if
        ] [ 2drop ] if
    ] assoc-each [ remove-non-loop-calls ] when ;

: detect-loops ( nodes -- )
    [
        collect-label-info
        remove-non-tail-calls
        remove-non-loop-calls
        potential-loops get [
            nip t swap set-#label-loop?
        ] assoc-each
    ] with-scope ;

! ! ! Constant branch folding
!
! BEFORE
!
!      #if ----> #merge ----> C
!       |
!   ---------
!   |       |
!   A       B
!   |       |
! #values   |
!        #values
!
! AFTER
!
!       |
!       A
!       |
!    #values
!       |
!    #merge
!       |
!       C

: fold-branch ( node branch# -- node )
    over node-children nth
    swap node-successor over splice-node ;

! #if
: known-boolean-value? ( node value -- value ? )
    2dup node-literal? [
        node-literal t
    ] [
        node-class {
            { [ dup null class< ] [ drop f f ] }
            { [ dup general-t class< ] [ drop t t ] }
            { [ dup \ f class< ] [ drop f t ] }
            { [ t ] [ drop f f ] }
        } cond
    ] if ;

: fold-if-branch? dup node-in-d first known-boolean-value? ;

: fold-if-branch ( node value -- node' )
    over drop-inputs >r
    0 1 ? fold-branch
    r> [ set-node-successor ] keep ;

! ! ! Lifting code after a conditional if one branch throws

! BEFORE
!
!         #if ----> #merge ----> B ----> #return/#values
!          |
!          |
!      ---------
!      |       |
!      |       A
! #terminate   |
!           #values
!
! AFTER
!
!         #if ----> #merge (*) ----> #return/#values (**)
!          |
!          |
!      ---------
!      |       |
!      |       A
! #terminate   |
!           #values
!              |
!           #merge (***)
!              |
!              B
!              |
!        #return/#values
!
! (*) has the same outputs as the inputs of (**), and it is not
! the same node as (***)
!
! Note: if (**) is #return is is sound to put #terminate there,
! but not if (**) is #

: only-one ( seq -- elt/f )
    dup length 1 = [ first ] [ drop f ] if ;

: lift-throw-tail? ( #if -- tail/? )
    dup node-successor #tail?
    [ drop f ] [ active-children only-one ] if ;

: clone-node ( node -- newnode )
    clone dup [ clone ] modify-values ;

: lift-branch
    over
    last-node clone-node
    dup node-in-d \ #merge out-node
    [ set-node-successor ] keep -rot
    >r dup node-successor r> splice-node
    set-node-successor ;

M: #if optimize-node*
    dup fold-if-branch? [ fold-if-branch t ] [
        drop dup lift-throw-tail? dup [
            dupd lift-branch t
        ] [
            2drop t f
        ] if
    ] if ;

! Loop tail hoising: code after a loop can sometimes go in the
! non-recursive branch of the loop

! BEFORE:

!   #label -> C -> #return 1
!     |
!     -> #if -> #merge (*) -> #return 2
!         |
!     --------
!     |      |
!     A      B
!     |      |
!  #values   |
!        #call-label
!            |
!            |
!         #values

! AFTER:

!        #label -> #return 1
!         |
!         -> #if -------> #merge (*) -> #return 2
!             |           \-------------------/
!     ----------------              |
!     |              |              |
!     A              B     unreacachable code needed to
!     |              |         preserve invariants
!  #values           |
!     |          #call-label
!  #merge (*)        |
!     |              |
!     C           #values
!     |
!  #return 1

: find-tail ( node -- tail )
    dup #terminate? [
        dup node-successor #tail? [
            node-successor find-tail
        ] unless
    ] unless ;

: child-tails ( node -- seq )
    node-children [ find-tail ] map ;

GENERIC: add-loop-exit* ( label node -- )

M: #branch add-loop-exit*
    child-tails [ add-loop-exit* ] with each ;

M: #call-label add-loop-exit*
    tuck node-param eq? [ drop ] [ node-successor , ] if ;

M: #terminate add-loop-exit*
    2drop ;

M: node add-loop-exit*
    nip node-successor dup #terminate? [ drop ] [ , ] if ;

: find-loop-exits ( label node -- seq )
    [ add-loop-exit* ] { } make ;

: find-final-if ( node -- #if/f )
    dup [
        dup #if? [
            dup node-successor #tail? [
                node-successor find-final-if
            ] unless
        ] [
            node-successor find-final-if
        ] if
    ] when ;

: detach-node-successor ( node -- successor )
    dup node-successor #terminate rot set-node-successor ;

: lift-loop-tail? ( #label -- tail/f )
    dup node-successor node-successor [
        dup node-param swap node-child find-final-if dup [
            find-loop-exits only-one
        ] [ 2drop f ] if
    ] [ drop f ] if ;

M: #loop optimize-node*
    dup lift-loop-tail? dup [
        last-node "values" set

        dup node-successor "tail" set
        dup node-successor last-node "return" set
        dup node-child find-final-if node-successor "merge" set

        ! #label -> #return
        "return" get clone-node over set-node-successor
        ! #merge -> C
        "merge" get clone-node "tail" get over set-node-successor
        ! #values -> #merge ->C
        "values" get set-node-successor

        t
    ] [
        2drop t f
    ] if ;
