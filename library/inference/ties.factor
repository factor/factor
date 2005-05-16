! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: kernel lists prettyprint ;

! A tie is when a literal value determines the type or value of
! a computed result. For example, in the following code, the
! type of the top of the stack depends on the outcome of the
! branch:
!
! dup cons? [ ... ] [ ... ] ifte
!
! In each branch, there is a different tie of the value to a
! type.
!
! Another type of tie happends with generic dispatch.
!
! The return value of the 'type' primitive determines the type
! of a value. The branch chosen in a dispatch determines the
! numeric value used as the dispatch parameter. Because of a
! pair of ties, this allows inferences such as the following
! having a stack effect of [ [ cons ] [ object ] ]:
!
! GENERIC: car
! M: cons car 0 slot ;
!
! The only branch that does not end with no-method pulls
! a tie that sets the value's type to cons after two steps.

! Formally, a tie is a tuple.

GENERIC: pull-tie ( tie -- )

TUPLE: class-tie value class ;
M: class-tie pull-tie ( tie -- )
    dup class-tie-class swap class-tie-value
    2dup set-value-class
    value-class-ties assoc pull-tie ;

TUPLE: literal-tie value literal ;
M: literal-tie pull-tie ( tie -- )
    dup literal-tie-literal swap literal-tie-value
    dup literal? [ 2dup set-literal-value ] when
    value-literal-ties assoc pull-tie ;

M: f pull-tie ( tie -- )
    #! For convenience.
    drop ;
