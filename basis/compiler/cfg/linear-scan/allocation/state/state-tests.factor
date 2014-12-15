USING: combinators.extras compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals heaps kernel namespaces tools.test ;
IN: compiler.cfg.linear-scan.allocation.state.tests

{
    T{ spill-slot f 0 }
    T{ spill-slot f 8 }
    T{ cfg { spill-area-size 16 } }
} [
    H{ } clone spill-slots set
    T{ cfg { spill-area-size 0 } } cfg set
    [ 8 next-spill-slot ] twice
    cfg get
] unit-test

{ { 33 1/0.0 } } [
    T{ sync-point { n 33 } } sync-point-key
] unit-test

{
    {
        { { 5 1/0. } T{ sync-point { n 5 } } }
        {
            { 20 28 }
            T{ live-interval-state { start 20 } { end 28 } }
        }
        {
            { 20 30 }
            T{ live-interval-state { start 20 } { end 30 } }
        }
        {
            { 33 999 }
            T{ live-interval-state { start 33 } { end 999 } }
        }
        { { 33 1/0. } T{ sync-point { n 33 } } }
        { { 100 1/0. } T{ sync-point { n 100 } } }
    }
} [
    {
        T{ live-interval-state { start 20 } { end 30 } }
        T{ live-interval-state { start 20 } { end 28 } }
        T{ live-interval-state { start 33 } { end 999 } }
    }
    {
        T{ sync-point { n 5 } }
        T{ sync-point { n 33 } }
        T{ sync-point { n 100 } }
    }
    >unhandled-min-heap heap-pop-all
] unit-test

{ 2 } [
    {
        T{ live-interval-state { start 20 } { end 30 } }
        T{ live-interval-state { start 20 } { end 30 } }
    } { } >unhandled-min-heap heap-size
] unit-test
