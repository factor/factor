USING: assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.registers
cpu.architecture cpu.x86.assembler.operands kernel linked-assocs
locals namespaces tools.test vectors ;
IN: compiler.cfg.linear-scan.allocation.spilling.tests

: test-live-interval ( -- live-interval )
    T{ live-interval-state
       { vreg 45 }
       { reg RBX }
       { spill-to T{ spill-slot { n 8 } } }
       { spill-rep double-rep }
       { ranges V{ { 22 47 } { 67 68 } { 69 72 } } }
       { uses
         V{
             T{ vreg-use
                { n 28 }
                { use-rep double-rep }
             }
         }
       }
    } ;

: test-live-interval2 ( -- live-interval )
    T{ live-interval-state
       { vreg 20 }
       { reg RAX }
       { spill-rep int-rep }
       { ranges V{ { 22 47 } { 67 68 } { 69 72 } } }
       { uses
         V{
             T{ vreg-use
                { n 23 }
                { use-rep int-rep }
             }
             T{ vreg-use
                { n 28 }
                { use-rep int-rep }
             }
             T{ vreg-use
                { n 30 }
                { use-rep int-rep }
             }
         }
       }
    } ;

: test-live-interval3 ( -- live-interval )
    T{ live-interval-state
       { vreg 21 }
       { reg RCX }
       { spill-rep int-rep }
       { ranges V{ { 1 100 } } }
       { uses V{
             T{ vreg-use
                { n 88 }
                { use-rep int-rep }
                { spill-slot? t }
             }
         }
       }
    } ;

! active-positions
{
    LH{ { RAX 23 } }
} [
    f machine-registers init-allocator
    H{ { 20 int-rep } } representations set
    test-live-interval2 [ add-active ] keep
    <linked-hash> [ active-positions ] keep
] unit-test

! assign-spill
{ T{ spill-slot f 0 } } [
    f f <basic-block> <cfg> cfg set
    H{ } clone spill-slots set
    H{ { 45 double-2-rep } } representations set
    test-live-interval assign-spill
    { 45 8 } spill-slots get at
] unit-test

! find-next-use

! inactive-positions
{ LH{ } } [
    H{ { 10 int-rep } } representations set
    T{ live-interval-state { vreg 10 } } <linked-hash>
    [ inactive-positions ] keep
] unit-test

! last-use-rep
{ double-rep } [
    test-live-interval last-use-rep
] unit-test

! spill-before
{ f } [
    30 <live-interval> spill-before
] unit-test

! spill-status

:: make-one-use-interval ( n -- live-interval )
    10 RAX f f f f V{ { 1 100 } } n f int-rep f vreg-use boa 1vector
    live-interval-state boa ;

{
    { RAX 5 }
} [
    f machine-registers init-allocator
    H{ { 10 int-rep } } representations set
    10 make-one-use-interval add-active
    5 make-one-use-interval add-inactive
    20 make-one-use-interval spill-status
] unit-test

{
    { RAX 23 }
} [
    f machine-registers init-allocator
    H{ { 10 int-rep } } representations set
    23 make-one-use-interval [ add-active ] keep
    spill-status
] unit-test

{
    { RBX 28 }
} [
    f machine-registers init-allocator
    H{ { 20 int-rep } { 45 int-rep } } representations set
    test-live-interval2 [ add-active ] keep
    test-live-interval add-inactive spill-status
] unit-test

{
    { RCX 1/0. }
} [
    f machine-registers init-allocator
    H{ { 20 int-rep } { 45 int-rep } { 21 int-rep } } representations set
    test-live-interval3 add-active test-live-interval2 spill-status
] unit-test

! trim-after-ranges
{
    T{ live-interval-state
       { ranges V{ { 25 30 } { 40 50 } } }
       { uses V{ T{ vreg-use { n 25 } } } }
    }
} [
    T{ live-interval-state
       { ranges V{ { 0 10 } { 20 30 } { 40 50 } } }
       { uses V{ T{ vreg-use { n 25 } } } }
    } dup trim-after-ranges
] unit-test

{
    T{ live-interval-state
       { ranges V{ { 10 23 } } }
       { uses V{ T{ vreg-use { n 10 } } } }
    }
} [
    T{ live-interval-state
       { ranges V{ { 20 23 } } }
       { uses V{ T{ vreg-use { n 10 } } } }
    }
    dup trim-after-ranges
] unit-test

! trim-before-ranges
{
    T{ live-interval-state
       { ranges V{ { 0 10 } { 20 21 } } }
       { uses V{ T{ vreg-use { n 20 } } } }
    }
} [
    T{ live-interval-state
       { ranges V{ { 0 10 } { 20 30 } { 40 50 } } }
       { uses V{ T{ vreg-use { n 20 } } } }
    } dup trim-before-ranges
] unit-test
