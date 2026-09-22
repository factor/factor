USING: help.lint.checks help.markup kernel listener namespaces
prettyprint.config tools.test ;
IN: help.lint.checks.tests

! GitHub issue #2053: examples use defaults, then restore caller settings.
{ 16 } [
    16 number-base [
        [ with-interactive-vocabs ] vocabs-quot [
            { $example "USING: prettyprint ;" "123 ." "123" } check-example
            { $example
                "USING: namespaces prettyprint prettyprint.config ;"
                "16 number-base [ 123 . ] with-variable"
                "0x7b"
            } check-example
        ] with-variable
        number-base get
    ] with-variable
] unit-test
