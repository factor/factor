! Copyright (C) 2009 Kobi Lurie, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors fry images.loader
images.processing.rotation kernel literals math sequences
tools.test images.processing.rotation.private ;
IN: images.processing.rotation.tests

: first-row ( seq^2 -- seq ) first ;
: first-col ( seq^2 -- item ) harvest [ first ] map ;
: last-row ( seq^2 -- item ) last ;
: last-col ( seq^2 -- item ) harvest [ last ] map ;
: end-of-first-row ( seq^2 -- item ) first-row last ;
: first-of-first-row ( seq^2 -- item ) first-row first ;
: end-of-last-row ( seq^2 -- item ) last-row last ;
: first-of-last-row ( seq^2 -- item ) last-row first ;

<<

: clone-image ( image -- new-image )
    clone [ clone ] change-bitmap ;

>>

: pasted-image ( -- image )
    "vocab:images/processing/rotation/test-bitmaps/PastedImage.bmp"
    load-image ;

: pasted-image90 ( -- image )
    "vocab:images/processing/rotation/test-bitmaps/PastedImage90.bmp"
    load-image ;

: lake-image ( -- image )
    "vocab:images/processing/rotation/test-bitmaps/lake.bmp"
    load-image image>pixel-rows ;

! XXX: disabling temporarily
USE: system
os linux? [
    [ t ] [ pasted-image dup clone-image 4 [ 90 rotate ] times = ] unit-test
    [ t ] [ pasted-image dup clone-image 2 [ 180 rotate ] times = ] unit-test
    [ t ] [ pasted-image dup clone-image 270 rotate 90 rotate = ] unit-test
    [ t ] [
        pasted-image dup clone-image dup { 90 180 90 } [ rotate drop ] with each =
    ] unit-test

    [ t ] [
        pasted-image 90 rotate
        pasted-image90 = 
    ] unit-test

    [ t ] [
        "vocab:images/processing/rotation/test-bitmaps/small.bmp"
        load-image 90 rotate
        "vocab:images/processing/rotation/test-bitmaps/small-rotated.bmp"
        load-image =
    ] unit-test
] unless

[ t ] [
    lake-image
    [ first-of-first-row ]
    [ 90 (rotate) end-of-first-row ] bi =
] unit-test

[ t ]
[ lake-image [ first-row ] [ 90 (rotate) last-col ] bi = ] unit-test

[ t ]
[ lake-image [ last-col ] [ 90 (rotate) last-row reverse ] bi = ] unit-test

[ t ]
[ lake-image [ last-row ] [ 90 (rotate) first-col ] bi = ] unit-test

[ t ]
[ lake-image [ first-col ] [ 90 (rotate) first-row reverse ] bi = ] unit-test
