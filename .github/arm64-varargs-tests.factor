! Run against each independently compiled native C fixture library.
USING: assocs compiler.errors debugger io kernel namespaces parser
sequences system tools.test vocabs.hierarchy ;
IN: arm64-varargs-ci-runner

f restartable-tests? set-global
"resource:.github/arm64-varargs-coverage.factor" run-file
{
    "alien.varargs"
    "raylib"
    "gobject-introspection.standard-types"
} [ [ load ] [ test ] bi ] each
os unix? [ "curses.ffi" [ load ] [ test ] bi ] when
os linux? [ "libudev" [ load ] [ test ] bi ] when
{
    "resource:basis/compiler/tests/alien-varargs.factor"
    "resource:basis/compiler/tests/alien-varargs-outgoing.factor"
    "resource:basis/compiler/tests/alien-varargs-promotions.factor"
    "resource:basis/compiler/tests/alien-arm64-unions.factor"
    "resource:basis/compiler/tests/alien-small-floats.factor"
} [ dup print flush run-test-file ] each

test-failures get empty? compiler-errors get assoc-empty? and [
    "ARM64 varargs tests passed" print flush 0 exit
] [
    :test-failures compiler-errors get values [ print-error ] each
    flush 1 exit
] if
