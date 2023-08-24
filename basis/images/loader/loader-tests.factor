USING: accessors continuations glib.ffi images.loader
io.files.temp kernel layouts sequences system tools.test ;
IN: images.loader.tests

: open-png-image ( -- image )
    "vocab:images/testing/png/basi0g01.png" load-image ;

: convert-to ( image format -- image' )
    "foo." prepend temp-file [ save-graphic-image ] keep load-image ;

os windows? [
    ! Windows can handle these three formats fine.
    { { t t t } } [
        { "png" "tif" "gif" } [
            open-png-image [ swap convert-to ] keep =
        ] map
    ] unit-test
] when

os linux? [
    ! GTK only these two.
    { { t t } } [
        { "png" "bmp" } [
            open-png-image [ swap convert-to ] keep =
        ] map
    ] unit-test

    ! It either can save to gif or throw a g-error if the gif encoder
    ! is excluded.
    { t } [
        [ open-png-image dup "gif" convert-to = ] [ g-error? ] recover
    ] unit-test
] when

os { linux windows } member? [
    { t } [
        [
            open-png-image
            "hai!" save-graphic-image
        ] [ unknown-image-extension? ] recover
    ] unit-test

    ! Windows 32 can't save .bmp-files for unknown reason. It can load
    ! them though.
    64-bit? [
        { t } [
            open-png-image dup "bmp" convert-to =
        ] unit-test
    ] when

    { t } [
        "vocab:images/testing/bmp/rgb_8bit.bmp" load-image dup
        "foo.png" temp-file [ save-graphic-image ] [ load-image ] bi =
    ] unit-test
] when

! On Windows, this image didn't load due to a funny problem with a
! callback triggering a gc causing an important pointer to be
! moved. Only happened with tiff images too.
{ { 1024 768 } } [
    "vocab:gpu/demos/bunny/loading.tiff" load-image dim>>
] unit-test
