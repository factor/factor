! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators io.pathnames kernel sequences system
vocabs vocabs.platforms ;
IN: io.standard-paths

HOOK: find-native-bundle os ( string -- path )

HOOK: find-in-path* os ( string -- path/f )

HOOK: find-in-applications os ( directories filename -- path )

HOOK: find-in-standard-login-path* os ( string -- path/f )

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

USE-MACOSX: io.standard-paths.macosx
USE-UNIX: io.standard-paths.unix
USE-WINDOWS: io.standard-paths.windows
