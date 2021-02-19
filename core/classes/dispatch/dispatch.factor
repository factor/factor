USING: classes kernel ;

IN: classes.dispatch

! * Dispatch Types
! This is an attempt to formalize the notion of treating dispatch types
! separately from data type classes to have a basis for specifying abstract
! dispatch types.

MIXIN: dispatch-type
INSTANCE: dispatch-type classoid
GENERIC: dispatch<= ( dispatch-type1 dispatch-type2 -- ? )

! Dispatch types per default not comparable to concrete types
M: classoid dispatch<= 2drop f ;
GENERIC: class>dispatch ( class -- dispatch-type )
M: dispatch-type class>dispatch ;
! This is used when building a decision tree to find the most specific method
! for a specific stack position
GENERIC: nth-dispatch-class ( index dispatch-type -- class )
GENERIC: dispatch-arity ( dispatch-type -- n )
! This is meant for when the applicability is not only depending on the concrete
! type at index.
GENERIC: nth-dispatch-applicable? ( class index dispatch-type -- ? )
GENERIC: dispatch-predicate-def ( dispatch-type -- quot )
