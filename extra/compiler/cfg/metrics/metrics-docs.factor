USING: compiler.cfg.metrics help.markup help.syntax ;
IN: compiler.cfg.metrics

ARTICLE: "compiler.cfg.metrics" "Compiler and allocator measurements"
"Compile a word or quotation through the production CFG pass lists and code generation, without installing the resulting machine code:"
{ $code "USING: compiler.cfg.metrics json math prettyprint ;"
        "[ + ] measure-compilation >json ." }
"The returned association contains frontend time and one record per generated procedure. Each procedure reports emitted code bytes, code generation time, and per-pass wall-clock nanoseconds with instruction, block, spill, reload, copy, spill-area and frame-size counts. A frame size of zero means no frame has been built at that point. Instruction counting happens outside each timed interval."
"The allocator field identifies the selected allocator. The allocate-registers timing includes SSA destruction, coalescing, interval or graph construction, allocation, assignment and edge-move resolution. Counts are static; a spill in a hot loop costs more than one in a cold block."
"Each procedure's allocation association contains optional allocator-specific diagnostics, captured in that procedure's dynamic scope immediately after finalization. The default allocator supplies an empty association."
"Use compare-allocators with an input and a sequence of allocator objects to obtain one report per allocator. Every entry starts from a freshly built CFG. This convenience operation runs in sequence in the current process; use repeated alternating fresh-process runs for performance conclusions."
"Use the same executable, image, input corpus and instrumentation for both configurations. Refresh compiler sources before measuring a changed worktree. Alternate configurations in fresh processes and retain all samples. These instrumented pass timings locate costs; confirm performance claims with uninstrumented end-to-end compilation and workload execution."
"Measurement does not replace allocator or GC correctness tests."
;

ABOUT: "compiler.cfg.metrics"
