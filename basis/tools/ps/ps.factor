! Copyright (C) 2012-2013 Doug Coleman, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors prettyprint sequences sorting system vocabs
vocabs.platforms ;
IN: tools.ps

HOOK: ps os ( -- assoc )

USE-OS-SUFFIX: tools.ps

: ps. ( -- )
    ps sort-keys { "PID" "CMD" } prefix simple-table. ;

MAIN: ps.
