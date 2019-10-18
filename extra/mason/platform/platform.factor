! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel system accessors namespaces splitting sequences
mason.config bootstrap.image assocs ;
IN: mason.platform

: (platform) ( os cpu -- string )
    H{ { CHAR: . CHAR: - } } substitute "-" glue ;

: platform ( -- string )
    target-os get name>> target-cpu get name>> (platform)
    target-variant get [ "-" glue ] when* ;

: gnu-make ( -- string )
    "make" ;

: boot-image-arch ( -- string )
    target-os get target-cpu get arch ;

: boot-image-name ( -- string )
    boot-image-arch "boot." ".image" surround ;
