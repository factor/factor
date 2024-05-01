USING: io io.encodings.utf8 io.files io.streams.tee kernel
tools.test ;

{ t } [
    "resource:LICENSE.txt" utf8 [
        [
            utf8
            [ tee-to-file-writer read-contents ]
            [ file-contents ] 2bi =
        ] with-test-file
    ] with-file-reader
] unit-test
