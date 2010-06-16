! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel system vocabs.loader ;
IN: time

HOOK: set-time os ( timestamp -- )
HOOK: adjust-time-monotonic os ( timestamp -- seconds )

os {
    { [ dup macosx? ] [ drop "time.macosx" require ] }
    { [ dup windows? ] [ drop "time.windows" require ] }
    { [ dup unix? ] [ drop "time.unix" require ] }
    [ drop ]
} cond
