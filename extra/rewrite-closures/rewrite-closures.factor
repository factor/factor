
USING: kernel parser math quotations namespaces sequences macros fry ;

IN: rewrite-closures

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [set-parameters] ( seq -- quot ) reverse [ [ set ] curry ] map concat ;

MACRO: set-parameters ( seq -- quot ) [set-parameters] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: parametric-quot ( parameters quot -- quot ) '[ _ set-parameters _ call ] ;

: scoped-quot ( quot -- quot ) '[ _ with-scope ] ;

: closed-quot ( quot -- quot )
  namestack swap '[ namestack [ _ set-namestack @ ] dip set-namestack ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: lambda ( parameters quot -- quot ) parametric-quot scoped-quot closed-quot ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: C[ \ ] [ >quotation ] parse-literal \ closed-quot parsed ; parsing