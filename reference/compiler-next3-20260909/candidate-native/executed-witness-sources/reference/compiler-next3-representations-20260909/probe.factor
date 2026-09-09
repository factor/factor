USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
USING: accessors arrays assocs compiler.cfg compiler.cfg.checker
compiler.cfg.debugger compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linearization compiler.cfg.loop-detection compiler.cfg.metrics
compiler.cfg.optimizer compiler.cfg.register-allocation
compiler.cfg.register-allocation.verifier
compiler.cfg.representations compiler.cfg.representations.selection
compiler.cfg.utilities compiler.cfg.value-numbering compiler.test
cpu.architecture io json kernel kernel.private locals math namespaces
math.private prettyprint quotations sequences sequences.generalizations system words ;
IN: representation-cost-probe

: repeated-loop-quot ( -- quot )
    [ { fixnum } declare 0.0 swap [ 1.0 float+ ] times ]
    31 [ \ dup ] replicate append [ 32 narray ] append >quotation ;

:: report-representations ( enabled? -- )
    enabled? conversion-aware-representation-costs? set
    repeated-loop-quot test-builder :> graphs
    graphs [| graph |
        graph cfg set
        graph optimize-cfg
        graph select-representations
        graph linearization-order [| block |
            block instructions>> [ ##allot? ] count :> boxes
            block instructions>> [ ##load-memory-imm? ] count :> loads
            block loop-nesting-at :> depth
            H{ { "loop-depth" depth }
               { "allocations" boxes } { "loads" loads }
               { "enabled" enabled? } } >json print
        ] each
    ] each ;

t check-allocation? set-global
t check-ssa? set-global
f global-value-numbering? set-global
f report-representations
t report-representations
{ f t } [| enabled? |
    enabled? conversion-aware-representation-costs? set
    100 repeated-loop-quot compile-call
    32 [ 100.0 ] replicate assert=
    "NATIVE-PASS " write enabled? . flush
] each
0 exit
