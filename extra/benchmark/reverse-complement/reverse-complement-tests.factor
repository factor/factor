IN: benchmark.reverse-complement.tests
USING: tools.test benchmark.reverse-complement crypto.md5
io.files kernel ;

[ "c071aa7e007a9770b2fb4304f55a17e5" ] [
    "extra/benchmark/reverse-complement/reverse-complement-test-in.txt"
    "extra/benchmark/reverse-complement/reverse-complement-test-out.txt"
    [ resource-path ] bi@
    reverse-complement

    "extra/benchmark/reverse-complement/reverse-complement-test-out.txt"
    resource-path file>md5str
] unit-test
