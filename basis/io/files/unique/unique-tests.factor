USING: accessors continuations io.directories io.encodings.ascii
io.encodings.utf8 io.files io.files.info io.files.temp
io.files.unique io.pathnames kernel namespaces sequences strings
tools.test unicode ;

{ 123 } [
    [
        "core" ".test" [
            [ [ 123 CHAR: a <string> ] dip ascii set-file-contents ]
            [ file-info size>> ] bi
        ] cleanup-unique-file
    ] with-temp-directory
] unit-test

{ t } [
    [
        current-directory get
        [ [ "FAILDOG" throw ] cleanup-unique-directory ] ignore-errors
        current-directory get =
    ] with-temp-directory
] unit-test

{ t } [
    [
        [
            "asdf" "" unique-file drop
            "asdf2" "" unique-file drop
            "." directory-files length 2 =
        ] cleanup-unique-directory
    ] with-temp-directory
] unit-test

{ t } [
    [
        [ ] with-unique-directory
        [ file-exists? ] [ delete-tree ] bi
    ] with-temp-directory
] unit-test

{ t } [
    [
        [
            "asdf" "" unique-file drop
            "asdf" "" unique-file drop
            "." directory-files length 2 =
        ] with-unique-directory drop
    ] with-temp-directory
] unit-test

{ 29 } [
    [
        "unique-files-" { "-test.0" "-test.1" } [
            [ file-name ] map first2 mismatch
        ] cleanup-unique-files
    ] with-temp-directory
] unit-test

{ "hello" } [
    [
        "hello" "foo" utf8 set-file-contents [
            "foo" [
                "world" swap utf8 set-file-contents
                "Noooooooo..." throw
            ] safe-overwrite-file
        ] ignore-errors
        "foo" utf8 file-contents
    ] with-temp-directory
] unit-test

{ "world" } [
    [
        "hello" "foo" utf8 set-file-contents
        "foo" [
            "world" swap utf8 set-file-contents
        ] safe-overwrite-file
        "foo" utf8 file-contents
    ] with-temp-directory
] unit-test

{ "hello" } [
    [
        "hello" "foo" utf8 set-file-contents [
            "foo" [
                utf8 [ >upper ] change-file-contents
                "Noooooooo..." throw
            ] safe-replace-file
        ] ignore-errors
        "foo" utf8 file-contents
    ] with-temp-directory
] unit-test

{ "HELLO" } [
    [
        "hello" "foo" utf8 set-file-contents
        "foo" [
            utf8 [ >upper ] change-file-contents
        ] safe-replace-file
        "foo" utf8 file-contents
    ] with-temp-directory
] unit-test
