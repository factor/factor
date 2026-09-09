USING: assocs compiler.errors compiler.units debugger io kernel namespaces sequences vocabs.loader ;
[ { "alien.c-types.varargs" "compiler.cfg.builder.alien.boxing" "cpu.arm.64" "compiler.cfg.builder.alien" "stack-checker.alien" } [ dup print flush reload ] each ] with-compilation-unit
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Compiler errors after refresh" throw ] unless
