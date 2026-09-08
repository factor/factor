USING: compiler.cfg.metrics help.markup help.syntax ;
IN: compiler.cfg.metrics

ARTICLE: "compiler.cfg.metrics" "Compiler and allocator measurements"
"Compile a word or quotation through the production CFG pass lists and code generation, without installing the resulting machine code:"
{ $code "USING: compiler.cfg.metrics json math prettyprint ;"
        "[ + ] measure-compilation >json ." }
"The returned association contains frontend time and one record per generated procedure. Each procedure reports emitted code bytes, code generation time, and per-pass wall-clock nanoseconds with instruction, block, spill, reload, copy, spill-area and frame-size counts. A frame size of zero means no frame has been built at that point. Instruction counting happens outside each timed interval."
"The linear-scan timing includes interval construction, allocation, assignment and edge-move resolution. SSA destruction and coalescing are measured separately. Counts are static; a spill in a hot loop costs more than one in a cold block."
"Use the same executable, image, input corpus and instrumentation for both configurations. Refresh compiler sources before measuring a changed worktree. Alternate configurations in fresh processes and retain all samples. These instrumented pass timings locate costs; confirm performance claims with uninstrumented end-to-end compilation and workload execution."
"Measurement does not replace allocator or GC correctness tests."
;

ABOUT: "compiler.cfg.metrics"
