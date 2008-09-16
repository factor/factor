! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel system accessors namespaces splitting sequences make
mason.config ;
IN: mason.platform

: platform ( -- string )
    target-os get "-" target-cpu get "." split "-" join 3append ;

: gnu-make ( -- string )
    target-os get { "freebsd" "openbsd" "netbsd" } member? "gmake" "make" ? ;

: boot-image-name ( -- string )
    [
        "boot." %
        target-cpu get "ppc" = [ target-os get % "-" % ] when
        target-cpu get %
        ".image" %
    ] "" make ;
