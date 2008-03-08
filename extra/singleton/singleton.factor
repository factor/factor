! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.predicate kernel parser quotations words ;
IN: singleton


: SINGLETON:
    \ word
    CREATE-CLASS
    dup [ eq? ] curry define-predicate-class ; parsing
