! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: namespaces
USING: hashtables kernel kernel-internals lists vectors math ;

! Other languages have classes, objects, variables, etc.
! Factor has similar concepts.
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
    namestack car ; inline

: >n ( namespace -- n:namespace )
    #! Push a namespace on the namespace stack.
    >hashtable namestack cons set-namestack ; inline

: n> ( n:namespace -- namespace )
    #! Pop the top of the namespace stack.
    namestack uncons set-namestack ; inline

: global ( -- g ) 4 getenv ;
: set-global ( g -- ) 4 setenv ;

: init-namespaces ( -- )
    global >n ;

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
: put ( variable value -- ) swap set ;

: nest ( variable -- hash )
    #! If the variable is set in the current namespace, return
    #! its value, otherwise set its value to a new namespace.
    dup namespace hash [ >r <namespace> dup r> set ] ?unless ;

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

: extend ( object code -- object )
    #! Used in code like this:
    #! : <subclass>
    #!      <superclass> [
    #!          ....
    #!      ] extend ;
    over >r bind r> ; inline

: on ( var -- ) t put ;
: off ( var -- ) f put ;
: inc ( var -- ) [ 1 + ] change ;
: dec ( var -- ) [ 1 - ] change ;

: cons@ ( x var -- )
    #! Prepend x to the list stored in var.
    [ cons ] change ;

: unique@ ( elem var -- )
    #! Prepend an element to the proper list stored in a
    #! variable if it is not already contained in the list.
    [ unique ] change ;

SYMBOL: list-buffer

: make-rlist ( quot -- list )
    #! Call a quotation. The quotation can call , to prepend
    #! objects to the list that is returned when the quotation
    #! is done.
    [ list-buffer off call list-buffer get ] with-scope ;
    inline

: make-list ( quot -- list )
    #! Return a list whose entries are in the same order that ,
    #! was called.
    make-rlist reverse ; inline

: make-vector ( quot -- list )
    #! Return a vector whose entries are in the same order that
    #! , was called.
    make-list list>vector ; inline

: , ( obj -- )
    #! Append an object to the currently constructing list.
    list-buffer cons@ ;

: unique, ( obj -- )
    #! Append an object to the currently constructing list, only
    #! if the object does not already occur in the list.
    list-buffer unique@ ;

: append, ( list -- )
    [ , ] each ;
