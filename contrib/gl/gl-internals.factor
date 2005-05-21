IN: gl-internals
USING: alien kernel sequences stdio math test parser namespaces lists strings words compiler ;

! usage of 'LIBRARY:' and 'FUNCTION:' :
!
!     LIBRARY: gl
!     FUNCTION: void glTranslatef ( GLfloat x, GLfloat y, GLfloat z ) ;
!
! should be the same as doing:
!
!     : glTranslatef ( x y z -- )
!         "void" "gl" "glTranslatef" [ "GLfloat" "GLfloat" "GLfloat" ] alien-invoke ;
!     \ glTranslatef compile
!
! other forms:
!
!    FUNCTION: void glEnd ( ) ; -> : glEnd ( -- ) "void" "gl" "glEnd" [ ] alien-invoke ; 
!
!    FUNCTION: TODO: something with a return...

: LIBRARY: scan "c-library" set ; parsing

: compile-function-call ( type lib func types stack-effect -- )
    >r over create-in >r 
    [ alien-invoke ] cons cons cons cons r> swap define-compound
    word r> "stack-effect" set-word-prop
    word compile ;

: (list-split) ( list1 list2 quot -- list1 list2 )
    dup >r >r dup
      [ unswons dup r> call
        [ r> 2drop ]
        [ rot cons swap r> (list-split) ] ifte ]
      [ r> r> 2drop ] ifte ;

: list-split ( list quot -- list1 list2 )
    #! split the list at the first element where 'elem quot call' is t, removing that element.
    #! if no elements return true, return 'list [ ]'
    [ ] -rot (list-split) >r reverse r> ;

: unpair ( list -- list1 list2 )
    [ uncons uncons unpair rot swons >r cons r> ]
    [ f f ] ifte* ;

: remove-trailing-char ( str ch -- str )
    >r dup length 1 - swap 2dup nth r> =
      [ head ] 
      [ nip ] ifte ;

: join-stack-effect ( lst -- str )
    [ CHAR: , remove-trailing-char " " append ] map " " swons concat ;

: parse-stack-effect ( lst -- types stack-effect )
    [ "--" = ] list-split >r unpair r> "--" swons append join-stack-effect ;

: (function) ( type lib func function-args -- )
    unswons drop reverse unswons drop reverse
    parse-stack-effect compile-function-call ;

: FUNCTION:
    scan "c-library" get scan string-mode on
      [ string-mode off (function) ] [ ] ; parsing
