USING: assocs compiler.errors compiler.units debugger io kernel memory namespaces sequences vocabs.loader ;
[ { "compiler.cfg.builder" "compiler.cfg.intrinsics.simd" "compiler.tree.propagation.simd" "stack-checker.alien" } [ dup print flush reload ] each ] with-compilation-unit
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Compiler errors after final helper refresh" throw ] unless
"Final source refresh passed" print flush
"verified.image" save-image-and-exit
