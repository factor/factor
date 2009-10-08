! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: fry images.loader images.normalization io
io.encodings.binary io.files io.pathnames io.streams.byte-array
kernel locals namespaces quotations sequences serialize
tools.test ;
IN: images.testing

<PRIVATE

: fig-name ( path -- newpath )
    [ parent-directory canonicalize-path ]
    [ file-stem ".fig" append ] bi
    append-path ;

PRIVATE>

: save-as-reference-image ( path -- )
    [ load-image ] [ fig-name ] bi
    binary [ serialize ] with-file-writer ;

: load-reference-image ( path -- image )
    fig-name binary [ deserialize ] with-file-reader ;

:: encode-test ( path image-class -- )
    f verbose-tests? [
        path load-image dup clone normalize-image 1quotation swap
        '[
            binary [ _ image-class image>stream ] with-byte-writer
            image-class load-image* normalize-image
        ] unit-test
    ] with-variable ;

: decode-test ( path -- )
    f verbose-tests? [
        [ load-image 1quotation ]
        [ '[ _ load-reference-image ] ] bi
        unit-test
    ] with-variable ;
