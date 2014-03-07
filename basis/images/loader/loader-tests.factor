USING: continuations images.loader io.files.temp kernel system tools.test ;
IN: images.loader.tests

os linux? [
    [ t ] [
        "vocab:images/testing/png/basi0g01.png" load-image dup
        "foo.bmp" temp-file [ save-graphic-image ] [ load-image ] bi =
    ] unit-test

    [ t ] [
        [
            "vocab:images/testing/png/basi0g01.png" load-image
            "hai!" save-graphic-image
        ] [ unknown-image-extension? ] recover
    ] unit-test
] when
