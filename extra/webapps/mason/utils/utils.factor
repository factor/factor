! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs db.tuples furnace.actions
furnace.utilities html.forms kernel namespaces sequences
validators xml.syntax urls mason.config
webapps.mason.version.data webapps.mason.backend ;
IN: webapps.mason.utils

: link ( url label -- xml )
    [XML <a href=<->><-></a> XML] ;

: validate-os/cpu ( -- )
    {
        { "os" [ v-one-line ] }
        { "cpu" [ v-one-line ] }
    } validate-params ;

: current-builder ( -- builder )
    builder new "os" value >>os "cpu" value >>cpu select-tuple ;

: current-release ( -- builder )
    release new "os" value >>os "cpu" value >>cpu select-tuple ;

: requirements ( builder -- xml )
    [
        os>> {
            { "windows" "Windows XP, Windows Vista or Windows 7" }
            { "macosx" "Mac OS X 10.5 Leopard" }
            { "linux" "Ubuntu Linux 9.04 (other distributions may also work)" }
            { "freebsd" "FreeBSD 7.1" }
            { "netbsd" "NetBSD 5.0" }
            { "openbsd" "OpenBSD 4.5" }
        } at
    ] [
        dup cpu>> "x86.32" = [
            os>> "macosx" =
            f "Intel Pentium 4, Core Duo, or other x86 chip with SSE2 support. Note that 32-bit Athlon XP processors do not support SSE2."
            ?
        ] [ drop f ] if
    ] bi
    2array sift [ [XML <li><-></li> XML] ] map [XML <ul><-></ul> XML] ;

: download-url ( string -- string' )
    "http://downloads.factorcode.org/" prepend ;

: package-url ( builder -- url )
    [ URL" http://builds.factorcode.org/package" ] dip
    [ os>> "os" set-query-param ]
    [ cpu>> "cpu" set-query-param ] bi
    adjust-url ;

: release-url ( builder -- url )
    [ URL" http://builds.factorcode.org/release" ] dip
    [ os>> "os" set-query-param ]
    [ cpu>> "cpu" set-query-param ] bi
    adjust-url ;

: validate-secret ( -- )
    { { "secret" [ v-one-line ] } } validate-params
    "secret" value status-secret get =
    [ validation-failed ] unless ;
