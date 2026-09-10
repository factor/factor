USING: accessors calendar environment io io.launcher io.pathnames
kernel sequences sequences.generalizations system tools.test ;
"resource:extra/file-picker/linux/fixtures/varargs.factor" run-test-file

"DISPLAY" os-env empty? "WAYLAND_DISPLAY" os-env empty? and [
    "FILE-PICKER-SKIP reason=no-display" print
] [
    { } [
        ! Saved load-all images need a clean image in FACTOR_GUI_TEST_IMAGE.
        vm-path "-i=" "FACTOR_GUI_TEST_IMAGE" os-env image-path or append
        "-no-user-init" "-no-monitors"
        "-resource-path=" "" resource-path append
        "resource:extra/file-picker/linux/fixtures/dialog-run.factor" absolute-path
        6 narray <process> swap >>command 60 seconds >>timeout try-process
    ] unit-test
] if
