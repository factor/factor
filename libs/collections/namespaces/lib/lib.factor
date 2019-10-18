
USING: kernel kernel-internals namespaces sequences hashtables.lib ;

IN: namespaces.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: save-namestack ( quot -- ) namestack >r call r> set-namestack ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make* ( seq -- seq ) [ dup quotation? [ call ] [ ] if ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set* ( val var -- ) namestack* set-hash-stack ;