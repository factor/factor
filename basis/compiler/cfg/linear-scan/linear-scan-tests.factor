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
compiler.cfg.debugger
compiler.cfg.def-use
compiler.cfg.comparisons
compiler.cfg.ssa.destruction.leaders
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

! Live interval calculation

! A value is defined and never used; make sure it has the right
! live range
V{
    T{ ##load-integer f 1 0 }
    T{ ##replace-imm f D 0 "hi" }
    T{ ##branch }
} 0 test-bb

: test-live-intervals ( -- )
    cfg new 0 get >>entry
    [ cfg set ] [ number-instructions ] [ compute-live-intervals ] tri
    2drop ;

[ ] [
    H{
        { 1 int-rep }
    } representations set
    H{
        { 1 1 }
    } leader-map set
    test-live-intervals
] unit-test

[ 0 0 ] [
    1 live-intervals get at [ start>> ] [ end>> ] bi
] unit-test

! Live range and interval splitting
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

cfg new 0 >>spill-area-size 4 >>spill-area-align cfg set
H{ } spill-slots set

H{
    { 1 float-rep }
    { 2 float-rep }
    { 3 float-rep }
} representations set

: clean-up-split ( a b -- a b )
    [ dup [ [ >vector ] change-uses [ >vector ] change-ranges ] when ] bi@ ;

[
    T{ live-interval
       { vreg 1 }
       { reg-class float-regs }
       { start 0 }
       { end 2 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 1 f float-rep } } }
       { ranges V{ T{ live-range f 0 2 } } }
       { spill-to T{ spill-slot f 0 } }
       { spill-rep float-rep }
    }
    T{ live-interval
       { vreg 1 }
       { reg-class float-regs }
       { start 5 }
       { end 5 }
       { uses V{ T{ vreg-use f 5 f float-rep } } }
       { ranges V{ T{ live-range f 5 5 } } }
       { reload-from T{ spill-slot f 0 } }
       { reload-rep float-rep }
    }
] [
    T{ live-interval
       { vreg 1 }
       { reg-class float-regs }
       { start 0 }
       { end 5 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 1 f float-rep } T{ vreg-use f 5 f float-rep } } }
       { ranges V{ T{ live-range f 0 5 } } }
    } 2 split-for-spill
    clean-up-split
] unit-test

[
    f
    T{ live-interval
       { vreg 2 }
       { reg-class float-regs }
       { start 1 }
       { end 5 }
       { uses V{ T{ vreg-use f 1 f float-rep } T{ vreg-use f 5 f float-rep } } }
       { ranges V{ T{ live-range f 1 5 } } }
       { reload-from T{ spill-slot f 4 } }
       { reload-rep float-rep }
    }
] [
    T{ live-interval
       { vreg 2 }
       { reg-class float-regs }
       { start 0 }
       { end 5 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 1 f float-rep } T{ vreg-use f 5 f float-rep } } }
       { ranges V{ T{ live-range f 0 5 } } }
    } 0 split-for-spill
    clean-up-split
] unit-test

[
    T{ live-interval
       { vreg 3 }
       { reg-class float-regs }
       { start 0 }
       { end 2 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 1 f float-rep } } }
       { ranges V{ T{ live-range f 0 2 } } }
       { spill-to T{ spill-slot f 8 } }
       { spill-rep float-rep }
    }
    f
] [
    T{ live-interval
       { vreg 3 }
       { reg-class float-regs }
       { start 0 }
       { end 5 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 1 f float-rep } T{ vreg-use f 5 f float-rep } } }
       { ranges V{ T{ live-range f 0 5 } } }
    } 5 split-for-spill
    clean-up-split
] unit-test

[
    T{ live-interval
       { vreg 4 }
       { reg-class float-regs }
       { start 0 }
       { end 1 }
       { uses V{ T{ vreg-use f 0 float-rep f } } }
       { ranges V{ T{ live-range f 0 1 } } }
       { spill-to T{ spill-slot f 12 } }
       { spill-rep float-rep }
    }
    T{ live-interval
       { vreg 4 }
       { reg-class float-regs }
       { start 20 }
       { end 30 }
       { uses V{ T{ vreg-use f 20 f float-rep } T{ vreg-use f 30 f float-rep } } }
       { ranges V{ T{ live-range f 20 30 } } }
       { reload-from T{ spill-slot f 12 } }
       { reload-rep float-rep }
    }
] [
    T{ live-interval
       { vreg 4 }
       { reg-class float-regs }
       { start 0 }
       { end 30 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 20 f float-rep } T{ vreg-use f 30 f float-rep } } }
       { ranges V{ T{ live-range f 0 8 } T{ live-range f 10 18 } T{ live-range f 20 30 } } }
    } 10 split-for-spill
    clean-up-split
] unit-test

! Don't insert reload if first usage is a def
[
    T{ live-interval
       { vreg 5 }
       { reg-class float-regs }
       { start 0 }
       { end 1 }
       { uses V{ T{ vreg-use f 0 float-rep f } } }
       { ranges V{ T{ live-range f 0 1 } } }
       { spill-to T{ spill-slot f 16 } }
       { spill-rep float-rep }
    }
    T{ live-interval
       { vreg 5 }
       { reg-class float-regs }
       { start 20 }
       { end 30 }
       { uses V{ T{ vreg-use f 20 float-rep f } T{ vreg-use f 30 f float-rep } } }
       { ranges V{ T{ live-range f 20 30 } } }
    }
] [
    T{ live-interval
       { vreg 5 }
       { reg-class float-regs }
       { start 0 }
       { end 30 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 20 float-rep f } T{ vreg-use f 30 f float-rep } } }
       { ranges V{ T{ live-range f 0 8 } T{ live-range f 10 18 } T{ live-range f 20 30 } } }
    } 10 split-for-spill
    clean-up-split
] unit-test

! Multiple representations
[
    T{ live-interval
       { vreg 6 }
       { reg-class float-regs }
       { start 0 }
       { end 11 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 10 double-rep float-rep } } }
       { ranges V{ T{ live-range f 0 11 } } }
       { spill-to T{ spill-slot f 24 } }
       { spill-rep double-rep }
    }
    T{ live-interval
       { vreg 6 }
       { reg-class float-regs }
       { start 20 }
       { end 20 }
       { uses V{ T{ vreg-use f 20 f double-rep } } }
       { ranges V{ T{ live-range f 20 20 } } }
       { reload-from T{ spill-slot f 24 } }
       { reload-rep double-rep }
    }
] [
    T{ live-interval
       { vreg 6 }
       { reg-class float-regs }
       { start 0 }
       { end 20 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 10 double-rep float-rep } T{ vreg-use f 20 f double-rep } } }
       { ranges V{ T{ live-range f 0 20 } } }
    } 15 split-for-spill
    clean-up-split
] unit-test

[
    f
    T{ live-interval
        { vreg 7 }
        { start 8 }
        { end 8 }
        { ranges V{ T{ live-range f 8 8 } } }
        { uses V{ T{ vreg-use f 8 int-rep } } }
        { reg-class int-regs }
    }
] [
    T{ live-interval
        { vreg 7 }
        { start 4 }
        { end 8 }
        { ranges V{ T{ live-range f 4 8 } } }
        { uses V{ T{ vreg-use f 8 int-rep } } }
        { reg-class int-regs }
    } 4 split-for-spill
    clean-up-split
] unit-test

! trim-before-ranges, trim-after-ranges
[
    T{ live-interval
        { vreg 8 }
        { start 0 }
        { end 3 }
        { ranges V{ T{ live-range f 0 3 } } }
        { uses V{ T{ vreg-use f 0 f int-rep } T{ vreg-use f 2 f int-rep } } }
        { reg-class int-regs }
        { spill-to T{ spill-slot f 32 } }
        { spill-rep int-rep }
    }
    T{ live-interval
        { vreg 8 }
        { start 14 }
        { end 16 }
        { ranges V{ T{ live-range f 14 16 } } }
        { uses V{ T{ vreg-use f 14 f int-rep } } }
        { reg-class int-regs }
        { reload-from T{ spill-slot f 32 } }
        { reload-rep int-rep }
    }
] [
    T{ live-interval
        { vreg 8 }
        { start 0 }
        { end 16 }
        { ranges V{ T{ live-range f 0 4 } T{ live-range f 6 10 } T{ live-range f 12 16 } } }
        { uses V{ T{ vreg-use f 0 f int-rep } T{ vreg-use f 2 f int-rep } T{ vreg-use f 14 f int-rep } } }
        { reg-class int-regs }
    } 8 split-for-spill
    clean-up-split
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
                 { uses V{ T{ vreg-use f 1 int-rep f } T{ vreg-use f 3 f int-rep } T{ vreg-use f 7 f int-rep } T{ vreg-use f 10 f int-rep } T{ vreg-use f 15 f int-rep } } }
              }
              T{ live-interval
                 { vreg 2 }
                 { reg-class int-regs }
                 { reg 2 }
                 { start 3 }
                 { end 8 }
                 { uses V{ T{ vreg-use f 3 int-rep f } T{ vreg-use f 4 f int-rep } T{ vreg-use f 8 f int-rep } } }
              }
              T{ live-interval
                 { vreg 3 }
                 { reg-class int-regs }
                 { reg 3 }
                 { start 3 }
                 { end 10 }
                 { uses V{ T{ vreg-use f 3 int-rep f } T{ vreg-use f 10 f int-rep } } }
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
        { uses V{ T{ vreg-use f 5 int-rep f } } }
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
                 { uses V{ T{ vreg-use f 1 int-rep f } } }
              }
              T{ live-interval
                 { vreg 2 }
                 { reg-class int-regs }
                 { reg 2 }
                 { start 3 }
                 { end 8 }
                 { uses V{ T{ vreg-use f 3 int-rep f } T{ vreg-use f 8 f int-rep } } }
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
        { uses V{ T{ vreg-use f 5 int-rep f } } }
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
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 100 f int-rep } } }
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
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 10 f int-rep } } }
           { ranges V{ T{ live-range f 0 10 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 11 }
           { end 20 }
           { uses V{ T{ vreg-use f 11 int-rep f } T{ vreg-use f 20 f int-rep } } }
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
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 100 f int-rep } } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 30 }
           { end 60 }
           { uses V{ T{ vreg-use f 30 int-rep f } T{ vreg-use f 60 f int-rep } } }
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
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 100 f int-rep } } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 30 }
           { end 200 }
           { uses V{ T{ vreg-use f 30 int-rep f } T{ vreg-use f 200 f int-rep } } }
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
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 100 f int-rep } } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 30 }
           { end 100 }
           { uses V{ T{ vreg-use f 30 int-rep f } T{ vreg-use f 100 f int-rep } } }
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
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 10 f int-rep } T{ vreg-use f 20 f int-rep } } }
           { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
        }
        T{ live-interval
           { vreg 2 }
           { reg-class int-regs }
           { start 0 }
           { end 20 }
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 10 f int-rep } T{ vreg-use f 20 f int-rep } } }
           { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
        }
        T{ live-interval
           { vreg 3 }
           { reg-class int-regs }
           { start 4 }
           { end 8 }
           { uses V{ T{ vreg-use f 6 int-rep f } } }
           { ranges V{ T{ live-range f 4 8 } } }
        }
        T{ live-interval
           { vreg 4 }
           { reg-class int-regs }
           { start 4 }
           { end 8 }
           { uses V{ T{ vreg-use f 8 int-rep f } } }
           { ranges V{ T{ live-range f 4 8 } } }
        }

        ! This guy will invoke the 'spill partially available' code path
        T{ live-interval
           { vreg 5 }
           { reg-class int-regs }
           { start 4 }
           { end 8 }
           { uses V{ T{ vreg-use f 8 int-rep f } } }
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
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 6 f int-rep } T{ vreg-use f 10 f int-rep } } }
           { ranges V{ T{ live-range f 0 10 } } }
        }

        ! This guy will invoke the 'spill new' code path
        T{ live-interval
           { vreg 5 }
           { reg-class int-regs }
           { start 2 }
           { end 8 }
           { uses V{ T{ vreg-use f 8 int-rep f } } }
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
        { uses V{ T{ vreg-use f 8 int-rep f } T{ vreg-use f 10 f int-rep } } }
    }
    register-status
] unit-test
