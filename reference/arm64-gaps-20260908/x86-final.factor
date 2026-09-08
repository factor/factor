USING: accessors assocs compiler.errors debugger io kernel namespaces
prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
{ "cpu.architecture" "alien.c-types" "alien" "alien.parser" "alien.syntax"
  "stack-checker.alien" "stack-checker.known-words"
  "compiler.cfg.builder.alien.params" "compiler.cfg.builder.alien.boxing"
  "compiler.cfg.builder.alien" "compiler.cfg.renaming.functor" } [
    dup "Reloading " write print flush reload
] each
USING: io kernel sequences vocabs.loader ;
{
    "cpu.architecture"
    "compiler.cfg.instructions"
    "compiler.cfg.def-use"
    "compiler.cfg.hats"
    "compiler.cfg.renaming.functor"
    "compiler.cfg.renaming"
    "compiler.cfg.linear-scan.assignment"
    "compiler.cfg.representations.rewrite"
    "compiler.cfg.ssa.construction"
    "compiler.cfg.representations.preferred"
    "compiler.cfg.value-numbering.expressions"
    "compiler.codegen"
    "cpu.x86"
    "cpu.x86.64"
    "compiler.cfg.value-numbering.graph"
    "compiler.cfg.value-numbering.folding"
    "compiler.cfg.value-numbering.math"
    "compiler.cfg.value-numbering"
    "compiler.cfg.multiply-negate"
    "compiler.cfg.optimizer"
} [ dup print flush reload ] each

"math.floats.small.c-types" reload
"math.floats.small" test
"resource:basis/compiler/tests/alien-small-floats.factor" run-test-file
"compiler.cfg.multiply-negate" test
{ "alien.parser" "compiler.cfg.builder.alien" } [ test ] each
{ "resource:basis/compiler/tests/alien.factor"
  "resource:basis/compiler/tests/alien-large-return.factor" } [ run-test-file ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ [ path>> print ] [ line#>> . ] [ error>> print-error ] tri ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
