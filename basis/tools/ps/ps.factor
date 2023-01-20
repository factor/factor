! Copyright (C) 2012-2013 Doug Coleman, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors prettyprint sequences sorting system vocabs ;
IN: tools.ps

HOOK: ps os ( -- assoc )

"tools.ps." os name>> append require

: ps. ( -- )
    ps sort-keys { "PID" "CMD" } prefix simple-table. ;

MAIN: ps.
