! Copyright (C) 2005 Alex Chapman.
! See http://factor.sf.net/license.txt for BSD license.
IN: !syntax
USING: alien compiler kernel lists math namespaces parser
sequences syntax words ;

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

: BEGIN-UNION: ( -- max )
    scan "struct-name" set  0 ; parsing

: MEMBER: ( max -- max )
    scan define-member ; parsing

: END-UNION ( max -- )
    define-struct-type ; parsing

: BEGIN-ENUM:
    #! C-style enumerations. Their use is not encouraged unless
    #! it is for C library interfaces. Used like this:
    #!
    #! BEGIN-ENUM 0
    #!     ENUM: x
    #!     ENUM: y
    #!     ENUM: z
    #! END-ENUM
    #!
    #! This is the same as : x 0 ; : y 1 ; : z 2 ;.
    scan string>number ; parsing

: ENUM:
    dup CREATE swap unit define-compound 1+ ; parsing

: END-ENUM
    drop ; parsing
