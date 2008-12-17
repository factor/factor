! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel words ;
IN: constants

: CONSTANT:
    CREATE scan-object [ ] curry (( -- value ))
    define-inline ; parsing
