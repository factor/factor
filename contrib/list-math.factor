IN: list-math
USE: lists
USE: math
USE: stack
USE: combinators
USE: kernel
USE: logic
USE: math
USE: stack

: 2uncons ( list1 list2 -- car1 car2 cdr1 cdr2 )
    uncons >r >r uncons r> swap r> ;

: 2each-step ( list list quot -- cdr cdr )
    >r 2uncons r> -rot 2slip ; inline interpret-only

: 2each ( list list quot -- )
    #! Apply the quotation to each pair of elements from the
    #! two lists in turn. The quotation must have stack effect
    #! ( x y -- ).
    >r 2dup and [
        r> dup >r 2each-step r> 2each
    ] [
        r> 3drop
    ] ifte ;

: 2map-step ( accum quot elt elt -- accum )
    2swap swap slip cons ;

: <2map ( list list quot -- accum quot list list )
    >r f -rot r> -rot ;

: 2map ( list list quot -- list )
    #! Apply the quotation to each pair of elements from the
    #! two lists in turn, collecting the return value into a
    #! new list. The quotation must have stack effect
    #! ( x y -- z ).
    <2map [ pick >r 2map-step r> ] 2each drop reverse ;

: |+ ( list -- sum )
    #! sum all elements in a list.
    0 swap [ + ] each ;

: +| ( list list -- list )
    [ + ] 2map ;

: |* ( list -- sum )
    #! multiply all elements in a list.
    1 swap [ * ] each ;

: *| ( list list -- list )
    [ * ] 2map ;

: *|+ ( list list -- dot )
    #! Dot product
    *| |+ ;

: average ( list -- avg )
    dup |+ swap length / ;
