! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators combinators.short-circuit io.files
io.files.info io.pathnames kernel sequences splitting system unicode
vocabs ;
IN: io.standard-paths

HOOK: find-native-bundle os ( string -- path )

! Backend searches return the complete filename, including any PATHEXT suffix.
HOOK: find-in-path* os ( string -- path/f )

HOOK: find-in-applications os ( directories filename -- path )

HOOK: find-in-standard-login-path* os ( string -- path/f )

HOOK: application-directories os ( -- paths )

<PRIVATE

: executable-file? ( path -- ? )
    { [ file-exists? ] [ directory? not ] [ file-executable? ] } 1&& ;

:: find-path-entry ( names directories test -- path/f )
    directories [| directory |
        names [
            directory swap append-path
            dup test call [ drop f ] unless
        ] map-find drop
    ] map-find drop ; inline

: executable-extensions ( pathext/f -- extensions )
    [ ";" split harvest ] [ { ".COM" ".EXE" ".BAT" ".CMD" } ] if* ;

:: windows-command-names ( command extensions -- names )
    command has-file-extension? [ command 1array ] [
        extensions [ command prepend ] map command prefix
    ] if ;

:: windows-executable-file? ( path extensions -- ? )
    path file-exists? [
        path directory? [ f ] [
            path file-name >lower :> name
            extensions [ >lower name swap tail? ] any?
            [ t ] [ path file-executable? ] if
        ] if
    ] [ f ] if ;

PRIVATE>

M: object find-in-standard-login-path*
    find-in-path* ;

: find-in-path ( string -- path/f )
    [ f ] [ find-in-path* ] if-empty ;

: ?find-in-path ( string -- path/string )
    [ find-in-path ] [ or ] bi ;

: find-in-standard-login-path ( string -- path/f )
    [ f ] [ find-in-standard-login-path* ] if-empty ;

{
    { [ os windows? ] [ "io.standard-paths.windows" ] }
    { [ os unix? ] [ "io.standard-paths.unix" ] }
} cond require

os macos? [ "io.standard-paths.macos" require ] when
