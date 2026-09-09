! Untimed installed-code capture. No optimizer overrides or timing samples.
USING: alien alien.data allocator-runtime-comparison arrays assocs
compiler-next3.benchmark compiler-next3.witnesses compiler.units
compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites compiler.cfg.value-numbering
io json kernel locals math namespaces sequences words ;
IN: compiler-next3.loop-code
:: capture-loop-code ( feature enabled? -- )
    "linear-scan" select-allocator
    f check-allocation? set f check-ssa? set
    f global-value-numbering? set f rematerialize-constants? set
    f backtracking-loop-spills? set
    feature enabled? configure-features :> options
    selected-loop-kernel get-global :> target
    target \ loop-work 2array compile
    \ loop-work execute( -- )
    target word-id :> target-id
    target word-code :> ( start end )
    start <alien> end start - memory>byte-array >array :> bytes
    start 32 mod :> mod32
    start 64 mod :> mod64
    H{ { "kind" "installed-loop-code" } { "feature" feature } { "enabled" enabled? }
       { "options" options } { "word" target-id }
       { "start-address" start } { "address-mod32" mod32 }
       { "address-mod64" mod64 } { "code-bytes" bytes }
       { "oracle" "123 xor 456 over 10000001 iterations = 435" } }
    >json print ;
: run-loop-code ( -- )
    "loops" f capture-loop-code "loops" t capture-loop-code
    "representations" t capture-loop-code
    "LOOP INSTALLED CODE CAPTURE PASS" print ;
