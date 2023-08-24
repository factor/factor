! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators system vocabs ;
IN: time

HOOK: set-system-time os ( timestamp -- )
HOOK: adjust-time-monotonic os ( timestamp -- seconds )

{
    { [ os windows? ] [ "time.windows" ] }
    { [ os macosx? ] [ "time.macosx" ] }
    { [ os unix? ] [ "time.unix" ] }
} cond require
