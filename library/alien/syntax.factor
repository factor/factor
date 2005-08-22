! Copyright (C) 2005 Alex Chapman.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: compiler kernel lists namespaces parser sequences words ;

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
! TODO: show returns in the stack effect

: LIBRARY: scan "c-library" set ; parsing

: parse-arglist ( lst -- types stack effect )
    2 swap group flip 2unseq [
        " " % [ "," ?tail drop % " " % ] each "-- " %
    ] make-string ;

: (define-c-word) ( type lib func types stack-effect -- )
    >r over create-in >r 
    [ alien-invoke ] cons cons cons cons r> swap define-compound
    word r> "stack-effect" set-word-prop ;

: define-c-word ( type lib func function-args -- )
    [ "()" subseq? not ] subset parse-arglist (define-c-word) ;

: FUNCTION:
    scan "c-library" get scan string-mode on
    [ string-mode off define-c-word ] [ ] ; parsing

: TYPEDEF:
    #! TYPEDEF: old new
    scan scan typedef ; parsing

: DLL" skip-blank parse-string dlopen swons ; parsing
