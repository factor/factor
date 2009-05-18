! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel system accessors namespaces splitting sequences
mason.config bootstrap.image assocs ;
IN: mason.platform

: (platform) ( os cpu -- string )
    { { CHAR: . CHAR: - } } substitute "-" glue ;

: platform ( -- string )
    target-os get target-cpu get (platform) ;

: gnu-make ( -- string )
    target-os get { "freebsd" "openbsd" "netbsd" } member? "gmake" "make" ? ;

: boot-image-arch ( -- string )
    target-os get target-cpu get arch ;

: boot-image-name ( -- string )
    "boot." boot-image-arch ".image" 3append ;
