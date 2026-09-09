USING: assocs compiler.errors debugger io kernel namespaces sequences
tools.test vocabs.loader ;

f restartable-tests? set-global
{
    "alien.varargs"
    "alien.parser"
    "stack-checker.alien"
    "compiler.cfg.builder.alien"
} [ dup print flush [ require ] [ test ] bi ] each
{
    "resource:basis/compiler/tests/alien-varargs-outgoing.factor"
    "resource:basis/compiler/tests/alien-varargs.factor"
} [ dup print flush run-test-file ] each
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and
[ "Varargs focused suite passed" print flush 0 ] [ 1 ] if exit
