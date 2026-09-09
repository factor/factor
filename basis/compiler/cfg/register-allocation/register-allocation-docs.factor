USING: compiler.cfg.register-allocation help.markup help.syntax ;
IN: compiler.cfg.register-allocation

HELP: register-allocator
{ $var-description "The allocator used by CFG finalization. An unset value or " { $link f } " selects " { $link linear-scan-allocator } ". Bind this variable around compilation to compare allocators without changing the process default. Existing compiled code is unaffected." } ;

HELP: allocate-cfg
{ $values { "cfg" "a control-flow graph in SSA form" } { "allocator" "an allocator object" } }
{ $description "Allocates physical registers. The input has selected representations, GC checks and save-context instructions, but still contains SSA phis. The method owns SSA destruction, coalescing, spill and reload insertion, and edge-move resolution. Its output must be ready for stack-frame construction and code generation, with all calling-convention and GC constraints satisfied."
"Implement this generic in an allocator vocabulary and bind " { $link register-allocator } " to its allocator object. Unsupported objects fail through ordinary generic dispatch; they do not silently select another allocator." } ;

HELP: allocator-statistics
{ $values { "allocator" "an allocator object" } { "assoc" "an association of diagnostic names to values" } }
{ $description "Returns a snapshot of diagnostics for the most recent allocation in the current dynamic scope. Implementations may report evictions, splits, graph properties or other algorithm-specific counters. The default method returns an empty association. The returned data must not change when a later allocation runs. Diagnostics must not affect allocation decisions." } ;

ARTICLE: "compiler.cfg.register-allocation" "Selecting a register allocator"
"Linear scan remains the default. To select an allocator for a compilation or measurement, dynamically bind " { $link register-allocator } ":"
{ $code "USING: compiler.cfg.metrics compiler.cfg.register-allocation"
        "math namespaces prettyprint ;"
        "linear-scan-allocator register-allocator"
        "[ [ + ] measure-compilation . ] with-variable" }
"Allocator implementations receive the CFG before SSA destruction so that SSA-based algorithms can use their required invariants. Each implementation must produce a fully allocated CFG."
"Three experimental alternatives are available:"
{ $list
    { { $vocab-link "compiler.cfg.register-allocation.greedy" } ": LLVM-inspired priority allocation with eviction, CFG region placement, local splitting and bounded last-chance recoloring." }
    { { $vocab-link "compiler.cfg.register-allocation.backtracking" } ": regalloc2-inspired SSA affinity bundles with eviction, conflict-directed splitting, shared spill homes and second-chance allocation." }
    { { $vocab-link "compiler.cfg.register-allocation.chordal" } ": SSA pressure reduction with explicit spills and reloads before certified interference-graph coloring and affinity-guided assignment." }
}
"These are Factor implementations of the approaches, with different engineering tradeoffs from their reference compilers. Compare generated code and execution as well as compilation cost before choosing a default."
{ $code "USING: compiler.cfg.metrics compiler.cfg.register-allocation"
        "compiler.cfg.register-allocation.greedy"
        "compiler.cfg.register-allocation.backtracking"
        "compiler.cfg.register-allocation.chordal"
        "kernel.private math prettyprint ;"
        "[ { fixnum fixnum } declare + ]"
        "{ linear-scan-allocator greedy-allocator"
        "  backtracking-allocator chordal-allocator } compare-allocators ." }
;

ABOUT: "compiler.cfg.register-allocation"
