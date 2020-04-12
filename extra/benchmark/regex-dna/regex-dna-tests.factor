USING: benchmark.regex-dna io io.files io.encodings.ascii
io.streams.string kernel tools.test splitting ;

{ t } [
    "resource:extra/benchmark/regex-dna/regex-dna-test-in.txt"
    [ regex-dna ] with-string-writer
    "resource:extra/benchmark/regex-dna/regex-dna-test-out.txt"
    ! Ensure the line endings don't change on Windows
    ! when checking out with git.
    ascii file-lines "\n" join =
] unit-test
