USING: editors editors.gram namespaces tools.test ;
IN: editors.gram.tests

{ { "/Applications/Gram.app/Contents/MacOS/cli" "/tmp/source file.factor:42" } } [
    "/Applications/Gram.app/Contents/MacOS/cli" \ gram-path [
        gram editor-class [
            "/tmp/source file.factor" 42 editor-command
        ] with-variable
    ] with-variable
] unit-test

{ { "C:\\Program Files\\Gram\\gram.exe" "C:\\source file.factor:12" } } [
    "C:\\Program Files\\Gram\\gram.exe" \ gram-path [
        gram editor-class [
            "C:\\source file.factor" 12 editor-command
        ] with-variable
    ] with-variable
] unit-test

{ { "/home/user/.local/bin/gram" "/home/user/source.factor:7" } } [
    "/home/user/.local/bin/gram" \ gram-path [
        gram editor-class [
            "/home/user/source.factor" 7 editor-command
        ] with-variable
    ] with-variable
] unit-test

{ { "/custom/gram" "/tmp/source.factor:1" } } [
    "/custom/gram" \ gram-path [
        gram editor-class [
            "/tmp/source.factor" 0 editor-command
        ] with-variable
    ] with-variable
] unit-test
