USING: environment io kernel sequences tools.test ;
"DISPLAY" os-env empty? [
    "FILE-PICKER-SKIP reason=no-display" print
] [
    "resource:extra/file-picker/linux/fixtures/dialog.factor" run-test-file
] if
