! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel macros sequences slots words classes.tuple
quotations combinators ;
IN: classes.tuple.lib

: reader-slots ( seq -- quot )
    [ slot-spec-reader 1quotation ] map [ cleave ] curry ;

MACRO: >tuple< ( class -- )
    all-slots rest-slice reader-slots ;

MACRO: >tuple*< ( class -- )
    all-slots
    [ slot-spec-name "*" tail? ] filter
    reader-slots ;


