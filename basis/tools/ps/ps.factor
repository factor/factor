! Copyright (C) 2012-2013 Doug Coleman, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators prettyprint system vocabs ;
IN: tools.ps

HOOK: ps os ( -- assoc )

{
    { [ os macosx?  ] [ "tools.ps.macosx"  ] }
    { [ os linux?   ] [ "tools.ps.linux"   ] }
    { [ os windows? ] [ "tools.ps.windows" ] }
} cond require

: ps. ( -- )
    ps simple-table. ;
