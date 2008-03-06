! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel parser quotations tuples words ;
IN: singleton

: SINGLETON:
    CREATE-CLASS
    dup { } define-tuple-class
    dup construct-empty 1quotation define ; parsing
