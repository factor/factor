USING: assocs classes.algebra classes.dispatch kernel sequences ;

IN: classes.dispatch.order

! * Ordering Dispatch Types
! ** Ordering as whole
! This is used for ordering methods.
! : dispatch<=> ( dispatch-type1 dispatch-type2 -- <=> )
!     [ class<= +lt+ or ] [ swap class<= +gt+ or ] 2bi


! ** Ordering locally per position


! Used for incremental dispatch.
: sort-dispatch ( seq key: ( elt -- class/f ) -- assoc )
    '[ _ call( elt -- class ) ] collect-by
    ! FIXME: inlined sort-methods here, move to sort-by-class in classes?
    >alist sift-keys [ keys sort-classes ] keep extract-keys ;
