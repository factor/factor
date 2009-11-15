! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators system vocabs.loader ;
IN: monotonic-clock

HOOK: monotonic-count os ( -- n )

{
    { [ os unix? ] [ "monotonic-clock.unix" ] }
    { [ os windows? ] [ "monotonic-clock.windows" ] }
    { [ os macosx? ] [ "monotonic-clock.unix.macosx" ] }
} cond require
