! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: fry images.loader io io.encodings.binary io.files
io.pathnames io.streams.byte-array kernel locals quotations
sequences tools.test ;
IN: images.testing

:: encode-test ( path image-class -- )
    path binary file-contents 1quotation
    [
        binary <byte-writer> dup [
            path load-image image-class image>stream
        ] with-output-stream B{ } like
    ] unit-test ;

<PRIVATE

: pam-name ( path -- newpath )
    [ parent-directory canonicalize-path ]
    [ file-stem ".pam" append ] bi
    append-path ;

: save-as-reference-image ( path -- )
    [ load-image ] [ pam-name ] bi save-graphic-image ;

PRIVATE>

: decode-test ( path -- )
    [ load-image 1quotation ] [ '[ _ pam-name load-image ] ] bi
    unit-test ;
