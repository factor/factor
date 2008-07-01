
USING: kernel parser math quotations namespaces sequences namespaces.lib 
       inference.transforms fry ;

IN: rewrite-closures

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : set-parameters ( seq -- ) reverse [ set ] each ;

: [set-parameters] ( seq -- quot ) [ [ set ] curry ] map concat ;

: set-parameters ( seq -- ) [set-parameters] call ;

\ set-parameters [ [set-parameters] ] 1 define-transform

! : parametric-quot ( parameters quot -- quot )
! [ [ swap ] set-parameters [ ] call ] make* ;

: parametric-quot ( parameters quot -- quot ) '[ , set-parameters , call ] ;

: scoped-quot ( quot -- quot ) [ with-scope ] curry ;

! : closed-quot ( quot -- quot )
! [ namestack >r [ namestack ] set-namestack [ ] call r> set-namestack ] make* ;

: closed-quot ( quot -- quot )
  namestack swap '[ namestack [ , set-namestack @ ] dip set-namestack ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: lambda ( parameters quot -- quot ) parametric-quot scoped-quot closed-quot ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: C[ \ ] [ >quotation ] parse-literal \ closed-quot parsed ; parsing