USING: accessors calendar environment io io.launcher io.pathnames
kernel sequences sequences.generalizations system tools.test ;
"resource:extra/file-picker/linux/fixtures/varargs.factor" run-test-file

"DISPLAY" os-env empty? [
    "FILE-PICKER-SKIP reason=no-display" print
] [
    { } [
        vm-path "-i=" "FACTOR_GUI_TEST_IMAGE" os-env image-path or append
        "-no-user-init" "-no-monitors"
        "resource:extra/file-picker/linux/fixtures/dialog-run.factor" absolute-path
        5 narray <process> swap >>command 60 seconds >>timeout try-process
    ] unit-test
] if
