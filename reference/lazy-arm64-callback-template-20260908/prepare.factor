USING: assocs compiler.errors debugger io kernel kernel.private memory namespaces
sequences vocabs.refresh ;
"Refreshing the old root image with the builder cycle fix" print flush
refresh-all
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Refresh failed" throw ] unless
CALLBACK-STUB special-object length 2 = [ "Expected legacy callback template" throw ] unless
"Refreshed old image retains two-item template" print flush
"/Users/erg/factor.worktrees/lazy-arm64-callback-template/prepared.image" save-image-and-exit
