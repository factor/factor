USING: kernel tools.test files.unique ;
IN: unix.stat.tests

[ 123 ] [
    123 CHAR: a <repetition> [
        write
    ] with-unique-file file-size>>
] unit-test
