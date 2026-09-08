USING: arrays command-line command-line.private io.encodings.utf8 io.files
io.pathnames kernel namespaces sequences tools.test vocabs.loader ;

! A UTF-8 BOM must not turn the first absolute root into a relative path.
{ t } [
    [
        [ "resource:work" absolute-path "\r\n\r\n" append ] dip
        [ utf8-bom set-file-contents ] keep
        V{ } clone vocab-roots [
            load-vocab-roots-file vocab-roots get
            "resource:work" absolute-path 1array sequence=
        ] with-variable
    ] with-test-file
] unit-test

{ t } [
    [
        [ "resource:work" absolute-path "\n" append ] dip
        [ utf8 set-file-contents ] keep
        V{ } clone vocab-roots [
            load-vocab-roots-file vocab-roots get
            "resource:work" absolute-path 1array sequence=
        ] with-variable
    ] with-test-file
] unit-test

{ f { "a" "b" "c" } } [
    { "factor" "-run=test-voc" "a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ f { "-a" "b" "c" } } [
    { "factor" "-run=test-voc" "-a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ f { "a" "-b" "c" } } [
    { "factor" "-run=test-voc" "a" "-b" "c" } parse-command-line
    script get command-line get
] unit-test

{ f { "a" "b" "-c" } } [
    { "factor" "-run=test-voc" "a" "b" "-c" } parse-command-line
    script get command-line get
] unit-test

{ "a" { "b" "c" } } [
    { "factor" "a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ "a" { "b" "c" } } [
    { "factor" "-foo" "a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ "a:b:c" } [ { "factor" "-roots=a:b:c" } parse-command-line
    "roots" get-global
] unit-test

{ { "arg1" "arg2" } t "12" f } [
    { "-foo" "-bar=12" "-no-baz" "arg1" "arg2" }
    command-line-options
    "foo" get "bar" get "baz" get
] unit-test
