USING: assocs compiler.errors compiler.units debugger io kernel memory namespaces sequences vocabs.loader ;
[
{
    "compiler.cfg.checker"
    "compiler.cfg.copy-prop"
    "compiler.cfg.linear-scan.checker"
    "compiler.cfg.linear-scan"
    "compiler.cfg.register-allocation"
    "compiler.cfg.register-allocation.greedy"
    "compiler.cfg.register-allocation.backtracking"
    "compiler.cfg.register-allocation.chordal"
    "compiler.cfg.value-numbering.folding"
    "compiler.cfg.representations.selection"
    "compiler.cfg.finalization"
    "compiler.cfg.value-numbering.simd"
    "compiler.cfg.value-numbering.global"
    "compiler.cfg.value-numbering"
    "compiler.cfg.optimizer"
} [ dup print flush reload ] each
] with-compilation-unit
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Compiler errors after current compiler refresh" throw ] unless
"Current compiler integration refreshed" print flush
"final.image" save-image-and-exit
