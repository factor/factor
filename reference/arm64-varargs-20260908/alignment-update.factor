USING: assocs compiler.errors compiler.units debugger io kernel memory
namespaces sequences vocabs.loader ;
[
 { "math.vectors.simd" "compiler.cfg.builder.alien.boxing"
   "compiler.cfg.builder.alien" } [ dup print flush reload ] each
] with-compilation-unit
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Alignment source update failed" throw ] unless
"Alignment source updated" print flush
"/Users/erg/factor/reference/arm64-varargs-20260908/final.image" save-image-and-exit
