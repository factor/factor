USING: benchmark.regex-dna io io.files io.encodings.ascii
io.streams.string kernel tools.test splitting ;

{ t } [
    "resource:extra/benchmark/regex-dna/regex-dna-test-in.txt"
    [ regex-dna ] with-string-writer
    "resource:extra/benchmark/regex-dna/regex-dna-test-out.txt"
    ascii file-contents =
] unit-test
