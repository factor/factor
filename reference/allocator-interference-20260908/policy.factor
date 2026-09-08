USING: accessors arrays assocs command-line compiler.cfg
compiler.cfg.finalization compiler.cfg.metrics compiler.cfg.optimizer
compiler.cfg.register-allocation compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.greedy compiler.codegen compiler.test
compiler.cfg.value-numbering combinators io json kernel kernel.private locals
math math.private namespaces parser sequences tools.time vocabs.loader ;
command-line get first "baseline" = [
    "work/interference-perf/baseline-backtracking.factor" run-file
    "work/interference-perf/baseline-greedy.factor" run-file
] [
    "compiler.cfg.register-allocation.backtracking" reload
    "compiler.cfg.register-allocation.greedy" reload
] if
IN: compiler.cfg.metrics
:: measure-cfg ( procedure -- metrics )
    [
        procedure cfg set
        \ optimize-cfg pass-list \ finalize-cfg pass-list append
        [ procedure swap measure-pass ] map :> passes
        current-register-allocator allocator-statistics :> allocation
        procedure generate 4 swap nth >array :> bytes
        H{ { "allocation" allocation } { "passes" passes }
           { "code" bytes } }
    ] with-scope ;
IN: interference-policy
: pressure-quotation ( -- quot )
    [
        {
            [ 1 fixnum+fast ]
            [ 2 fixnum+fast ]
            [ 3 fixnum+fast ]
            [ 4 fixnum+fast ]
            [ 5 fixnum+fast ]
            [ 6 fixnum+fast ]
            [ 7 fixnum+fast ]
            [ 8 fixnum+fast ]
            [ 9 fixnum+fast ]
            [ 10 fixnum+fast ]
            [ 11 fixnum+fast ]
            [ 12 fixnum+fast ]
            [ 13 fixnum+fast ]
            [ 14 fixnum+fast ]
            [ 15 fixnum+fast ]
            [ 16 fixnum+fast ]
            [ 17 fixnum+fast ]
            [ 18 fixnum+fast ]
            [ 19 fixnum+fast ]
            [ 20 fixnum+fast ]
            [ 21 fixnum+fast ]
            [ 22 fixnum+fast ]
            [ 23 fixnum+fast ]
            [ 24 fixnum+fast ]
            [ 25 fixnum+fast ]
            [ 26 fixnum+fast ]
            [ 27 fixnum+fast ]
            [ 28 fixnum+fast ]
            [ 29 fixnum+fast ]
            [ 30 fixnum+fast ]
            [ 31 fixnum+fast ]
            [ 32 fixnum+fast ]
            [ 33 fixnum+fast ]
            [ 34 fixnum+fast ]
            [ 35 fixnum+fast ]
            [ 36 fixnum+fast ]
            [ 37 fixnum+fast ]
            [ 38 fixnum+fast ]
            [ 39 fixnum+fast ]
            [ 40 fixnum+fast ]
        } cleave
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
    ] ;
f global-value-numbering? set
{ [ { fixnum fixnum } declare + ]
  [ { float float float } declare * + ]
  [ <iota> 0 [ + ] reduce ]
  [ [ dup * ] map ]
  [ dup [ 1 - ] [ 2 + ] if ]
} pressure-quotation suffix [
    { backtracking-allocator greedy-allocator } compare-allocators
] map >json print
