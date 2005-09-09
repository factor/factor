IN: compiler-backend
USING: kernel math namespaces sequences vectors ;

: (split-blocks) ( n linear -- )
    2dup length = [
        dup like , drop
    ] [
        2dup nth basic-block? [
            >r 1 + r> (split-blocks)
        ] [
            (cut) >r , 1 r> (cut) >r , 0 r> (split-blocks)
        ] ifte
    ] ifte ;

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

: update-ds ( vop -- )
    dup ds-loc-n d-height get - swap set-ds-loc-n ;

: update-cs ( vop -- )
    dup cs-loc-n r-height get - swap set-cs-loc-n ;

M: %peek-d simplify-stack* ( vop -- ) 0 vop-in update-ds ;

M: %peek-r simplify-stack* ( vop -- ) 0 vop-in update-cs ;

M: %replace-d simplify-stack* ( vop -- ) 0 vop-out update-ds ;

M: %replace-r simplify-stack* ( vop -- ) 0 vop-out update-cs ;

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
        { [ 2dup vop-outputs member? ] [ 2drop f swap call ] }
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

! Set if trim-dead* removed some VOPs.
GENERIC: trim-dead* ( tail vop -- )

M: tuple trim-dead* ( tail vop -- ) , drop ;

: simplify-inc ( vop -- ) dup 0 vop-in 0 = not ?, ;

M: %inc-d trim-dead* ( tail vop -- ) simplify-inc drop ;

M: %inc-r trim-dead* ( tail vop -- ) simplify-inc drop ;

: ?dead-load ( tail vop -- )
    #! If the VOP's output location is overwritten before being
    #! read again, kill the VOP.
    dup 0 vop-out rot location-live? ?, ;

M: %peek-d trim-dead* ( tail vop -- ) ?dead-load ;

M: %peek-r trim-dead* ( tail vop -- ) ?dead-load ;

M: %replace-d trim-dead* ( tail vop -- ) ?dead-load ;

M: %replace-r trim-dead* ( tail vop -- ) ?dead-load ;

M: %immediate trim-dead* ( tail vop -- ) ?dead-load ;

M: %indirect trim-dead* ( tail vop -- ) ?dead-load ;

: trim-dead ( block -- )
    #! Remove dead loads and stores.
    [ dup first >r 1 swap tail-slice r> trim-dead* ] each-tail ;

: simplify-block ( block -- block )
    #! Destructively modifies the VOPs in the block.
    [
        0 d-height set
        0 r-height set
        dup simplify-stack
        d-height get %inc-d r-height get %inc-r 2vector append
        trim-dead
    ] { } make ;

: keep-simplifying ( block -- block )
    dup length >r simplify-block dup length r>
    = [ keep-simplifying ] unless ;

: simplify ( blocks -- blocks )
    #! Simplify basic block IR.
    [ keep-simplifying ] map ;
