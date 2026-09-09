USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.build-stack-frame compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering compiler.cfg.linearization
compiler.cfg.loop-detection compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier compiler.cfg.registers compiler.cfg.utilities
compiler.codegen compiler.units cpu.architecture hashtables kernel layouts locals make math math.functions math.order
namespaces sequences tools.test words ;
IN: compiler.cfg.register-allocation.spill-sites.fixtures

: fresh-int ( -- vreg ) int-rep next-vreg-rep ;

:: sum-values ( values -- sum )
    values first :> sum!
    values rest [| value |
        fresh-int :> next
        next sum value ##add,
        next sum!
    ] each
    sum ;

:: sum-rounds ( values rounds -- sum )
    values sum-values :> sum!
    rounds 1 - [
        values sum-values :> term
        fresh-int :> next
        next sum term ##add,
        next sum!
    ] times
    sum ;

! All values are derived from the runtime input, remain live through the
! loop, and are consumed by both the hot body and the cold exit. Every
! arithmetic result contributes to the returned checksum.
:: <mixed-loop-pressure> ( count hot-count hot cold -- graph )
    H{ } clone representations set
    0 vreg-counter set
    fresh-int :> input
    fresh-int :> counter
    fresh-int :> next-counter
    fresh-int :> result
    f :> values!
    [
        ##prologue,
        input D: 0 ##peek,
        count <iota> [| i |
            fresh-int dup input i 1 + tag-fixnum ##add-imm,
        ] map values!
        ##branch,
    ] { } make 0 insns>block :> entry
    <basic-block> :> header
    f :> hot-result!
    [
        values hot-count head hot sum-rounds hot-result!
        next-counter counter 1 tag-fixnum ##sub-imm,
        ##branch,
    ] { } make 2 insns>block :> body
    [
        values cold sum-rounds :> cold-result
        fresh-int :> total
        total cold-result result ##add,
        total D: 0 ##replace,
        ##epilogue, ##return,
    ] { } make 3 insns>block :> done
    [
        counter H{ { entry input } { body next-counter } } ##phi,
        result H{ { entry input } { body hot-result } } ##phi,
        counter 0 cc> ##compare-integer-imm-branch,
    ] V{ } make header instructions<<
    entry header connect-bbs
    header body connect-bbs header done connect-bbs
    body header connect-bbs
    entry block>cfg ;

:: <loop-pressure> ( count hot cold -- graph )
    count count hot cold <mixed-loop-pressure> ;

:: weighted-traffic ( graph -- count )
    graph needs-loops
    graph linearization-order [| bb |
        bb instructions>> [ dup ##spill? swap ##reload? or ] count
        8 bb loop-nesting-at 3 min ^ *
    ] map-sum ;

:: loop-pressure-metrics* ( nvalues hot-count hot cold enabled? -- word metrics )
    [
        enabled? backtracking-loop-spills? set
        backtracking-allocator register-allocator set
        t check-allocation? set
        t check-numbering? set
        nvalues hot-count hot cold <mixed-loop-pressure> :> graph
        graph cfg set
        graph allocate-registers
        graph build-stack-frame
        graph cfg-metrics :> metrics
        graph weighted-traffic "weighted-traffic" metrics set-at
        graph linearization-order [ loop-nesting-at 0 > ] filter
        [ instructions>> [ dup ##spill? swap ##reload? or ] count ] map-sum
        "loop-traffic" metrics set-at
        loop-spill-site-count get "loop-spill-sites" metrics set-at
        cold-spill-store-count get "redundant-loop-stores" metrics set-at
        gensym :> word
        graph generate :> code
        code 4 swap nth length "code-bytes" metrics set-at
        code word associate >alist t t modify-code-heap
        word metrics
    ] with-scope ;

:: loop-pressure-metrics ( count hot cold enabled? -- word metrics )
    count count hot cold enabled? loop-pressure-metrics* ;
