USING: accessors alien assocs compiler.cfg compiler.cfg.comparisons
compiler.cfg.def-use compiler.cfg.instructions compiler.cfg.liveness
compiler.cfg.registers compiler.cfg.ssa.destruction.leaders
compiler.cfg.utilities compiler.test compiler.utilities cpu.architecture
cpu.x86.assembler.operands kernel math namespaces sequences system
tools.test ;
IN: compiler.cfg.liveness.tests

! compute-edge-live-in
{ H{ } } [
    { } 0 insns>block compute-edge-live-in
] unit-test

{
    H{
        { "bl1" H{ { 7 7 } } }
        { "bl2" H{ { 99 99 } } }
    }
} [
    {
        T{ ##phi
           { dst 103 }
           { inputs H{ { "bl1" 7 } { "bl2" 99 } } }
        }
    } 0 insns>block
    compute-edge-live-in
] unit-test

{
    H{
        { "b-31" H{ { 192 192 } { 193 193 } { 194 194 } { 195 195 } } }
        { "b-23" H{ { 181 181 } { 182 182 } { 183 183 } { 187 187 } } }
        { "b-26" H{ { 188 188 } { 189 189 } { 190 190 } { 191 191 } } }
    }
} [
    {
        T{ ##phi
           { dst 196 }
           { inputs H{ { "b-26" 189 } { "b-23" 183 } { "b-31" 193 } } }
        }
        T{ ##phi
           { dst 197 }
           { inputs H{ { "b-26" 190 } { "b-23" 182 } { "b-31" 194 } } }
        }
        T{ ##phi
           { dst 198 }
           { inputs H{ { "b-26" 191 } { "b-23" 181 } { "b-31" 195 } } }
        }
        T{ ##phi
           { dst 199 }
           { inputs H{ { "b-26" 188 } { "b-23" 187 } { "b-31" 192 } } }
        }
    } 0 insns>block compute-edge-live-in
] unit-test

! fill-gc-map
{
    T{ gc-map { gc-roots { 48 } } { derived-roots V{ } } }
} [
    H{ { 48 tagged-rep } } representations set
    H{ { 48 48  } } clone
    T{ gc-map } [ fill-gc-map ] keep
] unit-test

! gc-roots
! only vregs that are tagged are real gc roots
{ V{ } { 125 } } [
    H{
        { 123 double-rep }
        { 124 double-2-rep }
        { 125 tagged-rep }
    } representations set
    { 123 124 125 } unique gc-roots
] unit-test

! gen-uses
{ H{ { 37 37 } } } [
    H{ } clone [ T{ ##replace f 37 D: 0 0 } gen-uses ] keep
] unit-test

! kill-defs
{ H{ } } [
    H{ } dup T{ ##peek f 37 D: 0 0 } kill-defs
] unit-test

{ H{ { 3 3 } } } [
    H{ { 37 99 } { 99 99 } { 2 99 } } leader-map set
    H{ { 37 37 } { 3 3 } } dup T{ ##peek f 2 D: 0 0 } kill-defs
] unit-test

! liveness-step
{ 3 } [
    init-liveness
    3 <iota> [ <basic-block> swap >>number ] map <basic-block>
    [ connect-Nto1-bbs ] keep liveness-step length
] unit-test

! lookup-base-pointer
{ 84 } [
    H{ { 84 84 } } clone base-pointers set 84 lookup-base-pointer
] unit-test

{ 15 } [
    { T{ ##tagged>integer f 30 15 } } 0 insns>block block>cfg compute-live-sets
    30 lookup-base-pointer
] unit-test

cpu x86.64? [
    { f } [
        H{ } base-pointers set
        H{ { 123 T{ ##peek { dst RCX } { loc D: 1 } { insn# 6 } } } } insns set
        123 lookup-base-pointer
    ] unit-test
] when

! lookup-base-pointer*
{ f } [
    456 T{ ##peek f 123 D: 0 } lookup-base-pointer*
] unit-test

! transfer-liveness
{
    H{ { 37 37 } }
} [
    H{ } clone dup { T{ ##replace f 37 D: 1 6 } T{ ##peek f 37 D: 0 0 } }
    transfer-liveness
] unit-test

! visit-gc-root
{ V{ } HS{ 48 } } [
    H{ { 48 tagged-rep } } representations set
    48 V{ } clone HS{ } clone [ visit-gc-root ] 2keep
] unit-test

! So the real root is 40?
{ V{ { 48 40 } } HS{ 40 } } [
    H{ { 48 40 } } base-pointers set
    H{ { 48 int-rep } } representations set
    48 V{ } clone HS{ } clone [ visit-gc-root ] 2keep
] unit-test

! visit-insn
{ H{ } } [
    H{ } clone [ T{ ##peek f 0 D: 0 } visit-insn ] keep
] unit-test

{ H{ { 48 48 } { 37 37 } } } [
    H{ { 48 tagged-rep } } representations set
    H{ { 48 48  } } clone [ T{ ##replace f 37 D: 1 6 } visit-insn ] keep
] unit-test

{
    T{ ##call-gc
       { gc-map
         T{ gc-map { gc-roots { 93 } } { derived-roots V{ } } }
       }
    }
} [
    H{ { 93 tagged-rep } } representations set
    H{ { 93 93  } } clone T{ ##call-gc f T{ gc-map } }
    [ visit-insn ] keep
] unit-test

: test-liveness ( -- )
    1 get block>cfg compute-live-sets ;

! Sanity check...

V{
    T{ ##peek f 0 D: 0 }
    T{ ##replace f 0 D: 0 }
    T{ ##replace f 1 D: 1 }
    T{ ##peek f 1 D: 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##replace f 2 D: 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f 3 D: 0 }
    T{ ##return }
} 3 test-bb

1 { 2 3 } edges

{ } [ test-liveness ] unit-test

{
    H{
        { 1 1 }
        { 2 2 }
        { 3 3 }
    }
}
[ 1 get live-in ]
unit-test

! Tricky case; defs must be killed before uses

V{
    T{ ##peek f 0 D: 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##add-imm f 0 0 10 }
    T{ ##return }
} 2 test-bb

1 2 edge

{ } [ test-liveness ] unit-test

{ H{ { 0 0 } } } [ 2 get live-in ] unit-test

! Regression
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##inc { loc R: 2 } }
    T{ ##inc { loc D: -2 } }
    T{ ##peek f 21 D: -1 }
    T{ ##peek f 22 D: -2 }
    T{ ##replace f 21 R: 0 }
    T{ ##replace f 22 R: 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##call f >c-ptr }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##inc { loc R: -1 } }
    T{ ##inc { loc D: 1 } }
    T{ ##peek f 25 R: -1 }
    T{ ##replace f 25 D: 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##call f >float }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##inc f R: -1 }
    T{ ##inc f D: 2 }
    T{ ##peek f 27 R: -1 }
    T{ ##peek f 28 D: 2 }
    T{ ##peek f 29 D: 3 }
    T{ ##load-integer f 30 1 }
    T{ ##load-integer f 31 0 }
    T{ ##compare-imm-branch f 27 f cc/= }
} 5 test-bb

V{
    T{ ##inc f D: -1 }
    T{ ##branch }
} 6 test-bb

V{
    T{ ##inc f D: -1 }
    T{ ##branch }
} 7 test-bb

V{
    T{ ##phi f 36 H{ { 6 30 } { 7 31 } } }
    T{ ##inc f D: -2 }
    T{ ##unbox f 37 29 "alien_offset" int-rep }
    T{ ##unbox f 38 28 "to_double" double-rep }
    T{ ##unbox f 39 36 "to_signed_8" int-rep }
    T{ ##alien-invoke f f V{ } V{ { 37 int-rep 0 } { 38 double-rep 4 } { 39 int-rep 12 } } { { 40 int-rep EAX } } { } 0 16 "CFRunLoopRunInMode" f T{ gc-map } }
    T{ ##box f 41 40 "from_signed_8" int-rep T{ gc-map } }
    T{ ##replace f 41 D: 0 }
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

{ } [ test-liveness ] unit-test

{ H{ { 28 28 } { 29 29 } { 30 30 } { 31 31 } } } [ 5 get live-out ] unit-test
{ H{ { 28 28 } { 29 29 } { 30 30 } } } [ 6 get live-in ] unit-test
{ H{ { 28 28 } { 29 29 } { 31 31 } } } [ 7 get live-in ] unit-test
{ H{ { 30 30 } } } [ 6 get 8 get edge-live-in ] unit-test

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
    T{ ##replace f 2 D: 0 }
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

{ } [ 0 get block>cfg dup cfg set compute-live-sets ] unit-test

{ t } [ 0 get live-in assoc-empty? ] unit-test

{ H{ { 2 2 } } } [ 4 get live-out ] unit-test

{ H{ { 0 0 } } } [ 2 get 4 get edge-live-in ] unit-test

{ H{ { 1 1 } } } [ 3 get 4 get edge-live-in ] unit-test


V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 0 D: 0 }
    T{ ##tagged>integer f 1 0 }
    T{ ##call-gc f T{ gc-map } }
    T{ ##replace f 0 D: 0 }
    T{ ##call-gc f T{ gc-map } }
    T{ ##replace f 1 D: 0 }
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

{ } [ 0 get block>cfg dup cfg set compute-live-sets ] unit-test

{ V{ { 1 0 } } } [ 1 get instructions>> 2 swap nth gc-map>> derived-roots>> ] unit-test

{ { 0 } } [ 1 get instructions>> 2 swap nth gc-map>> gc-roots>> ] unit-test

{ V{ { 1 0 } } } [ 1 get instructions>> 4 swap nth gc-map>> derived-roots>> ] unit-test

{ { 0 } } [ 1 get instructions>> 4 swap nth gc-map>> gc-roots>> ] unit-test
