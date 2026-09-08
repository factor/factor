USING: accessors assocs compiler.errors debugger io kernel namespaces
prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
{ "cpu.architecture" "alien" "alien.parser" "alien.syntax"
  "stack-checker.alien" "stack-checker.known-words"
  "compiler.cfg.builder.alien.params" "compiler.cfg.builder.alien.boxing"
  "compiler.cfg.builder.alien" "compiler.cfg.renaming.functor" } [
    dup "Reloading " write print flush reload
] each
{ "alien.parser" "compiler.cfg.builder.alien" } [ test ] each
{ "resource:basis/compiler/tests/alien.factor"
  "resource:basis/compiler/tests/alien-large-return.factor" } [ run-test-file ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ [ path>> print ] [ line#>> . ] [ error>> print-error ] tri ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
