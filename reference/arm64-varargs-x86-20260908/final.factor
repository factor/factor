USING: accessors assocs compiler.errors compiler.units debugger io kernel memory namespaces
prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
{ "math.floats.small" "compiler.cfg.multiply-negate" "alien.parser"
  "stack-checker.alien" "compiler.cfg.builder.alien" "alien.varargs" } [ test ] each
{ "resource:basis/compiler/tests/alien-small-floats.factor"
  "resource:basis/compiler/tests/alien.factor"
  "resource:basis/compiler/tests/alien-large-return.factor"
  "resource:basis/compiler/tests/alien-varargs-outgoing.factor"
  "resource:basis/compiler/tests/alien-varargs-promotions.factor"
} [ dup print flush run-test-file ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ [ path>> print ] [ line#>> . ] [ error>> print-error ] tri ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
