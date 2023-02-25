USING: tools.test random sorting sequences hashtables assocs
kernel arrays splitting namespaces math accessors vectors
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
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.ranges
compiler.cfg.linear-scan.debugger
compiler.cfg.utilities ;
IN: compiler.cfg.linear-scan.tests

check-allocation? on
check-numbering? on

! Live interval calculation
: test-live-intervals ( -- )
    ! A value is defined and never used; make sure it has the right
    ! live range
    {
        T{ ##load-integer f 1 0 }
        T{ ##replace-imm f D: 0 "hi" }
        T{ ##branch }
    } insns>cfg
    [ cfg set ] [ number-instructions ] [ compute-live-intervals ] tri
    drop ;

{ } [
    H{
        { 1 int-rep }
    } representations set
    H{
        { 1 1 }
    } leader-map set
    test-live-intervals
] unit-test

{ 0 0 } [
    1 live-intervals get at ranges>> ranges-endpoints
] unit-test

! Live interval splitting
{ } insns>cfg [ stack-frame>> 4 >>spill-area-align drop ] keep cfg set
H{ } spill-slots set

H{
    { 1 float-rep }
    { 2 float-rep }
    { 3 float-rep }
} representations set

: clean-up-split ( a b -- a b )
    [ [ [ >vector ] change-uses [ >vector ] change-ranges ] ?call ] bi@ ;

{
    T{ live-interval-state
       { vreg 1 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 1 f float-rep } } }
       { ranges V{ { 0 2 } } }
       { spill-to T{ spill-slot f 0 } }
       { spill-rep float-rep }
    }
    T{ live-interval-state
       { vreg 1 }
       { uses V{ T{ vreg-use f 5 f float-rep } } }
       { ranges V{ { 5 5 } } }
       { reload-from T{ spill-slot f 0 } }
       { reload-rep float-rep }
    }
} [
    T{ live-interval-state
       { vreg 1 }
       { uses
         V{
             T{ vreg-use f 0 float-rep f }
             T{ vreg-use f 1 f float-rep }
             T{ vreg-use f 5 f float-rep }
         }
       }
       { ranges V{ { 0 5 } } }
    } 2 split-for-spill
    clean-up-split
] unit-test

{
    f
    T{ live-interval-state
       { vreg 2 }
       { uses V{ T{ vreg-use f 1 f float-rep } T{ vreg-use f 5 f float-rep } } }
       { ranges V{ { 1 5 } } }
       { reload-from T{ spill-slot f 4 } }
       { reload-rep float-rep }
    }
} [
    T{ live-interval-state
       { vreg 2 }
       { uses
         V{
             T{ vreg-use f 0 float-rep f }
             T{ vreg-use f 1 f float-rep }
             T{ vreg-use f 5 f float-rep }
         }
       }
       { ranges V{ { 0 5 } } }
    } 0 split-for-spill
    clean-up-split
] unit-test

{
    T{ live-interval-state
       { vreg 3 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 1 f float-rep } } }
       { ranges V{ { 0 2 } } }
       { spill-to T{ spill-slot f 8 } }
       { spill-rep float-rep }
    }
    f
} [
    T{ live-interval-state
       { vreg 3 }
       { uses
         V{
             T{ vreg-use f 0 float-rep f }
             T{ vreg-use f 1 f float-rep }
             T{ vreg-use f 5 f float-rep }
         }
       }
       { ranges V{ { 0 5 } } }
    } 5 split-for-spill
    clean-up-split
] unit-test

{
    T{ live-interval-state
       { vreg 4 }
       { uses V{ T{ vreg-use f 0 float-rep f } } }
       { ranges V{ { 0 1 } } }
       { spill-to T{ spill-slot f 12 } }
       { spill-rep float-rep }
    }
    T{ live-interval-state
       { vreg 4 }
       { uses V{ T{ vreg-use f 20 f float-rep } T{ vreg-use f 30 f float-rep } } }
       { ranges V{ { 20 30 } } }
       { reload-from T{ spill-slot f 12 } }
       { reload-rep float-rep }
    }
} [
    T{ live-interval-state
       { vreg 4 }
       { uses
         V{
             T{ vreg-use f 0 float-rep f }
             T{ vreg-use f 20 f float-rep }
             T{ vreg-use f 30 f float-rep }
         }
       }
       { ranges V{ { 0 8 } { 10 18 } { 20 30 } } }
    } 10 split-for-spill
    clean-up-split
] unit-test

! Don't insert reload if first usage is a def
{
    T{ live-interval-state
       { vreg 5 }
       { uses V{ T{ vreg-use f 0 float-rep f } } }
       { ranges V{ { 0 1 } } }
       { spill-to T{ spill-slot f 16 } }
       { spill-rep float-rep }
    }
    T{ live-interval-state
       { vreg 5 }
       { uses V{ T{ vreg-use f 20 float-rep f } T{ vreg-use f 30 f float-rep } } }
       { ranges V{ { 20 30 } } }
    }
} [
    T{ live-interval-state
       { vreg 5 }
       { uses
         V{
             T{ vreg-use f 0 float-rep f }
             T{ vreg-use f 20 float-rep f }
             T{ vreg-use f 30 f float-rep }
         }
       }
       { ranges V{ { 0 8 } { 10 18 } { 20 30 } } }
    } 10 split-for-spill
    clean-up-split
] unit-test

! Multiple representations
{
    T{ live-interval-state
       { vreg 6 }
       { uses V{ T{ vreg-use f 0 float-rep f } T{ vreg-use f 10 double-rep float-rep } } }
       { ranges V{ { 0 11 } } }
       { spill-to T{ spill-slot f 24 } }
       { spill-rep double-rep }
    }
    T{ live-interval-state
       { vreg 6 }
       { uses V{ T{ vreg-use f 20 f double-rep } } }
       { ranges V{ { 20 20 } } }
       { reload-from T{ spill-slot f 24 } }
       { reload-rep double-rep }
    }
} [
    T{ live-interval-state
       { vreg 6 }
       { uses
         V{
             T{ vreg-use f 0 float-rep f }
             T{ vreg-use f 10 double-rep float-rep }
             T{ vreg-use f 20 f double-rep }
         }
       }
       { ranges V{ { 0 20 } } }
    } 15 split-for-spill
    clean-up-split
] unit-test

{
    f
    T{ live-interval-state
        { vreg 7 }
        { ranges V{ { 8 8 } } }
        { uses V{ T{ vreg-use f 8 int-rep } } }
    }
} [
    T{ live-interval-state
        { vreg 7 }
        { ranges V{ { 4 8 } } }
        { uses V{ T{ vreg-use f 8 int-rep } } }
    } 4 split-for-spill
    clean-up-split
] unit-test

! trim-before-ranges, trim-after-ranges
{
    T{ live-interval-state
        { vreg 8 }
        { ranges V{ { 0 3 } } }
        { uses V{ T{ vreg-use f 0 f int-rep } T{ vreg-use f 2 f int-rep } } }
        { spill-to T{ spill-slot f 32 } }
        { spill-rep int-rep }
    }
    T{ live-interval-state
        { vreg 8 }
        { ranges V{ { 14 16 } } }
        { uses V{ T{ vreg-use f 14 f int-rep } } }
        { reload-from T{ spill-slot f 32 } }
        { reload-rep int-rep }
    }
} [
    T{ live-interval-state
        { vreg 8 }
        { ranges V{ { 0 4 } { 6 10 } { 12 16 } } }
        { uses
          V{
              T{ vreg-use f 0 f int-rep }
              T{ vreg-use f 2 f int-rep }
              T{ vreg-use f 14 f int-rep } }
        }
    } 8 split-for-spill
    clean-up-split
] unit-test

H{
    { 1 int-rep }
    { 2 int-rep }
    { 3 int-rep }
} representations set

{
    {
        3
        10
    }
} [
    H{
        { int-regs
          V{
              T{ live-interval-state
                 { vreg 1 }
                 { reg 1 }
                 { ranges V{ { 1 15 } } }
                 { uses
                   V{
                       T{ vreg-use f 1 int-rep f }
                       T{ vreg-use f 3 f int-rep }
                       T{ vreg-use f 7 f int-rep }
                       T{ vreg-use f 10 f int-rep }
                       T{ vreg-use f 15 f int-rep }
                   }
                 }
              }
              T{ live-interval-state
                 { vreg 2 }
                 { reg 2 }
                 { ranges V{ { 3 8 } } }
                 { uses
                   V{
                       T{ vreg-use f 3 int-rep f }
                       T{ vreg-use f 4 f int-rep }
                       T{ vreg-use f 8 f int-rep }
                   }
                 }
              }
              T{ live-interval-state
                 { vreg 3 }
                 { reg 3 }
                 { ranges V{ { 3 10 } } }
                 { uses V{ T{ vreg-use f 3 int-rep f } T{ vreg-use f 10 f int-rep } } }
              }
          }
        }
    } active-intervals set
    H{ } inactive-intervals set
    T{ live-interval-state
       { vreg 1 }
       { ranges V{ { 5 5 } } }
       { uses V{ T{ vreg-use f 5 int-rep f } } }
    }
    spill-status
] unit-test

{
    {
        1
        1/0.
    }
} [
    H{
        { int-regs
          V{
              T{ live-interval-state
                 { vreg 1 }
                 { reg 1 }
                 { ranges V{ { 1 15 } } }
                 { uses V{ T{ vreg-use f 1 int-rep f } } }
              }
              T{ live-interval-state
                 { vreg 2 }
                 { reg 2 }
                 { uses V{ T{ vreg-use f 3 int-rep f } T{ vreg-use f 8 f int-rep } } }
              }
          }
        }
    } active-intervals set
    H{ } inactive-intervals set
    T{ live-interval-state
       { vreg 3 }
       { ranges V{ { 5 5 } } }
       { uses V{ T{ vreg-use f 5 int-rep f } } }
    }
    spill-status
] unit-test

H{ { 1 int-rep } { 2 int-rep } } representations set

{ } [
    {
        T{ live-interval-state
           { vreg 1 }
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 100 f int-rep } } }
           { ranges V{ { 0 100 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

{ } [
    {
        T{ live-interval-state
           { vreg 1 }
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 10 f int-rep } } }
           { ranges V{ { 0 10 } } }
        }
        T{ live-interval-state
           { vreg 2 }
           { uses V{ T{ vreg-use f 11 int-rep f } T{ vreg-use f 20 f int-rep } } }
           { ranges V{ { 11 20 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

{ } [
    {
        T{ live-interval-state
           { vreg 1 }
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 100 f int-rep } } }
           { ranges V{ { 0 100 } } }
        }
        T{ live-interval-state
           { vreg 2 }
           { uses V{ T{ vreg-use f 30 int-rep f } T{ vreg-use f 60 f int-rep } } }
           { ranges V{ { 30 60 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

{ } [
    {
        T{ live-interval-state
           { vreg 1 }
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 100 f int-rep } } }
           { ranges V{ { 0 100 } } }
        }
        T{ live-interval-state
           { vreg 2 }
           { uses V{ T{ vreg-use f 30 int-rep f } T{ vreg-use f 200 f int-rep } } }
           { ranges V{ { 30 200 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[
    {
        T{ live-interval-state
           { vreg 1 }
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 100 f int-rep } } }
           { ranges V{ { 0 100 } } }
        }
        T{ live-interval-state
           { vreg 2 }
           { uses V{ T{ vreg-use f 30 int-rep f } T{ vreg-use f 100 f int-rep } } }
           { ranges V{ { 30 100 } } }
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

{ } [
    {
        T{ live-interval-state
           { vreg 1 }
           { uses
             V{
                 T{ vreg-use f 0 int-rep f }
                 T{ vreg-use f 10 f int-rep }
                 T{ vreg-use f 20 f int-rep }
             }
           }
           { ranges V{ { 0 2 } { 10 20 } } }
        }
        T{ live-interval-state
           { vreg 2 }
           { uses
             V{
                 T{ vreg-use f 0 int-rep f }
                 T{ vreg-use f 10 f int-rep }
                 T{ vreg-use f 20 f int-rep }
             }
           }
           { ranges V{ { 0 2 } { 10 20 } } }
        }
        T{ live-interval-state
           { vreg 3 }
           { uses V{ T{ vreg-use f 6 int-rep f } } }
           { ranges V{ { 4 8 } } }
        }
        T{ live-interval-state
           { vreg 4 }
           { uses V{ T{ vreg-use f 8 int-rep f } } }
           { ranges V{ { 4 8 } } }
        }

        ! This guy will invoke the 'spill partially available' code path
        T{ live-interval-state
           { vreg 5 }
           { uses V{ T{ vreg-use f 8 int-rep f } } }
           { ranges V{ { 4 8 } } }
        }
    }
    H{ { int-regs { "A" "B" } } }
    check-linear-scan
] unit-test

! Test spill-new code path

{ } [
    {
        T{ live-interval-state
           { vreg 1 }
           { uses V{ T{ vreg-use f 0 int-rep f } T{ vreg-use f 6 f int-rep } T{ vreg-use f 10 f int-rep } } }
           { ranges V{ { 0 10 } } }
        }

        ! This guy will invoke the 'spill new' code path
        T{ live-interval-state
           { vreg 5 }
           { uses V{ T{ vreg-use f 8 int-rep f } } }
           { ranges V{ { 2 8 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

! register-status had problems because it used map>assoc where the sequence
! had multiple keys
H{
    { 1 int-rep }
    { 2 int-rep }
    { 3 int-rep }
    { 4 int-rep }
} representations set

{ { 0 10 } } [
    H{
        { int-regs
          {
              T{ live-interval-state
                 { vreg 1 }
                 { reg 0 }
                 { ranges V{ { 0 2 } { 10 20 } } }
                 { uses V{ 0 2 10 20 } }
              }

              T{ live-interval-state
                 { vreg 2 }
                 { reg 0 }
                 { ranges V{ { 4 6 } { 30 40 } } }
                 { uses V{ 4 6 30 40 } }
              }
          }
        }
    } inactive-intervals set
    H{
        { int-regs
          {
              T{ live-interval-state
                 { vreg 3 }
                 { reg 1 }
                 { ranges V{ { 0 40 } } }
                 { uses V{ 0 40 } }
              }
          }
        }
    } active-intervals set

    T{ live-interval-state
        { vreg 4 }
        { ranges V{ { 8 10 } } }
        { uses V{ T{ vreg-use f 8 int-rep f } T{ vreg-use f 10 f int-rep } } }
    }
    H{ { int-regs { 0 1 } } } register-status
] unit-test

{ t } [
    T{ cfg { frame-pointer? f } } admissible-registers machine-registers =
] unit-test

{ f } [
    T{ cfg { frame-pointer? t } } admissible-registers
    int-regs of frame-reg swap member?
] unit-test
