USING: tools.test random sorting sequences sets hashtables assocs
kernel fry arrays splitting namespaces math accessors vectors locals
math.order grouping strings strings.private classes layouts
cpu.architecture
compiler.cfg
compiler.cfg.optimizer
compiler.cfg.instructions
compiler.cfg.registers
compiler.cfg.predecessors
compiler.cfg.rpo
compiler.cfg.linearization
compiler.cfg.debugger
compiler.cfg.def-use
compiler.cfg.comparisons
compiler.cfg.linear-scan
compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.debugger ;
FROM: namespaces => set ;
IN: compiler.cfg.linear-scan.tests

check-allocation? on
check-numbering? on

[
    { T{ live-range f 1 10 } T{ live-range f 15 15 } }
    { T{ live-range f 16 20 } }
] [
    {
        T{ live-range f 1 10 }
        T{ live-range f 15 20 }
    } 15 split-ranges
] unit-test

[
    { T{ live-range f 1 10 } T{ live-range f 15 16 } }
    { T{ live-range f 17 20 } }
] [
    {
        T{ live-range f 1 10 }
        T{ live-range f 15 20 }
    } 16 split-ranges
] unit-test

[
    { T{ live-range f 1 10 } }
    { T{ live-range f 15 20 } }
] [
    {
        T{ live-range f 1 10 }
        T{ live-range f 15 20 }
    } 12 split-ranges
] unit-test

[
    { T{ live-range f 1 10 } T{ live-range f 15 17 } }
    { T{ live-range f 18 20 } }
] [
    {
        T{ live-range f 1 10 }
        T{ live-range f 15 20 }
    } 17 split-ranges
] unit-test

[
    { T{ live-range f 1 10 } } 0 split-ranges
] must-fail

[
    { T{ live-range f 0 0 } }
    { T{ live-range f 1 5 } }
] [
    { T{ live-range f 0 5 } } 0 split-ranges
] unit-test

cfg new 0 >>spill-area-size cfg set
H{ } spill-slots set

H{
    { 1 float-rep }
    { 2 float-rep }
    { 3 float-rep }
} representations set

[
    T{ live-interval
       { vreg 1 }
       { reg-class float-regs }
       { start 0 }
       { end 2 }
       { uses V{ T{ vreg-use f float-rep 0 } T{ vreg-use f float-rep 1 } } }
       { ranges V{ T{ live-range f 0 2 } } }
       { spill-to T{ spill-slot f 0 } }
    }
    T{ live-interval
       { vreg 1 }
       { reg-class float-regs }
       { start 5 }
       { end 5 }
       { uses V{ T{ vreg-use f float-rep 5 } } }
       { ranges V{ T{ live-range f 5 5 } } }
       { reload-from T{ spill-slot f 0 } }
    }
] [
    T{ live-interval
       { vreg 1 }
       { reg-class float-regs }
       { start 0 }
       { end 5 }
       { uses V{ T{ vreg-use f float-rep 0 } T{ vreg-use f float-rep 1 } T{ vreg-use f float-rep 5 } } }
       { ranges V{ T{ live-range f 0 5 } } }
    } 2 split-for-spill
] unit-test

[
    T{ live-interval
       { vreg 2 }
       { reg-class float-regs }
       { start 0 }
       { end 1 }
       { uses V{ T{ vreg-use f float-rep 0 } } }
       { ranges V{ T{ live-range f 0 1 } } }
       { spill-to T{ spill-slot f 4 } }
    }
    T{ live-interval
       { vreg 2 }
       { reg-class float-regs }
       { start 1 }
       { end 5 }
       { uses V{ T{ vreg-use f float-rep 1 } T{ vreg-use f float-rep 5 } } }
       { ranges V{ T{ live-range f 1 5 } } }
       { reload-from T{ spill-slot f 4 } }
    }
] [
    T{ live-interval
       { vreg 2 }
       { reg-class float-regs }
       { start 0 }
       { end 5 }
       { uses V{ T{ vreg-use f float-rep 0 } T{ vreg-use f float-rep 1 } T{ vreg-use f float-rep 5 } } }
       { ranges V{ T{ live-range f 0 5 } } }
    } 0 split-for-spill
] unit-test

[
    T{ live-interval
       { vreg 3 }
       { reg-class float-regs }
       { start 0 }
       { end 1 }
       { uses V{ T{ vreg-use f float-rep 0 } } }
       { ranges V{ T{ live-range f 0 1 } } }
       { spill-to T{ spill-slot f 8 } }
    }
    T{ live-interval
       { vreg 3 }
       { reg-class float-regs }
       { start 20 }
       { end 30 }
       { uses V{ T{ vreg-use f float-rep 20 } T{ vreg-use f float-rep 30 } } }
       { ranges V{ T{ live-range f 20 30 } } }
       { reload-from T{ spill-slot f 8 } }
    }
] [
    T{ live-interval
       { vreg 3 }
       { reg-class float-regs }
       { start 0 }
       { end 30 }
       { uses V{ T{ vreg-use f float-rep 0 } T{ vreg-use f float-rep 20 } T{ vreg-use f float-rep 30 } } }
       { ranges V{ T{ live-range f 0 8 } T{ live-range f 10 18 } T{ live-range f 20 30 } } }
    } 10 split-for-spill
] unit-test

H{
    { 1 int-rep }
    { 2 int-rep }
    { 3 int-rep }
} representations set

[
    {
        3
        10
    }
] [
    H{
        { int-regs
          V{
              T{ live-interval
                 { vreg 1 }
                 { reg-class int-regs }
                 { reg 1 }
                 { start 1 }
                 { end 15 }
                 { uses V{ T{ vreg-use f int-rep 1 } T{ vreg-use f int-rep 3 } T{ vreg-use f int-rep 7 } T{ vreg-use f int-rep 10 } T{ vreg-use f int-rep 15 } } }
              }
              T{ live-interval
                 { vreg 2 }
                 { reg-class int-regs }
                 { reg 2 }
                 { start 3 }
                 { end 8 }
                 { uses V{ T{ vreg-use f int-rep 3 } T{ vreg-use f int-rep 4 } T{ vreg-use f int-rep 8 } } }
              }
              T{ live-interval
                 { vreg 3 }
                 { reg-class int-regs }
                 { reg 3 }
                 { start 3 }
                 { end 10 }
                 { uses V{ T{ vreg-use f int-rep 3 } T{ vreg-use f int-rep 10 } } }
              }
          }
        }
    } active-intervals set
    H{ } inactive-intervals set
    T{ live-interval
        { vreg 1 }
        { reg-class int-regs }
        { start 5 }
        { end 5 }
        { uses V{ T{ vreg-use f int-rep 5 } } }
    }
    spill-status
] unit-test

[
    {
        1
        1/0.
    }
] [
    H{
        { int-regs
          V{
              T{ live-interval
                 { vreg 1 }
                 { reg-class int-regs }
                 { reg 1 }
                 { start 1 }
                 { end 15 }
                 { uses V{ T{ vreg-use f int-rep 1 } } }
              }
              T{ live-interval
                 { vreg 2 }
                 { reg-class int-regs }
                 { reg 2 }
                 { start 3 }
                 { end 8 }
                 { uses V{ T{ vreg-use f int-rep 3 } T{ vreg-use f int-rep 8 } } }
              }
          }
        }
    } active-intervals set
    H{ } inactive-intervals set
    T{ live-interval
        { vreg 3 }
        { reg-class int-regs }
        { start 5 }
        { end 5 }
        { uses V{ T{ vreg-use f int-rep 5 } } }
    }
    spill-status
] unit-test

H{ { 1 int-rep } { 2 int-rep } } representations set

[ ] [
    {
        T{ live-interval
           { vreg 1 }
           { reg-class int-regs }
           { start 0 }
           { end 100 }
           { uses V{ T{ vreg-use f int-rep 0 } T{ vreg-use f int-rep 100 } } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[ ] [
    {
        T{ live-interval
           { vreg 1 }
           { reg-class int-regs }
           { start 0 }
           { end 10 }
           { uses V{ T{ vreg-use f int-rep 0 } T{ vreg-use f int-rep 10 } } }
           { ranges V{ T{ live-range f 0 10 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 11 }
           { end 20 }
           { uses V{ T{ vreg-use f int-rep 11 } T{ vreg-use f int-rep 20 } } }
           { ranges V{ T{ live-range f 11 20 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[ ] [
    {
        T{ live-interval
           { vreg 1 }
           { reg-class int-regs }
           { start 0 }
           { end 100 }
           { uses V{ T{ vreg-use f int-rep 0 } T{ vreg-use f int-rep 100 } } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 30 }
           { end 60 }
           { uses V{ T{ vreg-use f int-rep 30 } T{ vreg-use f int-rep 60 } } }
           { ranges V{ T{ live-range f 30 60 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[ ] [
    {
        T{ live-interval
           { vreg 1 }
           { reg-class int-regs }
           { start 0 }
           { end 100 }
           { uses V{ T{ vreg-use f int-rep 0 } T{ vreg-use f int-rep 100 } } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 30 }
           { end 200 }
           { uses V{ T{ vreg-use f int-rep 30 } T{ vreg-use f int-rep 200 } } }
           { ranges V{ T{ live-range f 30 200 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[
    {
        T{ live-interval
           { vreg 1 }
           { reg-class int-regs }
           { start 0 }
           { end 100 }
           { uses V{ T{ vreg-use f int-rep 0 } T{ vreg-use f int-rep 100 } } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 30 }
           { end 100 }
           { uses V{ T{ vreg-use f int-rep 30 } T{ vreg-use f int-rep 100 } } }
           { ranges V{ T{ live-range f 30 100 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] must-fail

! Problem with spilling intervals with no more usages after the spill location
H{
    { 1 int-rep }
    { 2 int-rep }
    { 3 int-rep }
    { 4 int-rep }
    { 5 int-rep }
} representations set

[ ] [
    {
        T{ live-interval
           { vreg 1 }
           { reg-class int-regs }
           { start 0 }
           { end 20 }
           { uses V{ T{ vreg-use f int-rep 0 } T{ vreg-use f int-rep 10 } T{ vreg-use f int-rep 20 } } }
           { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 0 }
           { end 20 }
           { uses V{ T{ vreg-use f int-rep 0 } T{ vreg-use f int-rep 10 } T{ vreg-use f int-rep 20 } } }
           { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
        }
        T{ live-interval
           { vreg 3 }
           { reg-class int-regs }
           { start 4 }
           { end 8 }
           { uses V{ T{ vreg-use f int-rep 6 } } }
           { ranges V{ T{ live-range f 4 8 } } }
        }
        T{ live-interval
           { vreg 4 }
           { reg-class int-regs }
           { start 4 }
           { end 8 }
           { uses V{ T{ vreg-use f int-rep 8 } } }
           { ranges V{ T{ live-range f 4 8 } } }
        }

        ! This guy will invoke the 'spill partially available' code path
        T{ live-interval
           { vreg 5 }
           { reg-class int-regs }
           { start 4 }
           { end 8 }
           { uses V{ T{ vreg-use f int-rep 8 } } }
           { ranges V{ T{ live-range f 4 8 } } }
        }
    }
    H{ { int-regs { "A" "B" } } }
    check-linear-scan
] unit-test

! Test spill-new code path

[ ] [
    {
        T{ live-interval
           { vreg 1 }
           { reg-class int-regs }
           { start 0 }
           { end 10 }
           { uses V{ T{ vreg-use f int-rep 0 } T{ vreg-use f int-rep 6 } T{ vreg-use f int-rep 10 } } }
           { ranges V{ T{ live-range f 0 10 } } }
        }

        ! This guy will invoke the 'spill new' code path
        T{ live-interval
           { vreg 5 }
           { reg-class int-regs }
           { start 2 }
           { end 8 }
           { uses V{ T{ vreg-use f int-rep 8 } } }
           { ranges V{ T{ live-range f 2 8 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[ f ] [
    T{ live-range f 0 10 }
    T{ live-range f 20 30 }
    intersect-live-range
] unit-test

[ 10 ] [
    T{ live-range f 0 10 }
    T{ live-range f 10 30 }
    intersect-live-range
] unit-test

[ 5 ] [
    T{ live-range f 0 10 }
    T{ live-range f 5 30 }
    intersect-live-range
] unit-test

[ 5 ] [
    T{ live-range f 5 30 }
    T{ live-range f 0 10 }
    intersect-live-range
] unit-test

[ 5 ] [
    T{ live-range f 5 10 }
    T{ live-range f 0 15 }
    intersect-live-range
] unit-test

[ 50 ] [
    {
        T{ live-range f 0 10 }
        T{ live-range f 20 30 }
        T{ live-range f 40 50 }
    }
    {
        T{ live-range f 11 15 }
        T{ live-range f 31 35 }
        T{ live-range f 50 55 }
    }
    intersect-live-ranges
] unit-test

[ f ] [
    {
        T{ live-range f 0 10 }
        T{ live-range f 20 30 }
        T{ live-range f 40 50 }
    }
    {
        T{ live-range f 11 15 }
        T{ live-range f 31 36 }
        T{ live-range f 51 55 }
    }
    intersect-live-ranges
] unit-test

[ 5 ] [
    T{ live-interval
       { start 0 }
       { reg-class int-regs }
       { end 10 }
       { uses { 0 10 } }
       { ranges V{ T{ live-range f 0 10 } } }
    }
    T{ live-interval
       { start 5 }
       { reg-class int-regs }
       { end 10 }
       { uses { 5 10 } }
       { ranges V{ T{ live-range f 5 10 } } }
    }
    relevant-ranges intersect-live-ranges
] unit-test

! register-status had problems because it used map>assoc where the sequence
! had multiple keys
H{
    { 1 int-rep }
    { 2 int-rep }
    { 3 int-rep }
    { 4 int-rep }
} representations set

[ { 0 10 } ] [
    H{ { int-regs { 0 1 } } } registers set
    H{
        { int-regs
          {
              T{ live-interval
                 { vreg 1 }
                 { reg-class int-regs }
                 { start 0 }
                 { end 20 }
                 { reg 0 }
                 { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
                 { uses V{ 0 2 10 20 } }
              }

              T{ live-interval
                 { vreg 2 }
                 { reg-class int-regs }
                 { start 4 }
                 { end 40 }
                 { reg 0 }
                 { ranges V{ T{ live-range f 4 6 } T{ live-range f 30 40 } } }
                 { uses V{ 4 6 30 40 } }
              }
          }
        }
    } inactive-intervals set
    H{
        { int-regs
          {
              T{ live-interval
                 { vreg 3 }
                 { reg-class int-regs }
                 { start 0 }
                 { end 40 }
                 { reg 1 }
                 { ranges V{ T{ live-range f 0 40 } } }
                 { uses V{ 0 40 } }
              }
          }
        }
    } active-intervals set

    T{ live-interval
        { vreg 4 }
        { reg-class int-regs }
        { start 8 }
        { end 10 }
        { ranges V{ T{ live-range f 8 10 } } }
        { uses V{ T{ vreg-use f int-rep 8 } T{ vreg-use f int-rep 10 } } }
    }
    register-status
] unit-test
