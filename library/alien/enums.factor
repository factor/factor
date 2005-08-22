! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: kernel lists math parser words ;

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
    dup CREATE swap unit define-compound 1 + ; parsing

: END-ENUM
    drop ; parsing
