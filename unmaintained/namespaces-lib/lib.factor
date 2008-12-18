USING: kernel namespaces namespaces.private quotations sequences
       assocs.lib math.parser math generalizations locals mirrors
       macros ;

IN: namespaces.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: save-namestack ( quot -- ) namestack slip set-namestack ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make* ( seq -- seq ) [ dup quotation? [ call ] [ ] if ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set* ( val var -- ) namestack* set-assoc-stack ;

: make-object ( quot class -- object )
    new [ <mirror> swap bind ] keep ; inline

: with-object ( object quot -- )
    [ <mirror> ] dip bind ; inline
