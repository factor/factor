USING: accessors arrays assocs io kernel math namespaces sequences
    system tools.test tools.test.private vocabs.loader ;
IN: qemu.runtime-check

! Exact vocabularies avoid recursively sweeping expensive SIMD fuzz suites.
CONSTANT: checks {
    "kernel" "math" "math.functions" "sequences" "arrays" "assocs"
    "compiler" "threads" "io.files" "io.files.info" "io.files.unique"
    "alien.c-types" "alien.syntax" "alien.libraries"
    "alien.libraries.finder.linux"
}

: main ( -- )
    f long-unit-tests-enabled? set-global
    checks [ dup "QEMU_CHECK " write print flush dup require test-vocab ] each
    test-failures get dup length "QEMU_FAILURES " write .
    empty? [ 0 ] [ 1 ] if exit ;

MAIN: main
