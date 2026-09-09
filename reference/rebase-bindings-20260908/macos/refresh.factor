USING: assocs compiler.errors debugger io kernel memory namespaces
sequences vocabs.loader ;
"compiler.cfg.intrinsics.simd" reload
"math.vectors.simd.intrinsics" reload
"math.vectors.simd" reload
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "SIMD reload failed" throw ] unless
"/Users/erg/factor.worktrees/bindings-on-agent1-20260908/rebased-simd.image" save-image-and-exit
