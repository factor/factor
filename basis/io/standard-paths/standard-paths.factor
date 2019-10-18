! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators io.pathnames kernel sequences system
vocabs ;
IN: io.standard-paths

HOOK: find-native-bundle os ( string -- path )

HOOK: find-in-path* os ( string -- path/f )

HOOK: find-in-applications os ( directories filename -- path )

: find-in-path ( string -- path/f )
    [ f ]
    [ [ find-in-path* ] keep over [ append-path ] [ 2drop f ] if ]
    if-empty ;

os {
    { [ dup macosx? ] [ drop "io.standard-paths.macosx" require ] }
    { [ dup unix? ] [ drop "io.standard-paths.unix" require ] }
    { [ dup windows? ] [ drop "io.standard-paths.windows" require ] }
} cond

