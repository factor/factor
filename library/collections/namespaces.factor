! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
DEFER: literalize

IN: namespaces
USING: hashtables kernel kernel-internals lists math sequences
strings vectors words ;

! Variables in Factor:
!
!   SYMBOL: x
!
!   5 x set
!   x get 2 + .
! 7
!   7 x set
!   x get 2 + .
! 9
!
! get ( name -- value ) and set ( value name -- ) search in
! the namespaces on the namespace stack, in top-down order.
!
! At the bottom of the namespace stack, is the global
! namespace; it is always present.
!
! bind ( namespace quot -- ) executes a quotation with a
! namespace pushed on the namespace stack.

: namestack ( -- ns ) 3 getenv ; inline

: set-namestack ( ns -- ) 3 setenv ; inline

: namespace ( -- namespace )
    #! Push the current namespace.
    namestack car ;

: >n ( namespace -- n:namespace )
    #! Push a namespace on the name stack.
    namestack cons set-namestack ; inline

: n> ( n:namespace -- namespace )
    #! Pop the top of the name stack.
    namestack uncons set-namestack ; inline

: global ( -- g ) 4 getenv ;

: <namespace> ( -- n )
    #! Create a new namespace.
    23 <hashtable> ;

: (get) ( var ns -- value )
    #! Internal word for searching the namestack.
    dup [
        2dup car hash* [
            nip cdr ( found )
        ] [
            cdr (get) ( keep looking )
        ] ?ifte
    ] [
        2drop f
    ] ifte ;

: get ( variable -- value )
    #! Push the value of a variable by searching the namestack
    #! from the top down.
    namestack (get) ;

: set ( value variable -- ) namespace set-hash ;

: on ( var -- ) t swap set ;

: off ( var -- ) f swap set ;

: nest ( variable -- hash )
    #! If the variable is set in the current namespace, return
    #! its value, otherwise set its value to a new namespace.
    dup namespace hash [ ] [ >r <namespace> dup r> set ] ?ifte ;

: change ( var quot -- )
    #! Execute the quotation with the variable value on the
    #! stack. The set the variable to the return value of the
    #! quotation.
    >r dup get r> rot slip set ; inline

: bind ( namespace quot -- )
    #! Execute a quotation with a namespace on the namestack.
    swap >n call n> drop ; inline

: with-scope ( quot -- )
    #! Execute a quotation with a new namespace on the
    #! namestack.
    <namespace> >n call n> drop ; inline

: extend ( namespace code -- namespace )
    #! Used in code like this:
    #! : <subclass>
    #!      <superclass> [
    #!          ....
    #!      ] extend ;
    over >r bind r> ; inline

! Building sequences
SYMBOL: building

: make-seq ( quot sequence -- sequence )
    #! Call , and % from the quotation to append to a sequence.
    [ building set call building get ] with-scope ; inline

: , ( obj -- )
    #! Add to the sequence being built with make-seq.
    ! The behavior where a string can be passed is deprecated;
    ! use % instead!
    building get dup sbuf? [
        over string? [ swap nappend ] [ push ] ifte
    ] [
        push
    ] ifte ;

: unique, ( obj -- )
    #! Add the object to the sequence being built with make-seq
    #! unless an equal object has already been added.
    building get 2dup index -1 = [ push ] [ 2drop ] ifte ;

: % ( seq -- )
    #! Append to the sequence being built with make-seq.
    building get swap nappend ;

: literal, ( word -- )
    #! Append some code that pushes the word on the stack. Used
    #! when building quotations.
    literalize % ;

: make-vector ( quot -- vector )
    100 <vector> make-seq ; inline

: make-list ( quot -- list )
    make-vector >list ; inline

: make-sbuf ( quot -- sbuf )
    100 <sbuf> make-seq ; inline

: make-string ( quot -- string )
    make-sbuf >string ; inline

: make-rstring ( quot -- string )
    make-sbuf <reversed> >string ; inline

! Building hashtables, and computing a transitive closure.
SYMBOL: hash-buffer

: make-hash ( quot -- hash )
    [
        <namespace> hash-buffer set
        call
        hash-buffer get
    ] with-scope ; inline

: hash, ( value key -- ? )
    hash-buffer get [ hash swap ] 2keep set-hash ;

: (closure) ( key hash -- )
    tuck hash dup [
        hash-keys [
            dup dup hash, [
                2drop
            ] [
                swap (closure)
            ] ifte
        ] each-with
    ] [
        2drop
    ] ifte ;

: closure ( key hash -- list )
    [ (closure) ] make-hash hash-keys ;
