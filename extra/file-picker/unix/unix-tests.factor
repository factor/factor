USING: accessors calendar environment file-picker generic io io.encodings.utf8 io.launcher io.pathnames
kernel sequences sequences.generalizations system tools.test ;
"resource:extra/file-picker/unix/fixtures/varargs.factor" run-test-file

! Verify shared dispatch without opening a native dialog.
{ t } [
    freebsd \ open-file-dialog method-for-class
    unix \ open-file-dialog method-for-class eq?
] unit-test

{ t } [
    freebsd \ save-file-dialog method-for-class
    unix \ save-file-dialog method-for-class eq?
] unit-test

"DISPLAY" os-env empty? "WAYLAND_DISPLAY" os-env empty? and [
    "FILE-PICKER-SKIP reason=no-display" print
] [
    { } [
        ! Saved load-all images need a clean image in FACTOR_GUI_TEST_IMAGE.
        vm-path "-i=" "FACTOR_GUI_TEST_IMAGE" os-env image-path or append
        "-no-user-init" "-no-monitors"
        "-resource-path=" "" resource-path append
        "resource:extra/file-picker/unix/fixtures/dialog-run.factor" absolute-path
        6 narray <process> swap >>command 60 seconds >>timeout
        +closed+ >>stdin +stdout+ >>stderr
        utf8 [ read-contents ] with-process-reader*
        0 = [ drop write ] [ output-process-error ] if
    ] unit-test
] if
