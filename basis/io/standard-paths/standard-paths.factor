! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators io.pathnames kernel sequences system
vocabs ;
IN: io.standard-paths

HOOK: find-native-bundle os ( string -- path )

HOOK: find-in-path* os ( string -- path/f )

HOOK: find-in-applications os ( directories filename -- path )

HOOK: find-in-standard-login-path* os ( string -- path/f )

HOOK: application-directories os ( -- paths )

M: object find-in-standard-login-path*
    find-in-path* ;

: find-in-path ( string -- path/f )
    [ f ] [
        [ find-in-path* ] keep over
        [ append-path ] [ 2drop f ] if
    ] if-empty ;

: ?find-in-path ( string -- path/string )
    [ find-in-path ] [ or ] bi ;

: find-in-standard-login-path ( string -- path/f )
    [ f ] [
        [ find-in-standard-login-path* ] keep over
        [ append-path ] [ 2drop f ] if
    ] if-empty ;

{
    { [ os windows? ] [ "io.standard-paths.windows" ] }
    { [ os unix? ] [ "io.standard-paths.unix" ] }
} cond require

os macos? [ "io.standard-paths.macos" require ] when
