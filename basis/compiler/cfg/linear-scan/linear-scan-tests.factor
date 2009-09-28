IN: compiler.cfg.linear-scan.tests
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
       { start 0 }
       { end 2 }
       { uses V{ 0 1 } }
       { ranges V{ T{ live-range f 0 2 } } }
       { spill-to T{ spill-slot f 0 } }
    }
    T{ live-interval
       { vreg 1 }
       { start 5 }
       { end 5 }
       { uses V{ 5 } }
       { ranges V{ T{ live-range f 5 5 } } }
       { reload-from T{ spill-slot f 0 } }
    }
] [
    T{ live-interval
       { vreg 1 }
       { start 0 }
       { end 5 }
       { uses V{ 0 1 5 } }
       { ranges V{ T{ live-range f 0 5 } } }
    } 2 split-for-spill
] unit-test

[
    T{ live-interval
       { vreg 2 }
       { start 0 }
       { end 1 }
       { uses V{ 0 } }
       { ranges V{ T{ live-range f 0 1 } } }
       { spill-to T{ spill-slot f 4 } }
    }
    T{ live-interval
       { vreg 2 }
       { start 1 }
       { end 5 }
       { uses V{ 1 5 } }
       { ranges V{ T{ live-range f 1 5 } } }
       { reload-from T{ spill-slot f 4 } }
    }
] [
    T{ live-interval
       { vreg 2 }
       { start 0 }
       { end 5 }
       { uses V{ 0 1 5 } }
       { ranges V{ T{ live-range f 0 5 } } }
    } 0 split-for-spill
] unit-test

[
    T{ live-interval
       { vreg 3 }
       { start 0 }
       { end 1 }
       { uses V{ 0 } }
       { ranges V{ T{ live-range f 0 1 } } }
       { spill-to T{ spill-slot f 8 } }
    }
    T{ live-interval
       { vreg 3 }
       { start 20 }
       { end 30 }
       { uses V{ 20 30 } }
       { ranges V{ T{ live-range f 20 30 } } }
       { reload-from T{ spill-slot f 8 } }
    }
] [
    T{ live-interval
       { vreg 3 }
       { start 0 }
       { end 30 }
       { uses V{ 0 20 30 } }
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
                 { reg 1 }
                 { start 1 }
                 { end 15 }
                 { uses V{ 1 3 7 10 15 } }
              }
              T{ live-interval
                 { vreg 2 }
                 { reg 2 }
                 { start 3 }
                 { end 8 }
                 { uses V{ 3 4 8 } }
              }
              T{ live-interval
                 { vreg 3 }
                 { reg 3 }
                 { start 3 }
                 { end 10 }
                 { uses V{ 3 10 } }
              }
          }
        }
    } active-intervals set
    H{ } inactive-intervals set
    T{ live-interval
        { vreg 1 }
        { start 5 }
        { end 5 }
        { uses V{ 5 } }
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
                 { reg 1 }
                 { start 1 }
                 { end 15 }
                 { uses V{ 1 } }
              }
              T{ live-interval
                 { vreg 2 }
                 { reg 2 }
                 { start 3 }
                 { end 8 }
                 { uses V{ 3 8 } }
              }
          }
        }
    } active-intervals set
    H{ } inactive-intervals set
    T{ live-interval
        { vreg 3 }
        { start 5 }
        { end 5 }
        { uses V{ 5 } }
    }
    spill-status
] unit-test

H{ { 1 int-rep } { 2 int-rep } } representations set

[ ] [
    {
        T{ live-interval
           { vreg 1 }
           { start 0 }
           { end 100 }
           { uses V{ 0 100 } }
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
           { start 0 }
           { end 10 }
           { uses V{ 0 10 } }
           { ranges V{ T{ live-range f 0 10 } } }
        }
        T{ live-interval
           { vreg 2 }
           { start 11 }
           { end 20 }
           { uses V{ 11 20 } }
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
           { start 0 }
           { end 100 }
           { uses V{ 0 100 } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg 2 }
           { start 30 }
           { end 60 }
           { uses V{ 30 60 } }
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
           { start 0 }
           { end 100 }
           { uses V{ 0 100 } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg 2 }
           { start 30 }
           { end 200 }
           { uses V{ 30 200 } }
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
           { start 0 }
           { end 100 }
           { uses V{ 0 100 } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg 2 }
           { start 30 }
           { end 100 }
           { uses V{ 30 100 } }
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
           { start 0 }
           { end 20 }
           { uses V{ 0 10 20 } }
           { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
        }
        T{ live-interval
           { vreg 2 }
           { start 0 }
           { end 20 }
           { uses V{ 0 10 20 } }
           { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
        }
        T{ live-interval
           { vreg 3 }
           { start 4 }
           { end 8 }
           { uses V{ 6 } }
           { ranges V{ T{ live-range f 4 8 } } }
        }
        T{ live-interval
           { vreg 4 }
           { start 4 }
           { end 8 }
           { uses V{ 8 } }
           { ranges V{ T{ live-range f 4 8 } } }
        }

        ! This guy will invoke the 'spill partially available' code path
        T{ live-interval
           { vreg 5 }
           { start 4 }
           { end 8 }
           { uses V{ 8 } }
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
           { start 0 }
           { end 10 }
           { uses V{ 0 6 10 } }
           { ranges V{ T{ live-range f 0 10 } } }
        }

        ! This guy will invoke the 'spill new' code path
        T{ live-interval
           { vreg 5 }
           { start 2 }
           { end 8 }
           { uses V{ 8 } }
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
       { end 10 }
       { uses { 0 10 } }
       { ranges V{ T{ live-range f 0 10 } } }
    }
    T{ live-interval
       { start 5 }
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
                 { start 0 }
                 { end 20 }
                 { reg 0 }
                 { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
                 { uses V{ 0 2 10 20 } }
              }

              T{ live-interval
                 { vreg 2 }
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
        { start 8 }
        { end 10 }
        { ranges V{ T{ live-range f 8 10 } } }
        { uses V{ 8 10 } }
    }
    register-status
] unit-test

:: test-linear-scan-on-cfg ( regs -- )
    [
        cfg new 0 get >>entry
        dup cfg set
        dup fake-representations
        dup { { int-regs regs } } (linear-scan)
        flatten-cfg 1array mr.
    ] with-scope ;

! Bug in live spill slots calculation

V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##peek
       { dst 703128 }
       { loc D 1 }
    }
    T{ ##peek
       { dst 703129 }
       { loc D 0 }
    }
    T{ ##copy
       { dst 703134 }
       { src 703128 }
    }
    T{ ##copy
       { dst 703135 }
       { src 703129 }
    }
    T{ ##compare-imm-branch
       { src1 703128 }
       { src2 5 }
       { cc cc/= }
    }
} 1 test-bb

V{
    T{ ##copy
       { dst 703134 }
       { src 703129 }
    }
    T{ ##copy
       { dst 703135 }
       { src 703128 }
    }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace
       { src 703134 }
       { loc D 0 }
    }
    T{ ##replace
       { src 703135 }
       { loc D 1 }
    }
    T{ ##epilogue }
    T{ ##return }
} 3 test-bb

0 1 edge
1 { 2 3 } edges
2 3 edge

! Bug in inactive interval handling
! [ rot dup [ -rot ] when ]
V{ T{ ##prologue } T{ ##branch } } 0 test-bb
    
V{
    T{ ##peek
       { dst 689473 }
       { loc D 2 }
    }
    T{ ##peek
       { dst 689474 }
       { loc D 1 }
    }
    T{ ##peek
       { dst 689475 }
       { loc D 0 }
    }
    T{ ##compare-imm-branch
       { src1 689473 }
       { src2 5 }
       { cc cc/= }
    }
} 1 test-bb

V{
    T{ ##copy
       { dst 689481 }
       { src 689475 }
       { rep int-rep }
    }
    T{ ##copy
       { dst 689482 }
       { src 689474 }
       { rep int-rep }
    }
    T{ ##copy
       { dst 689483 }
       { src 689473 }
       { rep int-rep }
    }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##copy
       { dst 689481 }
       { src 689473 }
       { rep int-rep }
    }
    T{ ##copy
       { dst 689482 }
       { src 689475 }
       { rep int-rep }
    }
    T{ ##copy
       { dst 689483 }
       { src 689474 }
       { rep int-rep }
    }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace
       { src 689481 }
       { loc D 0 }
    }
    T{ ##replace
       { src 689482 }
       { loc D 1 }
    }
    T{ ##replace
       { src 689483 }
       { loc D 2 }
    }
    T{ ##epilogue }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 3 4 } test-linear-scan-on-cfg ] unit-test

! Similar to the above
! [ swap dup [ rot ] when ]

T{ basic-block
   { id 201537 }
   { number 0 }
   { instructions V{ T{ ##prologue } T{ ##branch } } }
} 0 set
    
V{
    T{ ##peek
       { dst 689600 }
       { loc D 1 }
    }
    T{ ##peek
       { dst 689601 }
       { loc D 0 }
    }
    T{ ##compare-imm-branch
       { src1 689600 }
       { src2 5 }
       { cc cc/= }
    }
} 1 test-bb
    
V{
    T{ ##peek
       { dst 689604 }
       { loc D 2 }
    }
    T{ ##copy
       { dst 689607 }
       { src 689604 }
    }
    T{ ##copy
       { dst 689608 }
       { src 689600 }
       { rep int-rep }
    }
    T{ ##copy
       { dst 689610 }
       { src 689601 }
       { rep int-rep }
    }
    T{ ##branch }
} 2 test-bb
    
V{
    T{ ##peek
       { dst 689609 }
       { loc D 2 }
    }
    T{ ##copy
       { dst 689607 }
       { src 689600 }
       { rep int-rep }
    }
    T{ ##copy
       { dst 689608 }
       { src 689601 }
       { rep int-rep }
    }
    T{ ##copy
       { dst 689610 }
       { src 689609 }
       { rep int-rep }
    }
    T{ ##branch }
} 3 test-bb
    
V{
    T{ ##replace
       { src 689607 }
       { loc D 0 }
    }
    T{ ##replace
       { src 689608 }
       { loc D 1 }
    }
    T{ ##replace
       { src 689610 }
       { loc D 2 }
    }
    T{ ##epilogue }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 3 4 } test-linear-scan-on-cfg ] unit-test

! compute-live-registers was inaccurate since it didn't take
! lifetime holes into account

V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##peek
       { dst 0 }
       { loc D 0 }
    }
    T{ ##compare-imm-branch
       { src1 0 }
       { src2 5 }
       { cc cc/= }
    }
} 1 test-bb

V{
    T{ ##peek
       { dst 1 }
       { loc D 1 }
    }
    T{ ##copy
       { dst 2 }
       { src 1 }
       { rep int-rep }
    }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##peek
       { dst 3 }
       { loc D 2 }
    }
    T{ ##copy
       { dst 2 }
       { src 3 }
       { rep int-rep }
    }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace
       { src 2 }
       { loc D 0 }
    }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 3 4 } test-linear-scan-on-cfg ] unit-test

! Inactive interval handling: splitting active interval
! if it fits in lifetime hole only partially

V{ T{ ##peek f 3 R 1 } T{ ##branch } } 0 test-bb

V{
    T{ ##peek f 2 R 0 }
    T{ ##compare-imm-branch f 2 5 cc= }
} 1 test-bb

V{
    T{ ##peek f 0 D 0 }
    T{ ##branch }
} 2 test-bb


V{
    T{ ##peek f 1 D 1 }
    T{ ##peek f 0 D 0 }
    T{ ##replace f 1 D 2 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f 3 R 2 }
    T{ ##replace f 0 D 0 }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

! Not until splitting is finished
! [ _copy ] [ 3 get instructions>> second class ] unit-test

! Resolve pass; make sure the spilling is done correctly
V{ T{ ##peek f 3 R 1 } T{ ##branch } } 0 test-bb

V{
    T{ ##peek f 2 R 0 }
    T{ ##compare-imm-branch f 2 5 cc= }
} 1 test-bb

V{
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f 3 R 1 }
    T{ ##peek f 1 D 1 }
    T{ ##peek f 0 D 0 }
    T{ ##replace f 1 D 2 }
    T{ ##replace f 0 D 2 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f 3 R 2 }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

[ _spill ] [ 2 get successors>> first instructions>> first class ] unit-test

[ _spill ] [ 3 get instructions>> second class ] unit-test

[ f ] [ 3 get instructions>> [ _reload? ] any? ] unit-test

[ _reload ] [ 4 get instructions>> first class ] unit-test

! Resolve pass
V{
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 0 D 0 }
    T{ ##compare-imm-branch f 0 5 cc= }
} 1 test-bb

V{
    T{ ##replace f 0 D 0 }
    T{ ##peek f 1 D 0 }
    T{ ##peek f 2 D 0 }
    T{ ##replace f 1 D 0 }
    T{ ##replace f 2 D 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##peek f 1 D 0 }
    T{ ##compare-imm-branch f 1 5 cc= }
} 4 test-bb

V{
    T{ ##replace f 0 D 0 }
    T{ ##return }
} 5 test-bb

V{
    T{ ##replace f 0 D 0 }
    T{ ##return }
} 6 test-bb

0 1 edge
1 { 2 3 } edges
2 4 edge
3 4 edge
4 { 5 6 } edges

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

[ t ] [ 2 get instructions>> [ _spill? ] any? ] unit-test

[ t ] [ 3 get predecessors>> first instructions>> [ _spill? ] any? ] unit-test

[ t ] [ 5 get instructions>> [ _reload? ] any? ] unit-test

! A more complicated failure case with resolve that came up after the above
! got fixed
V{ T{ ##branch } } 0 test-bb
V{
    T{ ##peek f 0 D 0 }
    T{ ##peek f 1 D 1 }
    T{ ##peek f 2 D 2 }
    T{ ##peek f 3 D 3 }
    T{ ##peek f 4 D 0 }
    T{ ##branch }
} 1 test-bb
V{ T{ ##branch } } 2 test-bb
V{ T{ ##branch } } 3 test-bb
V{
    
    T{ ##replace f 1 D 1 }
    T{ ##replace f 2 D 2 }
    T{ ##replace f 3 D 3 }
    T{ ##replace f 4 D 4 }
    T{ ##replace f 0 D 0 }
    T{ ##branch }
} 4 test-bb
V{ T{ ##replace f 0 D 0 } T{ ##branch } } 5 test-bb
V{ T{ ##return } } 6 test-bb
V{ T{ ##branch } } 7 test-bb
V{
    T{ ##replace f 1 D 1 }
    T{ ##replace f 2 D 2 }
    T{ ##replace f 3 D 3 }
    T{ ##peek f 5 D 1 }
    T{ ##peek f 6 D 2 }
    T{ ##peek f 7 D 3 }
    T{ ##peek f 8 D 4 }
    T{ ##replace f 5 D 1 }
    T{ ##replace f 6 D 2 }
    T{ ##replace f 7 D 3 }
    T{ ##replace f 8 D 4 }
    T{ ##branch }
} 8 test-bb
V{
    T{ ##replace f 1 D 1 }
    T{ ##replace f 2 D 2 }
    T{ ##replace f 3 D 3 }
    T{ ##return }
} 9 test-bb

0 1 edge
1 { 2 7 } edges
7 8 edge
8 9 edge
2 { 3 5 } edges
3 4 edge
4 9 edge
5 6 edge

[ ] [ { 1 2 3 4 } test-linear-scan-on-cfg ] unit-test

[ _spill ] [ 1 get instructions>> second class ] unit-test
[ _reload ] [ 4 get instructions>> 4 swap nth class ] unit-test
[ V{ 3 2 1 } ] [ 8 get instructions>> [ _spill? ] filter [ dst>> n>> cell / ] map ] unit-test
[ V{ 3 2 1 } ] [ 9 get instructions>> [ _reload? ] filter [ src>> n>> cell / ] map ] unit-test

! Resolve pass should insert this
[ _reload ] [ 5 get predecessors>> first instructions>> first class ] unit-test

! Some random bug
V{
    T{ ##peek f 1 D 1 }
    T{ ##peek f 2 D 2 }
    T{ ##replace f 1 D 1 }
    T{ ##replace f 2 D 2 }
    T{ ##peek f 3 D 0 }
    T{ ##peek f 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{
    T{ ##peek f 1 D 1 }
    T{ ##peek f 2 D 2 }
    T{ ##replace f 3 D 3 }
    T{ ##replace f 1 D 1 }
    T{ ##replace f 2 D 2 }
    T{ ##replace f 0 D 3 }
    T{ ##branch }
} 2 test-bb

V{ T{ ##branch } } 3 test-bb

V{
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

! Spilling an interval immediately after its activated;
! and the interval does not have a use at the activation point
V{
    T{ ##peek f 1 D 1 }
    T{ ##peek f 2 D 2 }
    T{ ##replace f 1 D 1 }
    T{ ##replace f 2 D 2 }
    T{ ##peek f 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{
    T{ ##peek f 1 D 1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f 1 D 1 }
    T{ ##peek f 2 D 2 }
    T{ ##replace f 2 D 2 }
    T{ ##branch }
} 3 test-bb

V{ T{ ##branch } } 4 test-bb

V{
    T{ ##replace f 0 D 0 }
    T{ ##return }
} 5 test-bb

0 1 edge
1 { 2 4 } edges
4 5 edge
2 3 edge
3 5 edge

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

! Reduction of push-all regression, x86-32
V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##load-immediate { dst 61 } }
    T{ ##peek { dst 62 } { loc D 0 } }
    T{ ##peek { dst 64 } { loc D 1 } }
    T{ ##slot-imm
        { dst 69 }
        { obj 64 }
        { slot 1 }
        { tag 2 }
    }
    T{ ##copy { dst 79 } { src 69 } { rep int-rep } }
    T{ ##slot-imm
        { dst 85 }
        { obj 62 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##compare-branch
        { src1 69 }
        { src2 85 }
        { cc cc> }
    }
} 1 test-bb

V{
    T{ ##slot-imm
        { dst 97 }
        { obj 62 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##replace { src 79 } { loc D 3 } }
    T{ ##replace { src 62 } { loc D 4 } }
    T{ ##replace { src 79 } { loc D 1 } }
    T{ ##replace { src 62 } { loc D 2 } }
    T{ ##replace { src 61 } { loc D 5 } }
    T{ ##replace { src 62 } { loc R 0 } }
    T{ ##replace { src 69 } { loc R 1 } }
    T{ ##replace { src 97 } { loc D 0 } }
    T{ ##call { word resize-array } }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##peek { dst 98 } { loc R 0 } }
    T{ ##peek { dst 100 } { loc D 0 } }
    T{ ##set-slot-imm
        { src 100 }
        { obj 98 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##peek { dst 108 } { loc D 2 } }
    T{ ##peek { dst 110 } { loc D 3 } }
    T{ ##peek { dst 112 } { loc D 0 } }
    T{ ##peek { dst 114 } { loc D 1 } }
    T{ ##peek { dst 116 } { loc D 4 } }
    T{ ##peek { dst 119 } { loc R 0 } }
    T{ ##copy { dst 109 } { src 108 } { rep int-rep } }
    T{ ##copy { dst 111 } { src 110 } { rep int-rep } }
    T{ ##copy { dst 113 } { src 112 } { rep int-rep } }
    T{ ##copy { dst 115 } { src 114 } { rep int-rep } }
    T{ ##copy { dst 117 } { src 116 } { rep int-rep } }
    T{ ##copy { dst 120 } { src 119 } { rep int-rep } }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##copy { dst 109 } { src 62 } { rep int-rep } }
    T{ ##copy { dst 111 } { src 61 } { rep int-rep } }
    T{ ##copy { dst 113 } { src 62 } { rep int-rep } }
    T{ ##copy { dst 115 } { src 79 } { rep int-rep } }
    T{ ##copy { dst 117 } { src 64 } { rep int-rep } }
    T{ ##copy { dst 120 } { src 69 } { rep int-rep } }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##replace { src 120 } { loc D 0 } }
    T{ ##replace { src 109 } { loc D 3 } }
    T{ ##replace { src 111 } { loc D 4 } }
    T{ ##replace { src 113 } { loc D 1 } }
    T{ ##replace { src 115 } { loc D 2 } }
    T{ ##replace { src 117 } { loc D 5 } }
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

0 1 edge
1 { 2 4 } edges
2 3 edge
3 5 edge
4 5 edge

[ ] [ { 1 2 3 4 5 } test-linear-scan-on-cfg ] unit-test

! Another reduction of push-all
V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##peek { dst 85 } { loc D 0 } }
    T{ ##slot-imm
        { dst 89 }
        { obj 85 }
        { slot 3 }
        { tag 7 }
    }
    T{ ##peek { dst 91 } { loc D 1 } }
    T{ ##slot-imm
        { dst 96 }
        { obj 91 }
        { slot 1 }
        { tag 2 }
    }
    T{ ##add
        { dst 109 }
        { src1 89 }
        { src2 96 }
    }
    T{ ##slot-imm
        { dst 115 }
        { obj 85 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##slot-imm
        { dst 118 }
        { obj 115 }
        { slot 1 }
        { tag 2 }
    }
    T{ ##compare-branch
        { src1 109 }
        { src2 118 }
        { cc cc> }
    }
} 1 test-bb

V{
    T{ ##add-imm
        { dst 128 }
        { src1 109 }
        { src2 8 }
    }
    T{ ##load-immediate { dst 129 } { val 24 } }
    T{ ##inc-d { n 4 } }
    T{ ##inc-r { n 1 } }
    T{ ##replace { src 109 } { loc D 2 } }
    T{ ##replace { src 85 } { loc D 3 } }
    T{ ##replace { src 128 } { loc D 0 } }
    T{ ##replace { src 85 } { loc D 1 } }
    T{ ##replace { src 89 } { loc D 4 } }
    T{ ##replace { src 96 } { loc R 0 } }
    T{ ##replace { src 129 } { loc R 0 } }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##peek { dst 134 } { loc D 1 } }
    T{ ##slot-imm
        { dst 140 }
        { obj 134 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##inc-d { n 1 } }
    T{ ##inc-r { n 1 } }
    T{ ##replace { src 140 } { loc D 0 } }
    T{ ##replace { src 134 } { loc R 0 } }
    T{ ##call { word resize-array } }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##peek { dst 141 } { loc R 0 } }
    T{ ##peek { dst 143 } { loc D 0 } }
    T{ ##set-slot-imm
        { src 143 }
        { obj 141 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##write-barrier
        { src 141 }
        { card# 145 }
        { table 146 }
    }
    T{ ##inc-d { n -1 } }
    T{ ##inc-r { n -1 } }
    T{ ##peek { dst 156 } { loc D 2 } }
    T{ ##peek { dst 158 } { loc D 3 } }
    T{ ##peek { dst 160 } { loc D 0 } }
    T{ ##peek { dst 162 } { loc D 1 } }
    T{ ##peek { dst 164 } { loc D 4 } }
    T{ ##peek { dst 167 } { loc R 0 } }
    T{ ##copy { dst 157 } { src 156 } { rep int-rep } }
    T{ ##copy { dst 159 } { src 158 } { rep int-rep } }
    T{ ##copy { dst 161 } { src 160 } { rep int-rep } }
    T{ ##copy { dst 163 } { src 162 } { rep int-rep } }
    T{ ##copy { dst 165 } { src 164 } { rep int-rep } }
    T{ ##copy { dst 168 } { src 167 } { rep int-rep } }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##inc-d { n 3 } }
    T{ ##inc-r { n 1 } }
    T{ ##copy { dst 157 } { src 85 } }
    T{ ##copy { dst 159 } { src 89 } }
    T{ ##copy { dst 161 } { src 85 } }
    T{ ##copy { dst 163 } { src 109 } }
    T{ ##copy { dst 165 } { src 91 } }
    T{ ##copy { dst 168 } { src 96 } }
    T{ ##branch }
} 5 test-bb

V{
    T{ ##set-slot-imm
        { src 163 }
        { obj 161 }
        { slot 3 }
        { tag 7 }
    }
    T{ ##inc-d { n 1 } }
    T{ ##inc-r { n -1 } }
    T{ ##replace { src 168 } { loc D 0 } }
    T{ ##replace { src 157 } { loc D 3 } }
    T{ ##replace { src 159 } { loc D 4 } }
    T{ ##replace { src 161 } { loc D 1 } }
    T{ ##replace { src 163 } { loc D 2 } }
    T{ ##replace { src 165 } { loc D 5 } }
    T{ ##epilogue }
    T{ ##return }
} 6 test-bb

0 1 edge
1 { 2 5 } edges
2 3 edge
3 4 edge
4 6 edge
5 6 edge

[ ] [ { 1 2 3 4 5 } test-linear-scan-on-cfg ] unit-test

! Fencepost error in assignment pass
V{ T{ ##branch } } 0 test-bb

V{
    T{ ##peek f 0 D 0 }
    T{ ##compare-imm-branch f 0 5 cc= }
} 1 test-bb

V{ T{ ##branch } } 2 test-bb

V{
    T{ ##peek f 1 D 0 }
    T{ ##peek f 2 D 0 }
    T{ ##replace f 1 D 0 }
    T{ ##replace f 2 D 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f 0 D 0 }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

[ 0 ] [ 1 get instructions>> [ _spill? ] count ] unit-test

[ 1 ] [ 2 get instructions>> [ _spill? ] count ] unit-test

[ 1 ] [ 3 get predecessors>> first instructions>> [ _spill? ] count ] unit-test

[ 1 ] [ 4 get instructions>> [ _reload? ] count ] unit-test

! Another test case for fencepost error in assignment pass
V{ T{ ##branch } } 0 test-bb

V{
    T{ ##peek f 0 D 0 }
    T{ ##compare-imm-branch f 0 5 cc= }
} 1 test-bb

V{
    T{ ##peek f 1 D 0 }
    T{ ##peek f 2 D 0 }
    T{ ##replace f 1 D 0 }
    T{ ##replace f 2 D 0 }
    T{ ##replace f 0 D 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f 0 D 0 }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

[ 0 ] [ 1 get instructions>> [ _spill? ] count ] unit-test

[ 1 ] [ 2 get instructions>> [ _spill? ] count ] unit-test

[ 1 ] [ 2 get instructions>> [ _reload? ] count ] unit-test

[ 0 ] [ 3 get instructions>> [ _spill? ] count ] unit-test

[ 0 ] [ 4 get instructions>> [ _reload? ] count ] unit-test

V{
    T{ ##peek f 0 D 0 }
    T{ ##peek f 1 D 1 }
    T{ ##replace f 1 D 1 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##gc f 2 3 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##replace f 0 D 0 }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

[ ] [ { 1 2 3 } test-linear-scan-on-cfg ] unit-test

[ { 1 } ] [ 1 get instructions>> first tagged-values>> ] unit-test

V{
    T{ ##peek f 0 D 0 }
    T{ ##peek f 1 D 1 }
    T{ ##compare-imm-branch f 1 5 cc= }
} 0 test-bb

V{
    T{ ##gc f 2 3 }
    T{ ##replace f 0 D 0 }
    T{ ##return }
} 1 test-bb

V{
    T{ ##return }
} 2 test-bb

0 { 1 2 } edges

[ ] [ { 1 2 3 } test-linear-scan-on-cfg ] unit-test

[ { 1 } ] [ 1 get instructions>> first tagged-values>> ] unit-test
