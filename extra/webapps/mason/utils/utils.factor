! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs db.tuples furnace.actions
furnace.utilities html.forms kernel mason.config namespaces
sequences urls validators webapps.mason.backend
webapps.mason.version.data xml.syntax ;
IN: webapps.mason.utils

: link ( url label -- xml )
    [XML <a href=<->><-></a> XML] ;

: validate-os/cpu ( -- )
    {
        { "os" [ v-one-line ] }
        { "cpu" [ v-one-line ] }
    } validate-params ;

: current-builder ( -- builder/f )
    builder new "os" value >>os "cpu" value >>cpu select-tuple ;

: current-release ( -- builder/f )
    release new "os" value >>os "cpu" value >>cpu select-tuple ;

: requirements ( builder -- xml )
    [
        os>> {
            { "windows" "Windows XP, Windows Vista or Windows 7" }
            { "macosx" "Mac OS X 10.5 Leopard" }
            { "linux" "Ubuntu Linux 9.04 (other distributions may also work)" }
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

: platform-url ( url builder -- url )
    [ os>> "os" set-query-param ]
    [ cpu>> "cpu" set-query-param ] bi
    adjust-url ;

: package-url ( builder -- url )
    [ URL" http://builds.factorcode.org/package" clone ] dip
    platform-url ;

: report-url ( builder -- url )
    [ URL" http://builds.factorcode.org/report" clone ] dip
    platform-url ;

: release-url ( builder -- url )
    [ URL" http://builds.factorcode.org/release" clone ] dip
    platform-url ;

: validate-secret ( -- )
    { { "secret" [ v-one-line ] } } validate-params
    "secret" value status-secret get =
    [ validation-failed ] unless ;
