! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files io.encodings.ascii ;
IN: tools.deploy.test.19

: main ( -- )
    ! make sure to test vocab: urls
    "vocab:LICENSE.txt" ascii file-contents write ;

MAIN: main
