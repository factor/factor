USING: parser vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh
"compiler.cfg.register-allocation.verifier" require
"compiler.cfg.register-allocation.verifier.rematerialization" require >>
USING: accessors assocs compiler.cfg.register-allocation
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.validation
compiler.cfg.register-allocation.rematerialization compiler.cfg.value-numbering
io json kernel kernel.private locals namespaces sequences ;
IN: allocator-native-witness

:: run-diamond ( width seed -- )
    f rematerialize-constants? set f global-value-numbering? set
    t chordal-witness? set
    width seed <validation-diamond> :> graph
    graph 4 2 validation-register-bank :> bank
    chordal-allocator bank [ chordal-allocation-with-registers ] constrained-allocator boa
    graph swap compile-validation-cfg :> word
    chordal-allocator allocator-statistics :> stats
    { -9 -1 0 1 9 } [| input |
        input word execute( x -- y ) input width seed validation-diamond-result =
    ] all? [ ] [ "Native diamond formula mismatch" throw ] if
    width "width" stats set-at seed "seed" stats set-at
    stats >json print flush ;

t json-coerce-keys? set
{ 4 6 12 } [| width | 3 <iota> [| seed | [ width seed run-diamond ] with-scope ] each ] each
