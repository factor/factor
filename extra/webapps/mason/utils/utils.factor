! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs db.tuples furnace.actions
html.forms kernel mason.server mason.server.release sequences
validators xml.syntax ;
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
            { "winnt" "Windows XP, Windows Vista or Windows 7" }
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
