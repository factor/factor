USING: compiler.cfg.register-allocation help.markup help.syntax ;
IN: compiler.cfg.register-allocation

HELP: register-allocator
{ $var-description "The allocator used by CFG finalization. An unset value or " { $link f } " selects " { $link linear-scan-allocator } ". Bind this variable around compilation to compare allocators without changing the process default. Existing compiled code is unaffected." } ;

HELP: allocate-cfg
{ $values { "cfg" "a control-flow graph in SSA form" } { "allocator" "an allocator object" } }
{ $description "Allocates physical registers. The input has selected representations, GC checks and save-context instructions, but still contains SSA phis. The method owns SSA destruction, coalescing, spill and reload insertion, and edge-move resolution. Its output must be ready for stack-frame construction and code generation, with all calling-convention and GC constraints satisfied."
"Implement this generic in an allocator vocabulary and bind " { $link register-allocator } " to its allocator object. Unsupported objects fail through ordinary generic dispatch; they do not silently select another allocator." } ;

ARTICLE: "compiler.cfg.register-allocation" "Selecting a register allocator"
"Linear scan remains the default. To select an allocator for a compilation or measurement, dynamically bind " { $link register-allocator } ":"
{ $code "USING: compiler.cfg.metrics compiler.cfg.register-allocation"
        "math namespaces prettyprint ;"
        "linear-scan-allocator register-allocator"
        "[ [ + ] measure-compilation . ] with-variable" }
"Allocator implementations receive the CFG before SSA destruction so that SSA-based algorithms can use their required invariants. Each implementation must produce a fully allocated CFG."
;

ABOUT: "compiler.cfg.register-allocation"
