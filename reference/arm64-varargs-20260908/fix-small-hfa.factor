USING: assocs compiler.errors compiler.units debugger io kernel memory
namespaces sequences vocabs.loader ;
[ "cpu.arm.64.abi" reload ] with-compilation-unit
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Small HFA update failed" throw ] unless
"Small HFA source updated" print flush
"/Users/erg/factor/reference/arm64-varargs-20260908/final.image" save-image-and-exit
