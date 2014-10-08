USING: continuations images.loader io.files.temp kernel sequences system
tools.test ;
IN: images.loader.tests

CONSTANT: basi0g01.png "vocab:images/testing/png/basi0g01.png"

os { linux windows } member? [

    { { t t t } } [
        basi0g01.png load-image dup
        { "png" "gif" "tif" } [
            "foo." prepend temp-file [ save-graphic-image ] keep
        ] with map
        [ load-image = ] with map
    ] unit-test

    { t } [
        [
            basi0g01.png load-image
            "hai!" save-graphic-image
        ] [ unknown-image-extension? ] recover
    ] unit-test

    ! Windows can't save .bmp-files for unknown reason. It can load
    ! them though.
    os windows? [
        [
            basi0g01.png load-image "foo.bmp" temp-file save-graphic-image
        ] [ unknown-image-extension? ] must-fail-with
    ] [
        { t } [
            basi0g01.png load-image dup
            "foo.bmp" temp-file [ save-graphic-image ] [ load-image ] bi =
        ] unit-test
    ] if

    { t } [
        "vocab:images/testing/bmp/rgb_8bit.bmp" load-image dup
        "foo.png" temp-file [ save-graphic-image ] [ load-image ] bi =
    ] unit-test

] when
