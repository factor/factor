USING: benchmark.reverse-complement checksums checksums.md5
hex-strings io.files io.files.temp kernel tools.test ;

{ "c071aa7e007a9770b2fb4304f55a17e5" } [
    "resource:extra/benchmark/reverse-complement/reverse-complement-test-in.txt"
    "reverse-complement-test-out.txt" temp-file
    [ reverse-complement ] keep md5 checksum-file bytes>hex-string
] unit-test
