! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel macros sequences slots words ;
IN: tuples.lib

: reader-slots ( seq -- quot )
    [ slot-spec-reader ] map [ get-slots ] curry ;

MACRO: >tuple< ( class -- )
    "slots" word-prop 1 tail-slice reader-slots ;

MACRO: >tuple*< ( class -- )
    "slots" word-prop
    [ slot-spec-name "*" tail? ] subset
    reader-slots ;


