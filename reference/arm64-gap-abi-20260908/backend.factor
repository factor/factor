USING: vocabs.loader tools.test namespaces sequences prettyprint system compiler.errors assocs compiler.units kernel math ;
"cpu.architecture" reload
[
"alien" reload
"stack-checker.alien" reload
"stack-checker.known-words" reload
"compiler.cfg.builder.alien.params" reload
"compiler.cfg.builder.alien.boxing" reload
"compiler.cfg.renaming.functor" reload
"compiler.cfg.renaming" reload
"compiler.cfg.ssa.construction" reload
"compiler.cfg.representations.rewrite" reload
"compiler.cfg.linear-scan.assignment" reload
"alien.parser" reload
"alien.syntax" reload
"cpu.architecture" reload
"cpu.arm.64.assembler" reload
"cpu.arm.64" reload
"compiler.cfg.builder.alien" reload
] with-compilation-unit
"cpu.arm.64" test
"test failures" . test-failures get length dup .
"compiler errors" . compiler-errors get assoc-size dup .
+ 0 = 0 1 ? exit
