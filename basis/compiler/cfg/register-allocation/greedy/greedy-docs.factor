USING: compiler.cfg.register-allocation
compiler.cfg.register-allocation.greedy help.markup help.syntax ;
IN: compiler.cfg.register-allocation.greedy

HELP: greedy-allocator
{ $description "An experimental LLVM-inspired greedy register allocator. Bind "
  { $link register-allocator } " to this singleton around compilation to select it. It allocates large intervals first, evicts intervals with lower loop-weighted use density, and splits at loop boundaries or gaps between uses. It does not invoke LLVM or fall back to linear scan." } ;

ARTICLE: "compiler.cfg.register-allocation.greedy" "Greedy register allocation"
"This allocator reuses Factor's SSA destruction, live intervals, spill slots, GC handling and edge resolution. Its allocation order is independent of instruction order. Each physical register has a set of assigned intervals; lifetime holes allow sharing."
"A maximum priority queue visits intervals by covered range size, breaking ties by weighted use density and virtual register. An unavailable register can be obtained by evicting all its interfering intervals if each has strictly lower density. Evicted intervals are requeued. A failed eviction splits the interval, first at a block boundary where loop depth changes, otherwise at the widest gap between uses. Single-use fragments are shortened to the mandatory use."
"Use weights are static estimates: eight to the power of loop nesting, capped at depth three. These are not execution profiles. Splits reuse Factor's spill/reload representation. Calls and other clobbers are split first with the existing keep-destination rule; GC root handling remains in the shared assignment pass."
"This is a smaller algorithm than LLVM's Greedy allocator. It has vector interval sets rather than indexed interval unions, no profile-guided region placement, rematerialization, register hints, subregister model, or last-chance recoloring. It reports impossible mandatory-use pressure as an error. Linear scan remains the default."
"The diagnostic association reports assignments, evictions, splits, region-splits, and clobber-splits when their counts are nonzero. Measurements and executable pressure tests accompany the implementation."
{ $see-also register-allocator allocator-statistics }
;

ABOUT: "compiler.cfg.register-allocation.greedy"
