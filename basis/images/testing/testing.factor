! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings.binary io.files
io.streams.byte-array kernel quotations sequences tools.test ;
IN: images.testing

:: encode-test ( path image-class -- )
    path binary file-contents 1quotation
    [
        binary <byte-writer> dup [
            path load-image image-class image>stream
        ] with-output-stream B{ } like
    ] unit-test ;
