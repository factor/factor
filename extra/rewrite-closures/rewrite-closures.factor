
USING: kernel parser math quotations namespaces sequences namespaces.lib 
       inference.transforms ;

IN: rewrite-closures

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : set-parameters ( seq -- ) reverse [ set ] each ;

: [set-parameters] ( seq -- quot ) [ [ set ] curry ] map concat ;

: set-parameters ( seq -- ) [set-parameters] call ;

\ set-parameters [ [set-parameters] ] 1 define-transform

: parametric-quot ( parameters quot -- quot )
[ [ swap ] set-parameters [ ] call ] make* ;

: scoped-quot ( quot -- quot ) [ with-scope ] curry ;

: closed-quot ( quot -- quot )
[ namestack >r [ namestack ] set-namestack [ ] call r> set-namestack ] make* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: lambda ( parameters quot -- ) parametric-quot scoped-quot closed-quot ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: C[ \ ] [ >quotation ] parse-literal \ closed-quot parsed ; parsing