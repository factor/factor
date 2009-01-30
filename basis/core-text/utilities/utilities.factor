! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words parser alien alien.c-types kernel fry ;
IN: core-text.utilities

: C-GLOBAL:
    CREATE-WORD
    dup name>> '[ _ f dlsym *void* ]
    (( -- value )) define-declared ; parsing
