USING: editors editors.athas namespaces tools.test ;
IN: editors.athas.tests

{ { "/Applications/Athas CLI/athas" "/tmp/source file.factor:42" } } [
    "/Applications/Athas CLI/athas" \ athas-path [
        athas editor-class [
            "/tmp/source file.factor" 42 editor-command
        ] with-variable
    ] with-variable
] unit-test

{ { "athas" "/tmp/source.factor:1" } } [
    "athas" \ athas-path [
        athas editor-class [
            "/tmp/source.factor" 0 editor-command
        ] with-variable
    ] with-variable
] unit-test
