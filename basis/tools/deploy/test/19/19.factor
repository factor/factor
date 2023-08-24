! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: io io.files io.encodings.ascii ;
IN: tools.deploy.test.19

: main ( -- )
    ! make sure to test vocab: paths. This file is a copy of Factors
    ! LICENSE.txt.
    "vocab:local-license.txt" ascii file-contents write ;

MAIN: main
