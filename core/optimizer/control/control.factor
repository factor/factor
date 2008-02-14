! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs inference inference.class
inference.dataflow inference.backend inference.state io kernel
math namespaces sequences vectors words quotations hashtables
combinators classes generic.math continuations optimizer.def-use
optimizer.backend generic.standard ;
IN: optimizer.control

! ! ! Loop detection

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
! NOT A LOOP (call to A nested inside another label/loop):
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
!              ...     ...

GENERIC: detect-loops* ( node -- )

M: node detect-loops* drop ;

M: #label detect-loops* t swap set-#label-loop? ;

: not-a-loop ( #label -- )
    f swap set-#label-loop? ;

: tail-call? ( -- ? )
    node-stack get
    dup [ #label? ] find-last drop [ 1+ ] [ 0 ] if* tail
    [ node-successor #tail? ] all? ;

: detect-loop ( seen-other? label node -- seen-other? continue? )
    #! seen-other?: have we seen another label?
    {
        { [ dup #label? not ] [ 2drop t ] }
        { [ 2dup node-param eq? not ] [ 3drop t t ] }
        { [ tail-call? not ] [ not-a-loop drop f ] }
        { [ pick ] [ not-a-loop drop f ] }
        { [ t ] [ 2drop f ] }
    } cond ;

M: #call-label detect-loops*
    f swap node-param node-stack get <reversed>
    [ detect-loop ] with all? 2drop ;

: detect-loops ( node -- )
    [ detect-loops* ] each-node ;

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
: only-one ( seq -- elt/f )
    dup length 1 = [ first ] [ drop f ] if ;

: lift-throw-tail? ( #if -- tail/? )
    dup node-successor #tail?
    [ drop f ] [ active-children only-one ] if ;

: clone-node ( node -- newnode )
    clone dup [ clone ] modify-values ;

: detach-node-successor ( node -- successor )
    dup node-successor #terminate rot set-node-successor ;

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
! but not if (**) is #values

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

: fold-dispatch-branch? dup node-in-d first tuck node-literal? ;

: fold-dispatch-branch ( node value -- node' )
    dupd node-literal
    over drop-inputs >r fold-branch r>
    [ set-node-successor ] keep ;

M: #dispatch optimize-node*
    dup fold-dispatch-branch? [
        fold-dispatch-branch t
    ] [
        2drop t f
    ] if ;

! Loop tail hoising: code after a loop can sometimes go in the
! non-recursive branch of the loop

! BEFORE:

!   #label -> C -> #return 1
!     |
!     -> #if -> #merge -> #return 2
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

!    #label -> #terminate
!     |
!     -> #if -> #terminate
!         |
!     --------
!     |      |
!     A      B
!     |      |
!  #values   |
!     |  #call-label
!  #merge    |
!     |      |
!     C   #values
!     |
!  #return 1

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

: lift-loop-tail? ( #label -- tail/f )
    dup node-successor node-successor [
        dup node-param swap node-child find-final-if dup [
            node-children [ penultimate-node ] map
            [
                dup #call-label?
                [ node-param eq? not ] [ 2drop t ] if
            ] with subset only-one
        ] [ 2drop f ] if
    ] [ drop f ] if ;

! M: #loop optimize-node*
!     dup lift-loop-tail? dup [
!         last-node >r
!         dup detach-node-successor
!         over node-child find-final-if detach-node-successor
!         [ set-node-successor ] keep
!         r> set-node-successor
!         t
!     ] [
!         2drop t f
!     ] if ;
