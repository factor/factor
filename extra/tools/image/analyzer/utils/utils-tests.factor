USING: io io.encodings.binary io.streams.byte-array
tools.image.analyzer.utils tools.test ;
IN: tools.image.analyzer.utils.tests

{
    B{ 5 6 7 8 }
    B{ 1 2 3 4 }
} [
    B{ 1 2 3 4 5 6 7 8 } binary <byte-reader> <backwards-reader> [
        4 read 4 read
    ] with-input-stream
] unit-test
