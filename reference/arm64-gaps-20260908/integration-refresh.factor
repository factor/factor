USING: assocs compiler.errors compiler.units debugger io kernel memory namespaces sequences vocabs.loader ;
"cpu.architecture" reload
[
{
    "alien"
    "alien.c-types"
    "alien.parser"
    "alien.syntax"
    "stack-checker.alien"
    "stack-checker.known-words"
    "compiler.cfg.instructions"
    "compiler.cfg.def-use"
    "compiler.cfg.hats"
    "compiler.cfg.builder.alien.params"
    "compiler.cfg.builder.alien.boxing"
    "compiler.cfg.builder.alien"
    "compiler.cfg.renaming.functor"
    "compiler.cfg.renaming"
    "compiler.cfg.linear-scan.assignment"
    "compiler.cfg.representations.rewrite"
    "compiler.cfg.ssa.construction"
    "compiler.cfg.representations.preferred"
    "compiler.cfg.value-numbering.expressions"
    "compiler.codegen"
    "compiler.cfg.value-numbering.graph"
    "compiler.cfg.value-numbering.folding"
    "compiler.cfg.value-numbering.math"
    "compiler.cfg.value-numbering"
    "compiler.cfg.multiply-negate"
    "compiler.cfg.optimizer"
    "cpu.arm.64.assembler"
    "cpu.arm.64"
    "cpu.arm.64.features"
    "math.floats.small.c-types"
    "math.vectors.simd.intrinsics"
    "math.vectors.simd.extensions"
} [ dup print flush reload ] each
] with-compilation-unit
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Compiler errors after combined refresh" throw ] unless
"Combined source refresh passed" print flush
"integration.image" save-image-and-exit
