! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: arrays hashtables kernel lists math namespaces sequences ;

! Optimizations performed here:
! - combining %inc-d/%inc-r within a single basic block
! - removing dead loads of stack locations into vregs
! - removing dead stores of vregs into stack locations

: vop-in ( vop n -- input ) swap vop-inputs nth ;
: set-vop-in ( input vop n -- ) swap vop-inputs set-nth ;
: vop-out ( vop n -- input ) swap vop-outputs nth ;

: (split-blocks) ( n linear -- )
    2dup length = [
        dup like , drop
    ] [
        2dup nth basic-block? [
            >r 1+ r> (split-blocks)
        ] [
            (cut) >r , 1 r> (cut) >r , 0 r> (split-blocks)
        ] if
    ] if ;

: split-blocks ( linear -- blocks )
    [ 0 swap (split-blocks) ] { } make ;

SYMBOL: d-height
SYMBOL: r-height

! combining %inc-d/%inc-r
GENERIC: simplify-stack* ( vop -- )

M: tuple simplify-stack* ( vop -- ) drop ;

: accum-height ( vop var -- )
    >r dup 0 vop-in r> [ + ] change 0 swap 0 set-vop-in ;

M: %inc-d simplify-stack* ( vop -- ) d-height accum-height ;

M: %inc-r simplify-stack* ( vop -- ) r-height accum-height ;

GENERIC: update-loc ( loc -- )

M: ds-loc update-loc
    dup ds-loc-n d-height get - swap set-ds-loc-n ;

M: cs-loc update-loc
    dup cs-loc-n r-height get - swap set-cs-loc-n ;

M: %peek simplify-stack* ( vop -- ) 0 vop-in update-loc ;

M: %replace simplify-stack* ( vop -- ) 0 vop-out update-loc ;

: simplify-stack ( block -- )
    #! Combine all %inc-d/%inc-r into two final ones.
    #! Destructively modifies the VOPs in the block.
    [ simplify-stack* ] each ;

: each-tail ( seq quot -- | quot: tail -- )
    >r dup length [ swap tail-slice ] map-with r> each ; inline

! removing dead loads/stores
: preserves-location? ( exitcc location vop -- ? )
    #! If the VOP writes the register, call the loop exit
    #! continuation with 'f'.
    {
        { [ 2dup vop-inputs member? ] [ 3drop t ] }
        { [ 2dup vop-outputs member? ] [ 2drop f swap continue-with ] }
        { [ t ] [ 3drop f ] }
    } cond ;

GENERIC: live@end? ( location -- ? )

M: tuple live@end? drop t ;

M: ds-loc live@end? ds-loc-n d-height get + 0 >= ;

M: cs-loc live@end? cs-loc-n r-height get + 0 >= ;

: location-live? ( location tail -- ? )
    #! A location is not live if and only if it is overwritten
    #! before the end of the basic block.
    [
        -rot [ >r 2dup r> preserves-location? ] contains?
        [ dup live@end? ] unless*
    ] callcc1 2nip ;

! Used for elimination of dead loads from the stack:
! we keep a map of vregs to ds-loc/cs-loc/f.
SYMBOL: vreg-contents

GENERIC: trim-dead* ( tail vop -- )

: forget-vregs ( vop -- )
    vop-outputs [ vreg-contents get remove-hash ] each ;

M: tuple trim-dead* ( tail vop -- ) dup forget-vregs , drop ;

: simplify-inc ( vop -- ) dup 0 vop-in 0 = not ?, ;

M: %inc-d trim-dead* ( tail vop -- ) simplify-inc drop ;

M: %inc-r trim-dead* ( tail vop -- ) simplify-inc drop ;

: live-load? ( tail vop -- ? )
    #! If the VOP's output location is overwritten before being
    #! read again, kill the VOP.
    0 vop-out swap location-live? ;

: remember-peek ( vop -- )
    dup 0 vop-in swap 0 vop-out vreg-contents get set-hash ;

: redundant-peek? ( vop -- ? )
    dup 0 vop-in swap 0 vop-out vreg-contents get hash = ;

M: %peek trim-dead* ( tail vop -- )
    dup redundant-peek? >r tuck live-load? not r> or
    [ dup remember-peek dup , ] unless drop ;

: redundant-replace? ( vop -- ? )
    dup 0 vop-out swap 0 vop-in vreg-contents get hash = ;

: forget-stack-loc ( loc -- )
    #! Forget that any vregs hold this stack location.
    vreg-contents [ [ nip swap = not ] hash-subset-with ] change ;

: remember-replace ( vop -- )
    #! If a vreg claims to hold the stack location we are
    #! writing to, we must forget this fact, since that stack
    #! location no longer holds this value!
    dup 0 vop-out forget-stack-loc
    dup 0 vop-out swap 0 vop-in vreg-contents get set-hash ;

M: %replace trim-dead* ( tail vop -- )
    dup redundant-replace? >r tuck live-load? not r> or
    [ dup remember-replace dup , ] unless drop ;

: ?dead-literal dup forget-vregs tuck live-load? ?, ;

M: %immediate trim-dead* ( tail vop -- ) ?dead-literal ;

M: %indirect trim-dead* ( tail vop -- ) ?dead-literal ;

: trim-dead ( block -- )
    #! Remove dead loads and stores.
    [ dup first >r 1 swap tail-slice r> trim-dead* ] each-tail ;

: simplify-block ( block -- block )
    #! Destructively modifies the VOPs in the block.
    [
        0 d-height set
        0 r-height set
        H{ } clone vreg-contents set
        dup simplify-stack
        d-height get %inc-d r-height get %inc-r 2array append
        trim-dead
    ] { } make ;

: keep-simplifying ( block -- block )
    dup length >r simplify-block dup length r> =
    [ keep-simplifying ] unless ;

: simplify ( blocks -- blocks )
    #! Simplify basic block IR.
    [ keep-simplifying ] map ;
