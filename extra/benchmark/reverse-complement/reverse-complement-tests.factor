IN: benchmark.reverse-complement.tests
USING: tools.test benchmark.reverse-complement
checksums checksums.md5
io.files kernel ;

[ "c071aa7e007a9770b2fb4304f55a17e5" ] [
    "resource:extra/benchmark/reverse-complement/reverse-complement-test-in.txt"
    "resource:extra/benchmark/reverse-complement/reverse-complement-test-out.txt"
    reverse-complement

    "resource:extra/benchmark/reverse-complement/reverse-complement-test-out.txt"
    md5 checksum-file hex-string
] unit-test
