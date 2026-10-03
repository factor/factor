! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
! Shared acceptance stages for misc/riscv/test-qemu.sh.
USING: accessors arrays assocs combinators command-line compiler.errors continuations
db.postgresql debugger environment io io.encodings.utf8 io.files io.launcher
io.sockets.secure.openssl io.streams.string kernel locals math math.parser
memory namespaces parser.notes prettyprint redis sequences system tools.disassembler
tools.test vectors vocabs vocabs.hierarchy vocabs.loader ;
IN: riscv.qemu.validation

: configure-services ( -- )
    <postgresql-db>
        "PGHOST" os-env [ >>host ] when*
        "PGPORT" os-env [ >>port ] when*
        "PGUSER" os-env [ >>username ] when*
        "PGPASSWORD" os-env [ >>password ] when*
    \ postgresql-db set-global
    "REDIS_HOST" os-env [ redis-host set-global ] when*
    "REDIS_PORT" os-env [
        string>number dup integer? t assert= redis-port set-global
    ] when* ;

: bootstrap-probes ( -- )
    "unix.linux.proc" test
    "linux.input-events.ffi" dup require test
    { 42 } [ 40 2 + ] unit-test
    { 4950 } [ 100 <iota> >array compact-gc sum ] unit-test
    { "42\n" } [
        vm-path "-no-user-init" "-e=40 2 + ." 3array utf8
        [ read-contents ] with-process-reader
    ] unit-test
    { "cpu.riscv.32.assembler" "cpu.riscv.64.assembler" }
    [ dup require test ] each
    { t } [
        [ B{ 1 0 0x13 0 0 0 } disassemble ] with-string-writer
        dup print
        [ "c.nop" subseq-index >boolean ]
        [ "13000000" subseq-index >boolean ] bi and
    ] unit-test ;

:: prefix-tests ( -- )
    "compiler" test
    test-failures get length :> compiler-failures
    "Compiler test failures: " write compiler-failures .
    "Compiler errors after compiler tests: " write compiler-errors get assoc-size . flush
    "io" test
    "I/O test failures: " write test-failures get length compiler-failures - .
    "Compiler errors after I/O tests: " write compiler-errors get assoc-size . flush ;

: full-load ( -- )
    f parser-quiet? [ load-all ] with-variable
    "Standard load-all completed" print flush ;

:: essentials-tests ( -- )
    "resource:core" load-root
    "resource:core" test-root
    "Core test failures: " write test-failures get length . flush
    { "compiler" "io" "ui" } [| prefix |
        prefix load
        test-failures get length :> before
        prefix test
        prefix write " test failures: " write
        test-failures get length before - .
        "Compiler errors: " write compiler-errors get assoc-size . flush
    ] each ;

: run-stage ( stage -- )
    {
        { "probe" [ bootstrap-probes ] }
        { "prefixes" [ prefix-tests ] }
        { "essentials" [ essentials-tests ] }
        { "load-all" [ full-load ] }
        { "test-all" [ full-load configure-services test-all ] }
    } case ;

:: write-errors ( error/f output -- )
    output ".errors.txt" append utf8 [
        error/f [ error. nl ] when*
        :test-failures
        compiler-errors get values [ error. nl ] each
    ] with-file-writer ;

: save-failed-image ( output -- )
    f default-secure-context set-global
    ".failed.image" append
    dup "Failed-stage image: " write print flush
    save-image 1 exit ;

: finish-stage ( output -- )
    "Test failures: " write test-failures get length dup .
    "Compiler errors: " write compiler-errors get assoc-size dup . flush
    + zero? [
        f default-secure-context set-global
        save-image-and-exit
    ] [ f over write-errors save-failed-image ] if ;

:: run-and-finish-stage ( stage output -- )
    [ stage run-stage ] [
        dup error. flush
        output write-errors
        output save-failed-image
    ] recover
    output finish-stage ;

: reload-source ( vocab -- )
    dup "Refreshing source: " write print flush reload ;

: refresh-source ( -- )
    {
        "compiler.cfg.builder.alien.boxing"
        "cpu.riscv.32.abi"
        "cpu.riscv.64.abi"
        "compiler.cfg.builder.alien"
        "unix.statvfs.linux"
        "io.files.info.unix.linux"
        "tools.disassembler.capstone"
        "unix.linux.proc"
        "math.vectors.simd"
    } [ reload-source ] each
    ! Older loaded images contain floating boolean masks made by their
    ! previous constructor. Reparse the vocabularies that cached those masks.
    { "math.matrices.simd" "terrain" } [
        dup loaded-vocab-names member? [ reload-source ] [ drop ] if
    ] each ;

: main ( -- )
    command-line get dup length 2 assert= first2
    cpu name>> "riscv." "FACTOR_RISCV_BITS" os-env append assert=
    "CPU: " write cpu name>> print
    "VM: " write vm-path print flush
    refresh-source
    f default-secure-context set-global
    f restartable-tests? set-global
    V{ } clone test-failures set-global
    run-and-finish-stage ;

MAIN: main
