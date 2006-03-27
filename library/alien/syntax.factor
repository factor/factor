! Copyright (C) 2005 Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
IN: !syntax
USING: alien compiler kernel lists math namespaces parser
sequences syntax words ;

: DLL" skip-blank parse-string dlopen swons ; parsing

: ALIEN: scan-word <alien> swons ; parsing

! usage of 'LIBRARY:' and 'FUNCTION:' :
!
!     LIBRARY: gl
!     FUNCTION: void glTranslatef ( GLfloat x, GLfloat y, GLfloat z ) ;
!
! should be the same as doing:
!
!     : glTranslatef ( x y z -- )
!         "void" "gl" "glTranslatef" [ "GLfloat" "GLfloat" "GLfloat" ] alien-invoke ;
!
! other forms:
!
!    FUNCTION: void glEnd ( ) ; -> : glEnd ( -- ) "void" "gl" "glEnd" [ ] alien-invoke ; 
!
! TODO: show returns in the stack effect

: LIBRARY: scan "c-library" set ; parsing

: FUNCTION:
    scan "c-library" get scan string-mode on
    [ string-mode off define-c-word ] [ ] ; parsing

: TYPEDEF:
    #! TYPEDEF: old new
    scan scan typedef ; parsing

: BEGIN-STRUCT: ( -- offset )
    scan "struct-name" set  0 ; parsing

: FIELD: ( offset -- offset )
    scan scan define-field ; parsing

: END-STRUCT ( length -- )
    define-struct-type ; parsing

: C-UNION: ( -- max )
    scan "struct-name" set
    string-mode on [
        string-mode off
        0 [ define-member ] reduce define-struct-type
    ] [ ] ; parsing

: C-ENUM:
    string-mode on [
        string-mode off 0 [
            create-in swap [ unit define-compound ] keep 1+
        ] reduce drop
    ] [ ] ; parsing
