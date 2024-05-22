USING: combinators.smart io io.encodings.utf8 io.files
io.streams.tee kernel tools.test ;

{ t } [
    "resource:LICENSE.txt" utf8 [
        [
            utf8 [
                tee-to-file-writer
                [
                    readln
                    42 read
                    " " read-until
                    read1
                    read-contents
                ] output>array
            ]
            [
                [
                    [
                        readln
                        42 read
                        " " read-until
                        read1
                        read-contents
                    ] output>array
                ] with-file-reader
            ] 2bi =
        ] with-test-file
    ] with-file-reader
] unit-test
