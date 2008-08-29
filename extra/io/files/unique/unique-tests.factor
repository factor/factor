USING: io.encodings.ascii sequences strings io io.files accessors
tools.test kernel io.files.unique ;
IN: io.files.unique.tests

[ 123 ] [
    "core" ".test" [
        [
            ascii [
                123 CHAR: a <repetition> >string write
            ] with-file-writer
        ] keep file-info size>>
    ] with-unique-file
] unit-test
