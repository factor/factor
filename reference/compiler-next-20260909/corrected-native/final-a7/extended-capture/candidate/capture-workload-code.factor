! Untimed diagnostic only. Invoke run-code-capture after this file's compilation
! unit closes. The selected closure is compiled and installed normally; the hook
! records the actual final physical CFG and unrelocated code descriptor supplied
! to the VM, rather than recompiling a wrapper afterward for metrics.
USING: accessors allocator-runtime-comparison arrays assocs command-line
compiler.cfg compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites compiler.cfg.utilities
compiler.cfg.value-numbering compiler.codegen compiler.errors compiler.units
io kernel locals math namespaces prettyprint sequences tools.test words ;
IN: compiler-next.code-capture

SYMBOLS: captured-code captured-targets original-generate ;
<< \ generate def>> \ original-generate set-global >>

:: record-code ( graph code -- )
    captured-targets get [ graph word>> swap member? ] [ f ] if* [
        graph word>> word-id :> word
        graph label>> unparse :> label
        graph cfg>insns [ unparse ] map :> physical
        code first [ unparse ] map :> parameters
        code second [ unparse ] map :> literals
        code third >array :> relocations
        code fourth unparse :> labels
        4 code nth >array :> bytes
        5 code nth :> frame
        H{
            { "kind" "generated-code" }
            { "word" word }
            { "label" label }
            { "physical-instructions" physical }
            { "parameters" parameters }
            { "literals" literals }
            { "relocations" relocations }
            { "labels" labels }
            { "code-bytes" bytes }
            { "frame-bytes" frame }
        } captured-code get push
    ] when ;

USE: compiler-next.code-capture
IN: compiler.codegen
:: generate ( graph -- code )
    graph original-generate get call( graph -- code ) :> code
    graph code record-code
    code ;

IN: compiler-next.code-capture
: begin-code-capture ( -- )
    f length-limit set f nesting-limit set
    { base32-work integer-pressure-work } captured-targets set
    V{ } clone captured-code set ;

:: finish-code-capture ( -- )
    captured-targets get [| target |
        captured-code get [ "word" swap at target word-id = ] any? t assert=
    ] each
    captured-code get [ emit ] each
    "CODE-CAPTURE-COMPLETE" print ;

:: run-code-capture ( -- )
    [
        begin-code-capture
        command-line get first select-allocator
        t check-allocation? set t check-ssa? set
        f global-value-numbering? set
        t rematerialize-constants? set t backtracking-loop-spills? set
        benchmark-words get-global compile
        compiler-errors get assoc-size 0 assert=
        finish-code-capture
    ] with-scope ;
