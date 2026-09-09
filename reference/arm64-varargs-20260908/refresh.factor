USING: assocs bootstrap.image.private compiler.errors compiler.units debugger
hashtables io kernel kernel.private memory namespaces parser sequences vocabs.loader ;

"cpu.architecture" reload
[
    {
        "alien"
        "alien.c-types.varargs"
        "alien.varargs"
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
        "cpu.arm.64"
    } [ dup print flush reload ] each
] with-compilation-unit

compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Varargs compiler refresh failed" throw ] unless
H{ } clone special-objects set
H{ } clone sub-primitives set
"resource:basis/bootstrap/assembler/arm.unix.factor" run-file
"resource:basis/bootstrap/assembler/arm.64.factor" run-file
CALLBACK-STUB special-objects get at CALLBACK-STUB set-special-object
"Varargs compiler refreshed" print flush
"/Users/erg/factor/reference/arm64-varargs-20260908/candidate.image" save-image-and-exit
