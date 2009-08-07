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

[
    T{ live-interval
       { vreg V single-float-rep 1 }
       { start 0 }
       { end 2 }
       { uses V{ 0 1 } }
       { ranges V{ T{ live-range f 0 2 } } }
       { spill-to 0 }
    }
    T{ live-interval
       { vreg V single-float-rep 1 }
       { start 5 }
       { end 5 }
       { uses V{ 5 } }
       { ranges V{ T{ live-range f 5 5 } } }
       { reload-from 0 }
    }
] [
    T{ live-interval
       { vreg V single-float-rep 1 }
       { start 0 }
       { end 5 }
       { uses V{ 0 1 5 } }
       { ranges V{ T{ live-range f 0 5 } } }
    } 2 split-for-spill
] unit-test

[
    T{ live-interval
       { vreg V single-float-rep 2 }
       { start 0 }
       { end 1 }
       { uses V{ 0 } }
       { ranges V{ T{ live-range f 0 1 } } }
       { spill-to 4 }
    }
    T{ live-interval
       { vreg V single-float-rep 2 }
       { start 1 }
       { end 5 }
       { uses V{ 1 5 } }
       { ranges V{ T{ live-range f 1 5 } } }
       { reload-from 4 }
    }
] [
    T{ live-interval
       { vreg V single-float-rep 2 }
       { start 0 }
       { end 5 }
       { uses V{ 0 1 5 } }
       { ranges V{ T{ live-range f 0 5 } } }
    } 0 split-for-spill
] unit-test

[
    T{ live-interval
       { vreg V single-float-rep 3 }
       { start 0 }
       { end 1 }
       { uses V{ 0 } }
       { ranges V{ T{ live-range f 0 1 } } }
       { spill-to 8 }
    }
    T{ live-interval
       { vreg V single-float-rep 3 }
       { start 20 }
       { end 30 }
       { uses V{ 20 30 } }
       { ranges V{ T{ live-range f 20 30 } } }
       { reload-from 8 }
    }
] [
    T{ live-interval
       { vreg V single-float-rep 3 }
       { start 0 }
       { end 30 }
       { uses V{ 0 20 30 } }
       { ranges V{ T{ live-range f 0 8 } T{ live-range f 10 18 } T{ live-range f 20 30 } } }
    } 10 split-for-spill
] unit-test

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
                 { vreg V int-rep 1 }
                 { reg 1 }
                 { start 1 }
                 { end 15 }
                 { uses V{ 1 3 7 10 15 } }
              }
              T{ live-interval
                 { vreg V int-rep 2 }
                 { reg 2 }
                 { start 3 }
                 { end 8 }
                 { uses V{ 3 4 8 } }
              }
              T{ live-interval
                 { vreg V int-rep 3 }
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
        { vreg V int-rep 1 }
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
                 { vreg V int-rep 1 }
                 { reg 1 }
                 { start 1 }
                 { end 15 }
                 { uses V{ 1 } }
              }
              T{ live-interval
                 { vreg V int-rep 2 }
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
        { vreg V int-rep 3 }
        { start 5 }
        { end 5 }
        { uses V{ 5 } }
    }
    spill-status
] unit-test

[ ] [
    {
        T{ live-interval
           { vreg V int-rep 1 }
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
           { vreg V int-rep 1 }
           { start 0 }
           { end 10 }
           { uses V{ 0 10 } }
           { ranges V{ T{ live-range f 0 10 } } }
        }
        T{ live-interval
           { vreg V int-rep 2 }
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
           { vreg V int-rep 1 }
           { start 0 }
           { end 100 }
           { uses V{ 0 100 } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg V int-rep 2 }
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
           { vreg V int-rep 1 }
           { start 0 }
           { end 100 }
           { uses V{ 0 100 } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg V int-rep 2 }
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
           { vreg V int-rep 1 }
           { start 0 }
           { end 100 }
           { uses V{ 0 100 } }
           { ranges V{ T{ live-range f 0 100 } } }
        }
        T{ live-interval
           { vreg V int-rep 2 }
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

[ ] [
    {
        T{ live-interval
           { vreg V int-rep 1 }
           { start 0 }
           { end 20 }
           { uses V{ 0 10 20 } }
           { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
        }
        T{ live-interval
           { vreg V int-rep 2 }
           { start 0 }
           { end 20 }
           { uses V{ 0 10 20 } }
           { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
        }
        T{ live-interval
           { vreg V int-rep 3 }
           { start 4 }
           { end 8 }
           { uses V{ 6 } }
           { ranges V{ T{ live-range f 4 8 } } }
        }
        T{ live-interval
           { vreg V int-rep 4 }
           { start 4 }
           { end 8 }
           { uses V{ 8 } }
           { ranges V{ T{ live-range f 4 8 } } }
        }

        ! This guy will invoke the 'spill partially available' code path
        T{ live-interval
           { vreg V int-rep 5 }
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
           { vreg V int-rep 1 }
           { start 0 }
           { end 10 }
           { uses V{ 0 6 10 } }
           { ranges V{ T{ live-range f 0 10 } } }
        }

        ! This guy will invoke the 'spill new' code path
        T{ live-interval
           { vreg V int-rep 5 }
           { start 2 }
           { end 8 }
           { uses V{ 8 } }
           { ranges V{ T{ live-range f 2 8 } } }
        }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

SYMBOL: available

SYMBOL: taken

SYMBOL: max-registers

SYMBOL: max-insns

SYMBOL: max-uses

: not-taken ( -- n )
    available get keys dup empty? [ "Oops" throw ] when
    random
    dup taken get nth 1 + max-registers get = [
        dup available get delete-at
    ] [
        dup taken get [ 1 + ] change-nth
    ] if ;

: random-live-intervals ( num-intervals max-uses max-registers max-insns -- seq )
    [
        max-insns set
        max-registers set
        max-uses set
        max-insns get [ 0 ] replicate taken set
        max-insns get [ dup ] H{ } map>assoc available set
        [
            \ live-interval new
                swap int-rep swap vreg boa >>vreg
                max-uses get random 2 max [ not-taken 2 * ] replicate natural-sort
                [ >>uses ] [ first >>start ] bi
                dup uses>> last >>end
                dup [ start>> ] [ end>> ] bi <live-range> 1vector >>ranges
        ] map
    ] with-scope ;

: random-test ( num-intervals max-uses max-registers max-insns -- )
    over [ random-live-intervals ] dip int-regs associate check-linear-scan ;

[ ] [ 30 2 1 60 random-test ] unit-test
[ ] [ 60 2 2 60 random-test ] unit-test
[ ] [ 80 2 3 200 random-test ] unit-test
[ ] [ 70 2 5 30 random-test ] unit-test
[ ] [ 60 2 6 30 random-test ] unit-test
[ ] [ 1 2 10 10 random-test ] unit-test

[ ] [ 10 4 2 60 random-test ] unit-test
[ ] [ 10 20 2 400 random-test ] unit-test
[ ] [ 10 20 4 300 random-test ] unit-test

USING: math.private ;

[ ] [
    [ float+ float>fixnum 3 fixnum*fast ]
    test-cfg first optimize-cfg linear-scan drop
] unit-test

: fake-live-ranges ( seq -- seq' )
    [
        clone dup [ start>> ] [ end>> ] bi <live-range> 1vector >>ranges
    ] map ;

[ ] [
    {
        T{ live-interval
            { vreg V int-rep 70 }
            { start 14 }
            { end 17 }
            { uses V{ 14 15 16 17 } }
        }
        T{ live-interval
            { vreg V int-rep 67 }
            { start 13 }
            { end 14 }
            { uses V{ 13 14 } }
        }
        T{ live-interval
            { vreg V int-rep 30 }
            { start 4 }
            { end 18 }
            { uses V{ 4 12 16 17 18 } }
        }
        T{ live-interval
            { vreg V int-rep 27 }
            { start 3 }
            { end 13 }
            { uses V{ 3 7 13 } }
        }
        T{ live-interval
            { vreg V int-rep 59 }
            { start 10 }
            { end 18 }
            { uses V{ 10 11 12 18 } }
        }
        T{ live-interval
            { vreg V int-rep 60 }
            { start 12 }
            { end 17 }
            { uses V{ 12 17 } }
        }
        T{ live-interval
            { vreg V int-rep 56 }
            { start 9 }
            { end 10 }
            { uses V{ 9 10 } }
        }
    } fake-live-ranges
    { { int-regs { 0 1 2 3 } } }
    allocate-registers drop
] unit-test

[ ] [
    {
        T{ live-interval
            { vreg V int-rep 3687168 }
            { start 106 }
            { end 112 }
            { uses V{ 106 112 } }
        }
        T{ live-interval
            { vreg V int-rep 3687169 }
            { start 107 }
            { end 113 }
            { uses V{ 107 113 } }
        }
        T{ live-interval
            { vreg V int-rep 3687727 }
            { start 190 }
            { end 198 }
            { uses V{ 190 195 198 } }
        }
        T{ live-interval
            { vreg V int-rep 3686445 }
            { start 43 }
            { end 44 }
            { uses V{ 43 44 } }
        }
        T{ live-interval
            { vreg V int-rep 3686195 }
            { start 5 }
            { end 11 }
            { uses V{ 5 11 } }
        }
        T{ live-interval
            { vreg V int-rep 3686449 }
            { start 44 }
            { end 56 }
            { uses V{ 44 45 45 46 56 } }
        }
        T{ live-interval
            { vreg V int-rep 3686198 }
            { start 8 }
            { end 10 }
            { uses V{ 8 9 10 } }
        }
        T{ live-interval
            { vreg V int-rep 3686454 }
            { start 46 }
            { end 49 }
            { uses V{ 46 47 47 49 } }
        }
        T{ live-interval
            { vreg V int-rep 3686196 }
            { start 6 }
            { end 12 }
            { uses V{ 6 12 } }
        }
        T{ live-interval
            { vreg V int-rep 3686197 }
            { start 7 }
            { end 14 }
            { uses V{ 7 13 14 } }
        }
        T{ live-interval
            { vreg V int-rep 3686455 }
            { start 48 }
            { end 51 }
            { uses V{ 48 51 } }
        }
        T{ live-interval
            { vreg V int-rep 3686463 }
            { start 52 }
            { end 53 }
            { uses V{ 52 53 } }
        }
        T{ live-interval
            { vreg V int-rep 3686460 }
            { start 49 }
            { end 52 }
            { uses V{ 49 50 50 52 } }
        }
        T{ live-interval
            { vreg V int-rep 3686461 }
            { start 51 }
            { end 71 }
            { uses V{ 51 52 64 68 71 } }
        }
        T{ live-interval
            { vreg V int-rep 3686464 }
            { start 53 }
            { end 54 }
            { uses V{ 53 54 } }
        }
        T{ live-interval
            { vreg V int-rep 3686465 }
            { start 54 }
            { end 76 }
            { uses V{ 54 55 55 76 } }
        }
        T{ live-interval
            { vreg V int-rep 3686470 }
            { start 58 }
            { end 60 }
            { uses V{ 58 59 59 60 } }
        }
        T{ live-interval
            { vreg V int-rep 3686469 }
            { start 56 }
            { end 58 }
            { uses V{ 56 57 57 58 } }
        }
        T{ live-interval
            { vreg V int-rep 3686473 }
            { start 60 }
            { end 62 }
            { uses V{ 60 61 61 62 } }
        }
        T{ live-interval
            { vreg V int-rep 3686479 }
            { start 62 }
            { end 64 }
            { uses V{ 62 63 63 64 } }
        }
        T{ live-interval
            { vreg V int-rep 3686735 }
            { start 78 }
            { end 96 }
            { uses V{ 78 79 79 96 } }
        }
        T{ live-interval
            { vreg V int-rep 3686482 }
            { start 64 }
            { end 65 }
            { uses V{ 64 65 } }
        }
        T{ live-interval
            { vreg V int-rep 3686483 }
            { start 65 }
            { end 66 }
            { uses V{ 65 66 } }
        }
        T{ live-interval
            { vreg V int-rep 3687510 }
            { start 168 }
            { end 171 }
            { uses V{ 168 171 } }
        }
        T{ live-interval
            { vreg V int-rep 3687511 }
            { start 169 }
            { end 176 }
            { uses V{ 169 176 } }
        }
        T{ live-interval
            { vreg V int-rep 3686484 }
            { start 66 }
            { end 75 }
            { uses V{ 66 67 67 75 } }
        }
        T{ live-interval
            { vreg V int-rep 3687509 }
            { start 162 }
            { end 163 }
            { uses V{ 162 163 } }
        }
        T{ live-interval
            { vreg V int-rep 3686491 }
            { start 68 }
            { end 69 }
            { uses V{ 68 69 } }
        }
        T{ live-interval
            { vreg V int-rep 3687512 }
            { start 170 }
            { end 178 }
            { uses V{ 170 177 178 } }
        }
        T{ live-interval
            { vreg V int-rep 3687515 }
            { start 172 }
            { end 173 }
            { uses V{ 172 173 } }
        }
        T{ live-interval
            { vreg V int-rep 3686492 }
            { start 69 }
            { end 74 }
            { uses V{ 69 70 70 74 } }
        }
        T{ live-interval
            { vreg V int-rep 3687778 }
            { start 202 }
            { end 208 }
            { uses V{ 202 208 } }
        }
        T{ live-interval
            { vreg V int-rep 3686499 }
            { start 71 }
            { end 72 }
            { uses V{ 71 72 } }
        }
        T{ live-interval
            { vreg V int-rep 3687520 }
            { start 174 }
            { end 175 }
            { uses V{ 174 175 } }
        }
        T{ live-interval
            { vreg V int-rep 3687779 }
            { start 203 }
            { end 209 }
            { uses V{ 203 209 } }
        }
        T{ live-interval
            { vreg V int-rep 3687782 }
            { start 206 }
            { end 207 }
            { uses V{ 206 207 } }
        }
        T{ live-interval
            { vreg V int-rep 3686503 }
            { start 74 }
            { end 75 }
            { uses V{ 74 75 } }
        }
        T{ live-interval
            { vreg V int-rep 3686500 }
            { start 72 }
            { end 74 }
            { uses V{ 72 73 73 74 } }
        }
        T{ live-interval
            { vreg V int-rep 3687780 }
            { start 204 }
            { end 210 }
            { uses V{ 204 210 } }
        }
        T{ live-interval
            { vreg V int-rep 3686506 }
            { start 75 }
            { end 76 }
            { uses V{ 75 76 } }
        }
        T{ live-interval
            { vreg V int-rep 3687530 }
            { start 185 }
            { end 192 }
            { uses V{ 185 192 } }
        }
        T{ live-interval
            { vreg V int-rep 3687528 }
            { start 183 }
            { end 198 }
            { uses V{ 183 198 } }
        }
        T{ live-interval
            { vreg V int-rep 3687529 }
            { start 184 }
            { end 197 }
            { uses V{ 184 197 } }
        }
        T{ live-interval
            { vreg V int-rep 3687781 }
            { start 205 }
            { end 211 }
            { uses V{ 205 211 } }
        }
        T{ live-interval
            { vreg V int-rep 3687535 }
            { start 187 }
            { end 194 }
            { uses V{ 187 194 } }
        }
        T{ live-interval
            { vreg V int-rep 3686252 }
            { start 9 }
            { end 17 }
            { uses V{ 9 15 17 } }
        }
        T{ live-interval
            { vreg V int-rep 3686509 }
            { start 76 }
            { end 90 }
            { uses V{ 76 87 90 } }
        }
        T{ live-interval
            { vreg V int-rep 3687532 }
            { start 186 }
            { end 196 }
            { uses V{ 186 196 } }
        }
        T{ live-interval
            { vreg V int-rep 3687538 }
            { start 188 }
            { end 193 }
            { uses V{ 188 193 } }
        }
        T{ live-interval
            { vreg V int-rep 3687827 }
            { start 217 }
            { end 219 }
            { uses V{ 217 219 } }
        }
        T{ live-interval
            { vreg V int-rep 3687825 }
            { start 215 }
            { end 218 }
            { uses V{ 215 216 218 } }
        }
        T{ live-interval
            { vreg V int-rep 3687831 }
            { start 218 }
            { end 219 }
            { uses V{ 218 219 } }
        }
        T{ live-interval
            { vreg V int-rep 3686296 }
            { start 16 }
            { end 18 }
            { uses V{ 16 18 } }
        }
        T{ live-interval
            { vreg V int-rep 3686302 }
            { start 29 }
            { end 31 }
            { uses V{ 29 31 } }
        }
        T{ live-interval
            { vreg V int-rep 3687838 }
            { start 231 }
            { end 232 }
            { uses V{ 231 232 } }
        }
        T{ live-interval
            { vreg V int-rep 3686300 }
            { start 26 }
            { end 27 }
            { uses V{ 26 27 } }
        }
        T{ live-interval
            { vreg V int-rep 3686301 }
            { start 27 }
            { end 30 }
            { uses V{ 27 28 28 30 } }
        }
        T{ live-interval
            { vreg V int-rep 3686306 }
            { start 37 }
            { end 93 }
            { uses V{ 37 82 93 } }
        }
        T{ live-interval
            { vreg V int-rep 3686307 }
            { start 38 }
            { end 88 }
            { uses V{ 38 85 88 } }
        }
        T{ live-interval
            { vreg V int-rep 3687837 }
            { start 222 }
            { end 223 }
            { uses V{ 222 223 } }
        }
        T{ live-interval
            { vreg V int-rep 3686305 }
            { start 36 }
            { end 81 }
            { uses V{ 36 42 77 81 } }
        }
        T{ live-interval
            { vreg V int-rep 3686310 }
            { start 39 }
            { end 95 }
            { uses V{ 39 84 95 } }
        }
        T{ live-interval
            { vreg V int-rep 3687836 }
            { start 227 }
            { end 228 }
            { uses V{ 227 228 } }
        }
        T{ live-interval
            { vreg V int-rep 3687839 }
            { start 239 }
            { end 246 }
            { uses V{ 239 245 246 } }
        }
        T{ live-interval
            { vreg V int-rep 3687841 }
            { start 240 }
            { end 241 }
            { uses V{ 240 241 } }
        }
        T{ live-interval
            { vreg V int-rep 3687845 }
            { start 241 }
            { end 243 }
            { uses V{ 241 243 } }
        }
        T{ live-interval
            { vreg V int-rep 3686315 }
            { start 40 }
            { end 94 }
            { uses V{ 40 83 94 } }
        }
        T{ live-interval
            { vreg V int-rep 3687846 }
            { start 242 }
            { end 245 }
            { uses V{ 242 245 } }
        }
        T{ live-interval
            { vreg V int-rep 3687849 }
            { start 243 }
            { end 245 }
            { uses V{ 243 244 244 245 } }
        }
        T{ live-interval
            { vreg V int-rep 3687850 }
            { start 245 }
            { end 245 }
            { uses V{ 245 } }
        }
        T{ live-interval
            { vreg V int-rep 3687851 }
            { start 246 }
            { end 246 }
            { uses V{ 246 } }
        }
        T{ live-interval
            { vreg V int-rep 3687852 }
            { start 246 }
            { end 246 }
            { uses V{ 246 } }
        }
        T{ live-interval
            { vreg V int-rep 3687853 }
            { start 247 }
            { end 248 }
            { uses V{ 247 248 } }
        }
        T{ live-interval
            { vreg V int-rep 3687854 }
            { start 249 }
            { end 250 }
            { uses V{ 249 250 } }
        }
        T{ live-interval
            { vreg V int-rep 3687855 }
            { start 258 }
            { end 259 }
            { uses V{ 258 259 } }
        }
        T{ live-interval
            { vreg V int-rep 3687080 }
            { start 280 }
            { end 285 }
            { uses V{ 280 285 } }
        }
        T{ live-interval
            { vreg V int-rep 3687081 }
            { start 281 }
            { end 286 }
            { uses V{ 281 286 } }
        }
        T{ live-interval
            { vreg V int-rep 3687082 }
            { start 282 }
            { end 287 }
            { uses V{ 282 287 } }
        }
        T{ live-interval
            { vreg V int-rep 3687083 }
            { start 283 }
            { end 288 }
            { uses V{ 283 288 } }
        }
        T{ live-interval
            { vreg V int-rep 3687085 }
            { start 284 }
            { end 299 }
            { uses V{ 284 285 286 287 288 296 299 } }
        }
        T{ live-interval
            { vreg V int-rep 3687086 }
            { start 284 }
            { end 284 }
            { uses V{ 284 } }
        }
        T{ live-interval
            { vreg V int-rep 3687087 }
            { start 289 }
            { end 293 }
            { uses V{ 289 293 } }
        }
        T{ live-interval
            { vreg V int-rep 3687088 }
            { start 290 }
            { end 294 }
            { uses V{ 290 294 } }
        }
        T{ live-interval
            { vreg V int-rep 3687089 }
            { start 291 }
            { end 297 }
            { uses V{ 291 297 } }
        }
        T{ live-interval
            { vreg V int-rep 3687090 }
            { start 292 }
            { end 298 }
            { uses V{ 292 298 } }
        }
        T{ live-interval
            { vreg V int-rep 3687363 }
            { start 118 }
            { end 119 }
            { uses V{ 118 119 } }
        }
        T{ live-interval
            { vreg V int-rep 3686599 }
            { start 77 }
            { end 89 }
            { uses V{ 77 86 89 } }
        }
        T{ live-interval
            { vreg V int-rep 3687370 }
            { start 131 }
            { end 132 }
            { uses V{ 131 132 } }
        }
        T{ live-interval
            { vreg V int-rep 3687371 }
            { start 138 }
            { end 143 }
            { uses V{ 138 143 } }
        }
        T{ live-interval
            { vreg V int-rep 3687368 }
            { start 127 }
            { end 128 }
            { uses V{ 127 128 } }
        }
        T{ live-interval
            { vreg V int-rep 3687369 }
            { start 122 }
            { end 123 }
            { uses V{ 122 123 } }
        }
        T{ live-interval
            { vreg V int-rep 3687373 }
            { start 139 }
            { end 140 }
            { uses V{ 139 140 } }
        }
        T{ live-interval
            { vreg V int-rep 3686352 }
            { start 41 }
            { end 91 }
            { uses V{ 41 43 79 91 } }
        }
        T{ live-interval
            { vreg V int-rep 3687377 }
            { start 140 }
            { end 141 }
            { uses V{ 140 141 } }
        }
        T{ live-interval
            { vreg V int-rep 3687382 }
            { start 143 }
            { end 143 }
            { uses V{ 143 } }
        }
        T{ live-interval
            { vreg V int-rep 3687383 }
            { start 144 }
            { end 161 }
            { uses V{ 144 159 161 } }
        }
        T{ live-interval
            { vreg V int-rep 3687380 }
            { start 141 }
            { end 143 }
            { uses V{ 141 142 142 143 } }
        }
        T{ live-interval
            { vreg V int-rep 3687381 }
            { start 143 }
            { end 160 }
            { uses V{ 143 160 } }
        }
        T{ live-interval
            { vreg V int-rep 3687384 }
            { start 145 }
            { end 158 }
            { uses V{ 145 158 } }
        }
        T{ live-interval
            { vreg V int-rep 3687385 }
            { start 146 }
            { end 157 }
            { uses V{ 146 157 } }
        }
        T{ live-interval
            { vreg V int-rep 3687640 }
            { start 189 }
            { end 191 }
            { uses V{ 189 191 } }
        }
        T{ live-interval
            { vreg V int-rep 3687388 }
            { start 147 }
            { end 152 }
            { uses V{ 147 152 } }
        }
        T{ live-interval
            { vreg V int-rep 3687393 }
            { start 148 }
            { end 153 }
            { uses V{ 148 153 } }
        }
        T{ live-interval
            { vreg V int-rep 3687398 }
            { start 149 }
            { end 154 }
            { uses V{ 149 154 } }
        }
        T{ live-interval
            { vreg V int-rep 3686372 }
            { start 42 }
            { end 92 }
            { uses V{ 42 45 78 80 92 } }
        }
        T{ live-interval
            { vreg V int-rep 3687140 }
            { start 293 }
            { end 295 }
            { uses V{ 293 294 294 295 } }
        }
        T{ live-interval
            { vreg V int-rep 3687403 }
            { start 150 }
            { end 155 }
            { uses V{ 150 155 } }
        }
        T{ live-interval
            { vreg V int-rep 3687150 }
            { start 304 }
            { end 306 }
            { uses V{ 304 306 } }
        }
        T{ live-interval
            { vreg V int-rep 3687151 }
            { start 305 }
            { end 307 }
            { uses V{ 305 307 } }
        }
        T{ live-interval
            { vreg V int-rep 3687408 }
            { start 151 }
            { end 156 }
            { uses V{ 151 156 } }
        }
        T{ live-interval
            { vreg V int-rep 3687153 }
            { start 312 }
            { end 313 }
            { uses V{ 312 313 } }
        }
        T{ live-interval
            { vreg V int-rep 3686902 }
            { start 267 }
            { end 272 }
            { uses V{ 267 272 } }
        }
        T{ live-interval
            { vreg V int-rep 3686903 }
            { start 268 }
            { end 273 }
            { uses V{ 268 273 } }
        }
        T{ live-interval
            { vreg V int-rep 3686900 }
            { start 265 }
            { end 270 }
            { uses V{ 265 270 } }
        }
        T{ live-interval
            { vreg V int-rep 3686901 }
            { start 266 }
            { end 271 }
            { uses V{ 266 271 } }
        }
        T{ live-interval
            { vreg V int-rep 3687162 }
            { start 100 }
            { end 119 }
            { uses V{ 100 114 117 119 } }
        }
        T{ live-interval
            { vreg V int-rep 3687163 }
            { start 101 }
            { end 118 }
            { uses V{ 101 115 116 118 } }
        }
        T{ live-interval
            { vreg V int-rep 3686904 }
            { start 269 }
            { end 274 }
            { uses V{ 269 274 } }
        }
        T{ live-interval
            { vreg V int-rep 3687166 }
            { start 104 }
            { end 110 }
            { uses V{ 104 110 } }
        }
        T{ live-interval
            { vreg V int-rep 3687167 }
            { start 105 }
            { end 111 }
            { uses V{ 105 111 } }
        }
        T{ live-interval
            { vreg V int-rep 3687164 }
            { start 102 }
            { end 108 }
            { uses V{ 102 108 } }
        }
        T{ live-interval
            { vreg V int-rep 3687165 }
            { start 103 }
            { end 109 }
            { uses V{ 103 109 } }
        }
    } fake-live-ranges
    { { int-regs { 0 1 2 3 4 } } }
    allocate-registers drop
] unit-test

! A reduction of the above
[ ] [
    {
        T{ live-interval
            { vreg V int-rep 6449 }
            { start 44 }
            { end 56 }
            { uses V{ 44 45 46 56 } }
        }
        T{ live-interval
            { vreg V int-rep 6454 }
            { start 46 }
            { end 49 }
            { uses V{ 46 47 49 } }
        }
        T{ live-interval
            { vreg V int-rep 6455 }
            { start 48 }
            { end 51 }
            { uses V{ 48 51 } }
        }
        T{ live-interval
            { vreg V int-rep 6460 }
            { start 49 }
            { end 52 }
            { uses V{ 49 50 52 } }
        }
        T{ live-interval
            { vreg V int-rep 6461 }
            { start 51 }
            { end 71 }
            { uses V{ 51 52 64 68 71 } }
        }
        T{ live-interval
            { vreg V int-rep 6464 }
            { start 53 }
            { end 54 }
            { uses V{ 53 54 } }
        }
        T{ live-interval
            { vreg V int-rep 6470 }
            { start 58 }
            { end 60 }
            { uses V{ 58 59 60 } }
        }
        T{ live-interval
            { vreg V int-rep 6469 }
            { start 56 }
            { end 58 }
            { uses V{ 56 57 58 } }
        }
        T{ live-interval
            { vreg V int-rep 6473 }
            { start 60 }
            { end 62 }
            { uses V{ 60 61 62 } }
        }
        T{ live-interval
            { vreg V int-rep 6479 }
            { start 62 }
            { end 64 }
            { uses V{ 62 63 64 } }
        }
        T{ live-interval
            { vreg V int-rep 6735 }
            { start 78 }
            { end 96 }
            { uses V{ 78 79 96 } }
        }
        T{ live-interval
            { vreg V int-rep 6483 }
            { start 65 }
            { end 66 }
            { uses V{ 65 66 } }
        }
        T{ live-interval
            { vreg V int-rep 7845 }
            { start 91 }
            { end 93 }
            { uses V{ 91 93 } }
        }
        T{ live-interval
            { vreg V int-rep 6372 }
            { start 42 }
            { end 92 }
            { uses V{ 42 45 78 80 92 } }
        }
    } fake-live-ranges
    { { int-regs { 0 1 2 3 } } }
    allocate-registers drop
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
[ { 0 10 } ] [
    H{ { int-regs { 0 1 } } } registers set
    H{
        { int-regs
          {
              T{ live-interval
                 { vreg V int-rep 1 }
                 { start 0 }
                 { end 20 }
                 { reg 0 }
                 { ranges V{ T{ live-range f 0 2 } T{ live-range f 10 20 } } }
                 { uses V{ 0 2 10 20 } }
              }

              T{ live-interval
                 { vreg V int-rep 2 }
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
                 { vreg V int-rep 3 }
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
       { vreg V int-rep 4 }
        { start 8 }
        { end 10 }
        { ranges V{ T{ live-range f 8 10 } } }
        { uses V{ 8 10 } }
    }
    register-status
] unit-test

! Bug in live spill slots calculation

V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##peek
       { dst V int-rep 703128 }
       { loc D 1 }
    }
    T{ ##peek
       { dst V int-rep 703129 }
       { loc D 0 }
    }
    T{ ##copy
       { dst V int-rep 703134 }
       { src V int-rep 703128 }
    }
    T{ ##copy
       { dst V int-rep 703135 }
       { src V int-rep 703129 }
    }
    T{ ##compare-imm-branch
       { src1 V int-rep 703128 }
       { src2 5 }
       { cc cc/= }
    }
} 1 test-bb

V{
    T{ ##copy
       { dst V int-rep 703134 }
       { src V int-rep 703129 }
    }
    T{ ##copy
       { dst V int-rep 703135 }
       { src V int-rep 703128 }
    }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace
       { src V int-rep 703134 }
       { loc D 0 }
    }
    T{ ##replace
       { src V int-rep 703135 }
       { loc D 1 }
    }
    T{ ##epilogue }
    T{ ##return }
} 3 test-bb

0 1 edge
1 { 2 3 } edges
2 3 edge

SYMBOL: linear-scan-result

:: test-linear-scan-on-cfg ( regs -- )
    [
        cfg new 0 get >>entry
        compute-predecessors
        dup { { int-regs regs } } (linear-scan)
        cfg-changed
        flatten-cfg 1array mr.
    ] with-scope ;

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

! Bug in inactive interval handling
! [ rot dup [ -rot ] when ]
V{ T{ ##prologue } T{ ##branch } } 0 test-bb
    
V{
    T{ ##peek
       { dst V int-rep 689473 }
       { loc D 2 }
    }
    T{ ##peek
       { dst V int-rep 689474 }
       { loc D 1 }
    }
    T{ ##peek
       { dst V int-rep 689475 }
       { loc D 0 }
    }
    T{ ##compare-imm-branch
       { src1 V int-rep 689473 }
       { src2 5 }
       { cc cc/= }
    }
} 1 test-bb

V{
    T{ ##copy
       { dst V int-rep 689481 }
       { src V int-rep 689475 }
    }
    T{ ##copy
       { dst V int-rep 689482 }
       { src V int-rep 689474 }
    }
    T{ ##copy
       { dst V int-rep 689483 }
       { src V int-rep 689473 }
    }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##copy
       { dst V int-rep 689481 }
       { src V int-rep 689473 }
    }
    T{ ##copy
       { dst V int-rep 689482 }
       { src V int-rep 689475 }
    }
    T{ ##copy
       { dst V int-rep 689483 }
       { src V int-rep 689474 }
    }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace
       { src V int-rep 689481 }
       { loc D 0 }
    }
    T{ ##replace
       { src V int-rep 689482 }
       { loc D 1 }
    }
    T{ ##replace
       { src V int-rep 689483 }
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
       { dst V int-rep 689600 }
       { loc D 1 }
    }
    T{ ##peek
       { dst V int-rep 689601 }
       { loc D 0 }
    }
    T{ ##compare-imm-branch
       { src1 V int-rep 689600 }
       { src2 5 }
       { cc cc/= }
    }
} 1 test-bb
    
V{
    T{ ##peek
       { dst V int-rep 689604 }
       { loc D 2 }
    }
    T{ ##copy
       { dst V int-rep 689607 }
       { src V int-rep 689604 }
    }
    T{ ##copy
       { dst V int-rep 689608 }
       { src V int-rep 689600 }
    }
    T{ ##copy
       { dst V int-rep 689610 }
       { src V int-rep 689601 }
    }
    T{ ##branch }
} 2 test-bb
    
V{
    T{ ##peek
       { dst V int-rep 689609 }
       { loc D 2 }
    }
    T{ ##copy
       { dst V int-rep 689607 }
       { src V int-rep 689600 }
    }
    T{ ##copy
       { dst V int-rep 689608 }
       { src V int-rep 689601 }
    }
    T{ ##copy
       { dst V int-rep 689610 }
       { src V int-rep 689609 }
    }
    T{ ##branch }
} 3 test-bb
    
V{
    T{ ##replace
       { src V int-rep 689607 }
       { loc D 0 }
    }
    T{ ##replace
       { src V int-rep 689608 }
       { loc D 1 }
    }
    T{ ##replace
       { src V int-rep 689610 }
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
       { dst V int-rep 0 }
       { loc D 0 }
    }
    T{ ##compare-imm-branch
       { src1 V int-rep 0 }
       { src2 5 }
       { cc cc/= }
    }
} 1 test-bb

V{
    T{ ##peek
       { dst V int-rep 1 }
       { loc D 1 }
    }
    T{ ##copy
       { dst V int-rep 2 }
       { src V int-rep 1 }
    }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##peek
       { dst V int-rep 3 }
       { loc D 2 }
    }
    T{ ##copy
       { dst V int-rep 2 }
       { src V int-rep 3 }
    }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace
       { src V int-rep 2 }
       { loc D 0 }
    }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 3 4 } test-linear-scan-on-cfg ] unit-test

! Inactive interval handling: splitting active interval
! if it fits in lifetime hole only partially

V{ T{ ##peek f V int-rep 3 R 1 } T{ ##branch } } 0 test-bb

V{
    T{ ##peek f V int-rep 2 R 0 }
    T{ ##compare-imm-branch f V int-rep 2 5 cc= }
} 1 test-bb

V{
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##branch }
} 2 test-bb


V{
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##replace f V int-rep 1 D 2 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f V int-rep 3 R 2 }
    T{ ##replace f V int-rep 0 D 0 }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

! Not until splitting is finished
! [ _copy ] [ 3 get instructions>> second class ] unit-test

! Resolve pass; make sure the spilling is done correctly
V{ T{ ##peek f V int-rep 3 R 1 } T{ ##branch } } 0 test-bb

V{
    T{ ##peek f V int-rep 2 R 0 }
    T{ ##compare-imm-branch f V int-rep 2 5 cc= }
} 1 test-bb

V{
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f V int-rep 3 R 1 }
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##replace f V int-rep 1 D 2 }
    T{ ##replace f V int-rep 0 D 2 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f V int-rep 3 R 2 }
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
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##compare-imm-branch f V int-rep 0 5 cc= }
} 1 test-bb

V{
    T{ ##replace f V int-rep 0 D 0 }
    T{ ##peek f V int-rep 1 D 0 }
    T{ ##peek f V int-rep 2 D 0 }
    T{ ##replace f V int-rep 1 D 0 }
    T{ ##replace f V int-rep 2 D 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##peek f V int-rep 1 D 0 }
    T{ ##compare-imm-branch f V int-rep 1 5 cc= }
} 4 test-bb

V{
    T{ ##replace f V int-rep 0 D 0 }
    T{ ##return }
} 5 test-bb

V{
    T{ ##replace f V int-rep 0 D 0 }
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
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##peek f V int-rep 2 D 2 }
    T{ ##peek f V int-rep 3 D 3 }
    T{ ##peek f V int-rep 4 D 0 }
    T{ ##branch }
} 1 test-bb
V{ T{ ##branch } } 2 test-bb
V{ T{ ##branch } } 3 test-bb
V{
    
    T{ ##replace f V int-rep 1 D 1 }
    T{ ##replace f V int-rep 2 D 2 }
    T{ ##replace f V int-rep 3 D 3 }
    T{ ##replace f V int-rep 4 D 4 }
    T{ ##replace f V int-rep 0 D 0 }
    T{ ##branch }
} 4 test-bb
V{ T{ ##replace f V int-rep 0 D 0 } T{ ##branch } } 5 test-bb
V{ T{ ##return } } 6 test-bb
V{ T{ ##branch } } 7 test-bb
V{
    T{ ##replace f V int-rep 1 D 1 }
    T{ ##replace f V int-rep 2 D 2 }
    T{ ##replace f V int-rep 3 D 3 }
    T{ ##peek f V int-rep 5 D 1 }
    T{ ##peek f V int-rep 6 D 2 }
    T{ ##peek f V int-rep 7 D 3 }
    T{ ##peek f V int-rep 8 D 4 }
    T{ ##replace f V int-rep 5 D 1 }
    T{ ##replace f V int-rep 6 D 2 }
    T{ ##replace f V int-rep 7 D 3 }
    T{ ##replace f V int-rep 8 D 4 }
    T{ ##branch }
} 8 test-bb
V{
    T{ ##replace f V int-rep 1 D 1 }
    T{ ##replace f V int-rep 2 D 2 }
    T{ ##replace f V int-rep 3 D 3 }
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
[ V{ 3 2 1 } ] [ 8 get instructions>> [ _spill? ] filter [ n>> cell / ] map ] unit-test
[ V{ 3 2 1 } ] [ 9 get instructions>> [ _reload? ] filter [ n>> cell / ] map ] unit-test

! Resolve pass should insert this
[ _reload ] [ 5 get predecessors>> first instructions>> first class ] unit-test

! Some random bug
V{
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##peek f V int-rep 2 D 2 }
    T{ ##replace f V int-rep 1 D 1 }
    T{ ##replace f V int-rep 2 D 2 }
    T{ ##peek f V int-rep 3 D 0 }
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##peek f V int-rep 2 D 2 }
    T{ ##replace f V int-rep 3 D 3 }
    T{ ##replace f V int-rep 1 D 1 }
    T{ ##replace f V int-rep 2 D 2 }
    T{ ##replace f V int-rep 0 D 3 }
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
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##peek f V int-rep 2 D 2 }
    T{ ##replace f V int-rep 1 D 1 }
    T{ ##replace f V int-rep 2 D 2 }
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{ T{ ##branch } } 1 test-bb

V{
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f V int-rep 1 D 1 }
    T{ ##peek f V int-rep 2 D 2 }
    T{ ##replace f V int-rep 2 D 2 }
    T{ ##branch }
} 3 test-bb

V{ T{ ##branch } } 4 test-bb

V{
    T{ ##replace f V int-rep 0 D 0 }
    T{ ##return }
} 5 test-bb

1 get 1vector 0 get (>>successors)
2 get 4 get V{ } 2sequence 1 get (>>successors)
5 get 1vector 4 get (>>successors)
3 get 1vector 2 get (>>successors)
5 get 1vector 3 get (>>successors)

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

! Reduction of push-all regression, x86-32
V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##load-immediate { dst V int-rep 61 } }
    T{ ##peek { dst V int-rep 62 } { loc D 0 } }
    T{ ##peek { dst V int-rep 64 } { loc D 1 } }
    T{ ##slot-imm
        { dst V int-rep 69 }
        { obj V int-rep 64 }
        { slot 1 }
        { tag 2 }
    }
    T{ ##copy { dst V int-rep 79 } { src V int-rep 69 } }
    T{ ##slot-imm
        { dst V int-rep 85 }
        { obj V int-rep 62 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##compare-branch
        { src1 V int-rep 69 }
        { src2 V int-rep 85 }
        { cc cc> }
    }
} 1 test-bb

V{
    T{ ##slot-imm
        { dst V int-rep 97 }
        { obj V int-rep 62 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##replace { src V int-rep 79 } { loc D 3 } }
    T{ ##replace { src V int-rep 62 } { loc D 4 } }
    T{ ##replace { src V int-rep 79 } { loc D 1 } }
    T{ ##replace { src V int-rep 62 } { loc D 2 } }
    T{ ##replace { src V int-rep 61 } { loc D 5 } }
    T{ ##replace { src V int-rep 62 } { loc R 0 } }
    T{ ##replace { src V int-rep 69 } { loc R 1 } }
    T{ ##replace { src V int-rep 97 } { loc D 0 } }
    T{ ##call { word resize-array } }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##peek { dst V int-rep 98 } { loc R 0 } }
    T{ ##peek { dst V int-rep 100 } { loc D 0 } }
    T{ ##set-slot-imm
        { src V int-rep 100 }
        { obj V int-rep 98 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##peek { dst V int-rep 108 } { loc D 2 } }
    T{ ##peek { dst V int-rep 110 } { loc D 3 } }
    T{ ##peek { dst V int-rep 112 } { loc D 0 } }
    T{ ##peek { dst V int-rep 114 } { loc D 1 } }
    T{ ##peek { dst V int-rep 116 } { loc D 4 } }
    T{ ##peek { dst V int-rep 119 } { loc R 0 } }
    T{ ##copy { dst V int-rep 109 } { src V int-rep 108 } }
    T{ ##copy { dst V int-rep 111 } { src V int-rep 110 } }
    T{ ##copy { dst V int-rep 113 } { src V int-rep 112 } }
    T{ ##copy { dst V int-rep 115 } { src V int-rep 114 } }
    T{ ##copy { dst V int-rep 117 } { src V int-rep 116 } }
    T{ ##copy { dst V int-rep 120 } { src V int-rep 119 } }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##copy { dst V int-rep 109 } { src V int-rep 62 } }
    T{ ##copy { dst V int-rep 111 } { src V int-rep 61 } }
    T{ ##copy { dst V int-rep 113 } { src V int-rep 62 } }
    T{ ##copy { dst V int-rep 115 } { src V int-rep 79 } }
    T{ ##copy { dst V int-rep 117 } { src V int-rep 64 } }
    T{ ##copy { dst V int-rep 120 } { src V int-rep 69 } }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##replace { src V int-rep 120 } { loc D 0 } }
    T{ ##replace { src V int-rep 109 } { loc D 3 } }
    T{ ##replace { src V int-rep 111 } { loc D 4 } }
    T{ ##replace { src V int-rep 113 } { loc D 1 } }
    T{ ##replace { src V int-rep 115 } { loc D 2 } }
    T{ ##replace { src V int-rep 117 } { loc D 5 } }
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
    T{ ##peek { dst V int-rep 85 } { loc D 0 } }
    T{ ##slot-imm
        { dst V int-rep 89 }
        { obj V int-rep 85 }
        { slot 3 }
        { tag 7 }
    }
    T{ ##peek { dst V int-rep 91 } { loc D 1 } }
    T{ ##slot-imm
        { dst V int-rep 96 }
        { obj V int-rep 91 }
        { slot 1 }
        { tag 2 }
    }
    T{ ##add
        { dst V int-rep 109 }
        { src1 V int-rep 89 }
        { src2 V int-rep 96 }
    }
    T{ ##slot-imm
        { dst V int-rep 115 }
        { obj V int-rep 85 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##slot-imm
        { dst V int-rep 118 }
        { obj V int-rep 115 }
        { slot 1 }
        { tag 2 }
    }
    T{ ##compare-branch
        { src1 V int-rep 109 }
        { src2 V int-rep 118 }
        { cc cc> }
    }
} 1 test-bb

V{
    T{ ##add-imm
        { dst V int-rep 128 }
        { src1 V int-rep 109 }
        { src2 8 }
    }
    T{ ##load-immediate { dst V int-rep 129 } { val 24 } }
    T{ ##inc-d { n 4 } }
    T{ ##inc-r { n 1 } }
    T{ ##replace { src V int-rep 109 } { loc D 2 } }
    T{ ##replace { src V int-rep 85 } { loc D 3 } }
    T{ ##replace { src V int-rep 128 } { loc D 0 } }
    T{ ##replace { src V int-rep 85 } { loc D 1 } }
    T{ ##replace { src V int-rep 89 } { loc D 4 } }
    T{ ##replace { src V int-rep 96 } { loc R 0 } }
    T{ ##replace { src V int-rep 129 } { loc R 0 } }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##peek { dst V int-rep 134 } { loc D 1 } }
    T{ ##slot-imm
        { dst V int-rep 140 }
        { obj V int-rep 134 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##inc-d { n 1 } }
    T{ ##inc-r { n 1 } }
    T{ ##replace { src V int-rep 140 } { loc D 0 } }
    T{ ##replace { src V int-rep 134 } { loc R 0 } }
    T{ ##call { word resize-array } }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##peek { dst V int-rep 141 } { loc R 0 } }
    T{ ##peek { dst V int-rep 143 } { loc D 0 } }
    T{ ##set-slot-imm
        { src V int-rep 143 }
        { obj V int-rep 141 }
        { slot 2 }
        { tag 7 }
    }
    T{ ##write-barrier
        { src V int-rep 141 }
        { card# V int-rep 145 }
        { table V int-rep 146 }
    }
    T{ ##inc-d { n -1 } }
    T{ ##inc-r { n -1 } }
    T{ ##peek { dst V int-rep 156 } { loc D 2 } }
    T{ ##peek { dst V int-rep 158 } { loc D 3 } }
    T{ ##peek { dst V int-rep 160 } { loc D 0 } }
    T{ ##peek { dst V int-rep 162 } { loc D 1 } }
    T{ ##peek { dst V int-rep 164 } { loc D 4 } }
    T{ ##peek { dst V int-rep 167 } { loc R 0 } }
    T{ ##copy { dst V int-rep 157 } { src V int-rep 156 } }
    T{ ##copy { dst V int-rep 159 } { src V int-rep 158 } }
    T{ ##copy { dst V int-rep 161 } { src V int-rep 160 } }
    T{ ##copy { dst V int-rep 163 } { src V int-rep 162 } }
    T{ ##copy { dst V int-rep 165 } { src V int-rep 164 } }
    T{ ##copy { dst V int-rep 168 } { src V int-rep 167 } }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##inc-d { n 3 } }
    T{ ##inc-r { n 1 } }
    T{ ##copy { dst V int-rep 157 } { src V int-rep 85 } }
    T{ ##copy { dst V int-rep 159 } { src V int-rep 89 } }
    T{ ##copy { dst V int-rep 161 } { src V int-rep 85 } }
    T{ ##copy { dst V int-rep 163 } { src V int-rep 109 } }
    T{ ##copy { dst V int-rep 165 } { src V int-rep 91 } }
    T{ ##copy { dst V int-rep 168 } { src V int-rep 96 } }
    T{ ##branch }
} 5 test-bb

V{
    T{ ##set-slot-imm
        { src V int-rep 163 }
        { obj V int-rep 161 }
        { slot 3 }
        { tag 7 }
    }
    T{ ##inc-d { n 1 } }
    T{ ##inc-r { n -1 } }
    T{ ##replace { src V int-rep 168 } { loc D 0 } }
    T{ ##replace { src V int-rep 157 } { loc D 3 } }
    T{ ##replace { src V int-rep 159 } { loc D 4 } }
    T{ ##replace { src V int-rep 161 } { loc D 1 } }
    T{ ##replace { src V int-rep 163 } { loc D 2 } }
    T{ ##replace { src V int-rep 165 } { loc D 5 } }
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
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##compare-imm-branch f V int-rep 0 5 cc= }
} 1 test-bb

V{ T{ ##branch } } 2 test-bb

V{
    T{ ##peek f V int-rep 1 D 0 }
    T{ ##peek f V int-rep 2 D 0 }
    T{ ##replace f V int-rep 1 D 0 }
    T{ ##replace f V int-rep 2 D 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f V int-rep 0 D 0 }
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
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##compare-imm-branch f V int-rep 0 5 cc= }
} 1 test-bb

V{
    T{ ##peek f V int-rep 1 D 0 }
    T{ ##peek f V int-rep 2 D 0 }
    T{ ##replace f V int-rep 1 D 0 }
    T{ ##replace f V int-rep 2 D 0 }
    T{ ##replace f V int-rep 0 D 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f V int-rep 0 D 0 }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [ { 1 2 } test-linear-scan-on-cfg ] unit-test

[ 0 ] [ 1 get instructions>> [ _spill? ] count ] unit-test

[ 1 ] [ 2 get instructions>> [ _spill? ] count ] unit-test

[ 1 ] [ 2 get instructions>> [ _reload? ] count ] unit-test

[ 0 ] [ 3 get instructions>> [ _spill? ] count ] unit-test

[ 0 ] [ 4 get instructions>> [ _reload? ] count ] unit-test

! GC check tests

! Spill slot liveness was computed incorrectly, leading to a FEP
! early in bootstrap on x86-32
[ t ] [
    [
        T{ basic-block
           { id 12345 }
           { instructions
             V{
                 T{ ##gc f V int-rep 6 V int-rep 7 }
                 T{ ##peek f V int-rep 0 D 0 }
                 T{ ##peek f V int-rep 1 D 1 }
                 T{ ##peek f V int-rep 2 D 2 }
                 T{ ##peek f V int-rep 3 D 3 }
                 T{ ##peek f V int-rep 4 D 4 }
                 T{ ##peek f V int-rep 5 D 5 }
                 T{ ##replace f V int-rep 0 D 1 }
                 T{ ##replace f V int-rep 1 D 2 }
                 T{ ##replace f V int-rep 2 D 3 }
                 T{ ##replace f V int-rep 3 D 4 }
                 T{ ##replace f V int-rep 4 D 5 }
                 T{ ##replace f V int-rep 5 D 0 }
             }
           }
        } cfg new over >>entry
        { { int-regs V{ 0 1 2 3 } } } (linear-scan)
        instructions>> first
        tagged-values>> assoc-empty?
    ] with-scope
] unit-test

V{
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##replace f V int-rep 1 D 1 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##gc f V int-rep 2 V int-rep 3 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##replace f V int-rep 0 D 0 }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

[ ] [ { 1 2 3 } test-linear-scan-on-cfg ] unit-test

[ { 3 } ] [ 1 get instructions>> first tagged-values>> ] unit-test



V{
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##compare-imm-branch f V int-rep 1 5 cc= }
} 0 test-bb

V{
    T{ ##gc f V int-rep 2 V int-rep 3 }
    T{ ##replace f V int-rep 0 D 0 }
    T{ ##return }
} 1 test-bb

V{
    T{ ##return }
} 2 test-bb

0 { 1 2 } edges

[ ] [ { 1 2 3 } test-linear-scan-on-cfg ] unit-test

[ { 3 } ] [ 1 get instructions>> first tagged-values>> ] unit-test
