! Copyright (C) 2009 Keith Lazuka.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays images images.loader
images.normalization images.viewer io io.backend io.directories
io.encodings.binary io.files io.pathnames io.streams.byte-array
kernel namespaces random sequences serialize tools.test ;
IN: images.testing

<PRIVATE

: fig-name ( path -- newpath )
    [ parent-directory normalize-path ]
    [ file-stem ".fig" append ] bi
    append-path ;

PRIVATE>

:: with-matching-files ( dirpath extension quot -- )
    dirpath [
        [
            dup file-extension extension = quot [ drop ] if
        ] each
    ] with-directory-files ; inline

: images. ( dirpath extension -- )
    [ image. ] with-matching-files ;

: ls ( dirpath extension -- )
    [ "\"" 1surround print ] with-matching-files ;

: save-as-reference-image ( path -- )
    [ load-image ] [ fig-name ] bi
    binary [ serialize ] with-file-writer ;

: save-all-as-reference-images ( dirpath extension -- )
    [ save-as-reference-image ] with-matching-files ;

: load-reference-image ( path -- image )
    fig-name binary [ deserialize ] with-file-reader ;

:: encode-test ( path image-class -- )
    f verbose-tests? [
        path image-class load-image*
        [ clone normalize-image 1array ] keep
        '[
            binary [
                _ path file-extension image-class image>stream
            ] with-byte-writer image-class load-image* normalize-image
        ] unit-test
    ] with-variable ;

:: decode-test ( path image-class -- )
    f verbose-tests? [
        path image-class load-image* 1array
        [ path load-reference-image ]
        unit-test
    ] with-variable ;

: <rgb-image> ( -- image )
    <image>
        RGB >>component-order
        ubyte-components >>component-type ; inline

: randomize-image ( image -- image )
    dup bytes-per-image random-bytes >>bitmap ;

: image-load-must-fail ( path image-class -- )
    '[ _ _ load-image* ] must-fail ;
