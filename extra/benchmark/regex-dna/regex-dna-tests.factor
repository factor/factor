USING: benchmark.regex-dna io.encodings.ascii io.files
io.streams.string kernel sequences tools.test ;

{ t } [
    "resource:extra/benchmark/regex-dna/regex-dna-test-in.txt"
    [ regex-dna ] with-string-writer
    "resource:extra/benchmark/regex-dna/regex-dna-test-out.txt"
    ! Ensure the line endings don't change on Windows
    ! when checking out with git.
    ascii file-lines [ "\n" append ] map concat =
] unit-test
