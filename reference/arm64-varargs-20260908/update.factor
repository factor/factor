USING: assocs compiler.errors compiler.units debugger io kernel memory
namespaces sequences vocabs.loader ;
[
    {
        "math.vectors.simd"
        "alien.c-types.varargs"
        "cpu.arm.64.abi"
        "alien.varargs"
        "alien.parser"
        "alien.syntax"
        "stack-checker.alien"
        "stack-checker.known-words"
        "compiler.cfg.builder.alien.boxing"
        "compiler.cfg.builder.alien"
        "cpu.arm.64"
    } [ dup print flush reload ] each
] with-compilation-unit
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Varargs source update failed" throw ] unless
"Varargs source updated" print flush
"/Users/erg/factor/reference/arm64-varargs-20260908/current.image" save-image-and-exit
