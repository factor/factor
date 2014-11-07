USING: compiler.cfg.liveness
compiler.cfg compiler.cfg.debugger compiler.cfg.instructions
compiler.cfg.predecessors compiler.cfg.registers compiler.cfg.utilities
cpu.architecture accessors namespaces sequences kernel
tools.test vectors alien math compiler.cfg.comparisons
cpu.x86.assembler.operands assocs ;
IN: compiler.cfg.liveness.tests

: test-liveness ( -- )
    1 get block>cfg compute-live-sets ;

! Sanity check...

V{
    T{ ##peek f 0 D 0 }
    T{ ##replace f 0 D 0 }
    T{ ##replace f 1 D 1 }
    T{ ##peek f 1 D 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##replace f 2 D 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f 3 D 0 }
    T{ ##return }
} 3 test-bb

1 { 2 3 } edges

[ ] [ test-liveness ] unit-test

[
    H{
        { 1 1 }
        { 2 2 }
        { 3 3 }
    }
]
[ 1 get live-in ]
unit-test

! Tricky case; defs must be killed before uses

V{
    T{ ##peek f 0 D 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##add-imm f 0 0 10 }
    T{ ##return }
} 2 test-bb

1 2 edge

[ ] [ test-liveness ] unit-test

[ H{ { 0 0 } } ] [ 2 get live-in ] unit-test

! Regression
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##inc-r f 2 }
    T{ ##inc-d f -2 }
    T{ ##peek f 21 D -1 }
    T{ ##peek f 22 D -2 }
    T{ ##replace f 21 R 0 }
    T{ ##replace f 22 R 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##call f >c-ptr }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##inc-r f -1 }
    T{ ##inc-d f 1 }
    T{ ##peek f 25 R -1 }
    T{ ##replace f 25 D 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##call f >float }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##inc-r f -1 }
    T{ ##inc-d f 2 }
    T{ ##peek f 27 R -1 }
    T{ ##peek f 28 D 2 }
    T{ ##peek f 29 D 3 }
    T{ ##load-integer f 30 1 }
    T{ ##load-integer f 31 0 }
    T{ ##compare-imm-branch f 27 f cc/= }
} 5 test-bb

V{
    T{ ##inc-d f -1 }
    T{ ##branch }
} 6 test-bb

V{
    T{ ##inc-d f -1 }
    T{ ##branch }
} 7 test-bb

V{
    T{ ##phi f 36 H{ { 6 30 } { 7 31 } } }
    T{ ##inc-d f -2 }
    T{ ##unbox f 37 29 "alien_offset" int-rep }
    T{ ##unbox f 38 28 "to_double" double-rep }
    T{ ##unbox f 39 36 "to_cell" int-rep }
    T{ ##alien-invoke f V{ } V{ { 37 int-rep 0 } { 38 double-rep 4 } { 39 int-rep 12 } } { { 40 int-rep EAX } } { } 0 16 "CFRunLoopRunInMode" f T{ gc-map } }
    T{ ##box f 41 40 "from_signed_cell" int-rep T{ gc-map } }
    T{ ##replace f 41 D 0 }
    T{ ##branch }
} 8 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 9 test-bb

0 1 edge
1 2 edge
2 3 edge
3 4 edge
4 5 edge
5 { 6 7 } edges
6 8 edge
7 8 edge
8 9 edge

[ ] [ test-liveness ] unit-test

[ H{ { 28 28 } { 29 29 } { 30 30 } { 31 31 } } ] [ 5 get live-out ] unit-test
[ H{ { 28 28 } { 29 29 } { 30 30 } } ] [ 6 get live-in ] unit-test
[ H{ { 28 28 } { 29 29 } { 31 31 } } ] [ 7 get live-in ] unit-test
[ H{ { 30 30 } } ] [ 6 get 8 get edge-live-in ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-integer f 0 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-integer f 1 1 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f 2 H{ { 2 0 } { 3 1 } } }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##branch }
} 5 test-bb

V{
    T{ ##replace f 2 D 0 }
    T{ ##branch }
} 6 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 7 test-bb

0 1 edge
1 { 2 3 } edges
2 4 edge
3 4 edge
4 { 5 6 } edges
5 6 edge
6 7 edge

[ ] [ 0 get block>cfg dup cfg set compute-live-sets ] unit-test

[ t ] [ 0 get live-in assoc-empty? ] unit-test

[ H{ { 2 2 } } ] [ 4 get live-out ] unit-test

[ H{ { 0 0 } } ] [ 2 get 4 get edge-live-in ] unit-test

[ H{ { 1 1 } } ] [ 3 get 4 get edge-live-in ] unit-test


V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 0 D 0 }
    T{ ##tagged>integer f 1 0 }
    T{ ##call-gc f T{ gc-map } }
    T{ ##replace f 0 D 0 }
    T{ ##call-gc f T{ gc-map } }
    T{ ##replace f 1 D 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

H{
    { 0 tagged-rep }
    { 1 int-rep }
} representations set

[ ] [ 0 get block>cfg dup cfg set compute-live-sets ] unit-test

[ V{ { 1 0 } } ] [ 1 get instructions>> 2 swap nth gc-map>> derived-roots>> ] unit-test

[ { 0 } ] [ 1 get instructions>> 2 swap nth gc-map>> gc-roots>> ] unit-test

[ V{ { 1 0 } } ] [ 1 get instructions>> 4 swap nth gc-map>> derived-roots>> ] unit-test

[ { 0 } ] [ 1 get instructions>> 4 swap nth gc-map>> gc-roots>> ] unit-test
