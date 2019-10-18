
USING: kernel namespaces sequences ;

IN: rewrite-closures

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make* ( seq -- seq ) [ dup quotation? [ call ] [ ] if ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-parameters ( seq -- ) reverse [ set ] each ;

: parametric-quot ( parameters quot -- quot )
[ [ swap ] set-parameters [ ] call ] make* ;

: scoped-quot ( quot -- quot ) [ with-scope ] curry ;

: closed-quot ( quot -- quot )
[ namestack >r [ namestack ] set-namestack [ ] call r> set-namestack ] make* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: lambda ( parameters quot -- ) parametric-quot scoped-quot closed-quot ;