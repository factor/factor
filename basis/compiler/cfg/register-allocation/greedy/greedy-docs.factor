USING: compiler.cfg.register-allocation
compiler.cfg.register-allocation.greedy help.markup help.syntax ;
IN: compiler.cfg.register-allocation.greedy

HELP: greedy-allocator
{ $description "An LLVM-style greedy register allocator. Bind "
  { $link register-allocator } " to this singleton around compilation to select it. It combines indexed interference queries, staged allocation, cascade-controlled eviction, CFG region spill placement, local splitting and bounded recoloring. It does not invoke LLVM or fall back to another allocator. Linear scan remains the default." } ;

HELP: greedy-allocation-with-registers
{ $values { "cfg" "a control-flow graph" }
          { "registers" "an association from register classes to legal physical register sequences" } }
{ $description "Runs the complete greedy allocator, including SSA destruction, instruction numbering, register assignment and edge resolution, using the supplied register banks. The banks must respect the target's reserved-register and ABI constraints. Independent validation can supply smaller legal banks without changing the global allocator selection." } ;

ARTICLE: "compiler.cfg.register-allocation.greedy" "Greedy register allocation"
"This allocator reuses Factor's SSA destruction, live intervals, spill and rematerialization lowering, GC handling and edge resolution. Allocation order is independent of instruction order. A sorted occupancy index for each physical register queries individual live ranges, preserving lifetime holes. Interval priorities and use costs are cached."
"A maximum priority queue visits initial intervals before retries, ordering each tier by covered range size, weighted use density and virtual register. Allocation advances through assignment, global region splitting, local splitting, spilling and terminal stages. Stages never regress; split products advance toward mandatory-use fragments."
"Register preferences come from copies and previous split choices. Eviction compares broken-hint costs and victim weights, then requeues displaced intervals. Victims inherit the requester's eviction cascade so peers cannot repeatedly evict one another. An urgent mandatory interval may displace a spillable interval in a newer cascade with a cost penalty, but cannot break its own cascade. Terminal fragments cannot be evicted."
"Global splitting evaluates each legal register on the actual live CFG. A deterministic minimum-cut solver chooses register-resident blocks using weighted memory-use and edge-transition costs, subject to hard interference constraints. Transparent blocks and loop cycles participate in the same network. Resident blocks receive the chosen register; memory blocks containing uses become products for local refinement. Edge resolution emits stores, reloads and copies where locations change. Networks above 128 live blocks proceed to local splitting."
"Local splitting selects weighted use clusters inside physically free register windows, including room for the post-use spill. If allocation still fails, last-chance recoloring searches for an augmenting reassignment with depth at most five, at most eight interferers per candidate and a budget of 64 interval visits. A failed attempt restores register assignments, occupancy indexes and diagnostics. Spill products retain only mandatory uses; an impossible terminal allocation raises a register-pressure error. These search limits do not select another allocator."
"Use and edge weights are static estimates based on eight to the power of loop nesting, capped at depth three. Calls and other clobbers are split first using Factor's keep-destination and ABI spill-slot rules. When constant rematerialization is enabled, eligible values use shared recipes instead of memory backing. Shared assignment preserves GC roots and saves live-through registers, including the incoming representation of a region fragment with no local uses."
"The target model exposes whole integer and floating-point register banks. Tagged values share the integer bank; scalar and SIMD floating-point values share the floating bank. Conservative inclusive intervals after SSA destruction preserve operand, temporary and implicit GC interference, but limit dying-input reuse and copy hints compared with LLVM's instruction phases. Subregister lanes, register units, target-specific register classes, callee-saved activation costs, instruction folding, measured execution profiles and ML eviction advice are outside this interface. The implementation adapts LLVM's allocation mechanisms to Factor; it does not claim full LLVM target-feature parity."
"The diagnostic association identifies the algorithm as llvm-style-greedy and reports a zero fallback count. Activity counters include processed stages, assignments, evictions, urgent evictions, hint assignments and breaks, global and local splits, block products, resident blocks, region cut cost, clobber handling, and recoloring attempts, successes, search steps and rollbacks. Counters for inactive features may be absent."
{ $see-also register-allocator allocator-statistics greedy-allocation-with-registers }
;

ABOUT: "compiler.cfg.register-allocation.greedy"
