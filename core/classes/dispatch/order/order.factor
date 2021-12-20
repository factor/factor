USING: accessors arrays assocs classes.algebra classes.dispatch.covariant-tuples
kernel sequences sets ;

IN: classes.dispatch.order

! * Ordering Dispatch Types
! ** Ordering as whole
! Ordering is done via class<=

! Dispatch is ambiguous if there is an intersection but no strict local order.
! FIXME: used cartesian-map instead of map-combinations because of bootstrapping
! dependency problems.  This means we have a lot of unnecessary comparisons.
: ambiguous-dispatch-types ( dispatch-types -- classes )
    dup [
        2dup classes-intersect?
        [ 2dup compare-classes +incomparable+ =
          [ 2array ] [ 2drop f ] if
        ] [ 2drop f ] if
    ] cartesian-map concat sift
    [ first2 [ classes>> ] bi@ [ class-and ] 2map <covariant-tuple> ] map
    members
    ;


! ** Ordering locally per position


! Used for incremental dispatch.
: sort-dispatch ( seq key: ( elt -- class/f ) -- assoc )
    '[ _ call( elt -- class ) ] collect-by
    ! FIXME: inlined sort-methods here, move to sort-by-class in classes?
    >alist sift-keys [ keys sort-classes ] keep extract-keys ;
