! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs bootstrap.image kernel mason.config
namespaces sequences ;
IN: mason.platform

: (platform) ( os cpu -- string )
    H{ { CHAR: . CHAR: - } } substitute "-" glue ;

: platform ( -- string )
    target-os get name>> target-cpu get name>> (platform)
    target-variant get [ "-" glue ] when* ;

: gnu-make ( -- string )
    "make" ;

: target-arch ( -- arch )
    target-os get target-cpu get arch-name ;

: target-boot-image-name ( -- string )
    target-arch boot-image-name ;
