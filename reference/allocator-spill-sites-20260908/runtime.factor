USING: compiler.cfg.register-allocation.spill-sites.fixtures
io kernel locals prettyprint sequences tools.time ;
IN: compiler.cfg.register-allocation.spill-sites.runtime

:: exercise ( word repetitions -- )
    repetitions [ 1000 word execute( n -- checksum ) drop ] times ;

:: measure-runtime ( -- )
    40 8 5 f loop-pressure-metrics drop :> baseline
    40 8 5 t loop-pressure-metrics drop :> candidate
    baseline 20 exercise candidate 20 exercise
    { f t t f f t t f } [| enabled? |
        "READY" print flush readln drop
        [ enabled? candidate baseline ? 2000 exercise ] benchmark .
        "DONE" print flush readln drop
    ] each ;

measure-runtime
