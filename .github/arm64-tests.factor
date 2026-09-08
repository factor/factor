! Focused native ARM64 coverage, shared by Linux, macOS and Windows CI.
USING: assocs combinators compiler.errors cpu.arm.64.features debugger io kernel
namespaces sequences system tools.test vocabs.hierarchy ;
IN: arm64-ci

! Test failures must be recorded instead of opening an interactive restart.
f restartable-tests? set-global
cpu arm.64? [ "ARM64 regression tests require an ARM64 VM" throw ] unless
"disable-neon-extensions" get [
    arm64-features empty? [ "Optional ARM64 extensions are still enabled" throw ] unless
] when

{
    "cpu.arm.64"
    "alien.parser"
    "stack-checker.alien"
    "compiler.cfg.builder.alien"
    "compiler.cfg.multiply-negate"
    "math.vectors.simd"
    "math.vectors.conversion"
    "math.floats.env"
    "math.floats.small"
} [
    dup "Testing " write print flush
    [ load ] [ test ] bi
] each

! These are test files belonging to compiler, not loadable vocabularies.
{
    "resource:basis/compiler/tests/alien.factor"
    "resource:basis/compiler/tests/alien-large-return.factor"
    "resource:basis/compiler/tests/alien-small-floats.factor"
    "resource:basis/compiler/tests/alien-arm64-abi.factor"
    "resource:basis/compiler/tests/float.factor"
} [ dup "Testing " write print flush run-test-file ] each

: test-status ( -- status )
    test-failures get empty? compiler-errors get assoc-empty? and
    [ "ARM64 regression tests passed" print 0 ] [
        :test-failures compiler-errors get values [ print-error ] each 1
    ] if ;

test-status flush exit
