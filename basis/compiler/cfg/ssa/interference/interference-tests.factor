USING: accessors alien.c-types compiler.cfg.comparisons
compiler.cfg.def-use compiler.cfg.instructions compiler.cfg.liveness
compiler.cfg.registers compiler.cfg.ssa.interference
compiler.cfg.ssa.interference.live-ranges
compiler.cfg.ssa.interference.private compiler.cfg.utilities
compiler.test cpu.architecture kernel namespaces sequences slots
tools.test ;
IN: compiler.cfg.ssa.interference.tests

: test-interference ( -- )
    0 get block>cfg
    dup compute-live-sets
    dup compute-defs
    dup compute-insns
    compute-live-ranges ;

: <test-vreg-info> ( vreg -- info )
    [ ] [ insn-of dup ##tagged>integer? [ src>> ] [ dst>> ] if ] [ def-of ] tri
    <vreg-info> ;

: test-vregs-intersect? ( vreg1 vreg2 -- ? )
    [ <test-vreg-info> ] bi@ vregs-intersect? ;

: test-vregs-interfere? ( vreg1 vreg2 -- ? )
    [ <test-vreg-info> ] bi@
    [ blue >>color ] [ red >>color ] bi*
    vregs-interfere? ;

: test-sets-interfere? ( seq1 seq2 -- merged ? )
    [ [ <test-vreg-info> ] map ] bi@ sets-interfere? ;

V{
    T{ ##peek f 0 D: 0 }
    T{ ##peek f 2 D: 0 }
    T{ ##copy f 1 0 }
    T{ ##copy f 3 2 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 4 D: 0 }
    T{ ##peek f 5 D: 0 }
    T{ ##replace f 3 D: 0 }
    T{ ##peek f 6 D: 0 }
    T{ ##replace f 5 D: 0 }
    T{ ##return }
} 1 test-bb

0 1 edge

{ } [ test-interference ] unit-test

{ f } [ 0 1 test-vregs-intersect? ] unit-test
{ f } [ 1 0 test-vregs-intersect? ] unit-test
{ f } [ 2 3 test-vregs-intersect? ] unit-test
{ f } [ 3 2 test-vregs-intersect? ] unit-test
{ t } [ 0 2 test-vregs-intersect? ] unit-test
{ t } [ 2 0 test-vregs-intersect? ] unit-test
{ f } [ 1 3 test-vregs-intersect? ] unit-test
{ f } [ 3 1 test-vregs-intersect? ] unit-test
{ t } [ 3 4 test-vregs-intersect? ] unit-test
{ t } [ 4 3 test-vregs-intersect? ] unit-test
{ t } [ 3 5 test-vregs-intersect? ] unit-test
{ t } [ 5 3 test-vregs-intersect? ] unit-test
{ f } [ 3 6 test-vregs-intersect? ] unit-test
{ f } [ 6 3 test-vregs-intersect? ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb


V{
    T{ ##inc f D: -3 }
    T{ ##peek f 12 D: -2 }
    T{ ##peek f 23 D: -1 }
    T{ ##sar-imm f 13 23 4 }
    T{ ##peek f 24 D: -3 }
    T{ ##sar-imm f 14 24 4 }
    T{ ##mul f 15 13 13 }
    T{ ##mul f 16 15 15 }
    T{ ##tagged>integer f 17 12 }
    T{ ##store-memory f 16 17 14 0 7 int-rep uchar }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

{ } [ test-interference ] unit-test

{ t } [ { 15 } { 23 13 } test-sets-interfere? nip ] unit-test

V{
    T{ ##prologue f }
    T{ ##branch f }
} 0 test-bb

V{
    T{ ##inc f D: 2 }
    T{ ##peek f 32 D: 2 }
    T{ ##load-reference f 33 ##check-nursery-branch }
    T{ ##load-integer f 34 11 }
    T{ ##tagged>integer f 35 32 }
    T{ ##and-imm f 36 35 15 }
    T{ ##compare-integer-imm-branch f 36 7 cc= }
} 1 test-bb

V{
    T{ ##slot-imm f 48 32 1 7 }
    T{ ##slot-imm f 50 48 1 2 }
    T{ ##sar-imm f 65 50 4 }
    T{ ##compare-integer-branch f 34 65 cc<= }
} 2 test-bb

V{
    T{ ##inc f D: -2 }
    T{ ##slot-imm f 57 48 11 2 }
    T{ ##compare f 58 33 57 cc= 20 }
    T{ ##replace f 58 D: 0 }
    T{ ##branch f }
} 3 test-bb

V{
    T{ ##epilogue f }
    T{ ##return f }
} 4 test-bb

V{
    T{ ##inc f D: -2 }
    T{ ##replace-imm f f D: 0 }
    T{ ##branch f }
} 5 test-bb

V{
    T{ ##epilogue f }
    T{ ##return f }
} 6 test-bb

V{
    T{ ##inc f D: -2 }
    T{ ##replace-imm f f D: 0 }
    T{ ##branch f }
} 7 test-bb

V{
    T{ ##epilogue f }
    T{ ##return f }
} 8 test-bb

0 1 edge
1 { 2 7 } edges
2 { 3 5 } edges
3 4 edge
5 6 edge
7 8 edge

{ } [ test-interference ] unit-test

{ f } [ { 48 } { 32 35 } test-sets-interfere? nip ] unit-test

TUPLE: bab ;
TUPLE: gfg { x bab } ;
: bah ( -- x ) f ;

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##check-nursery-branch f 16 cc<= 75 76 }
} 1 test-bb

V{
    T{ ##save-context f 77 78 }
    T{ ##call-gc f T{ gc-map } }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##inc f D: 1 }
    T{ ##load-reference f 37 T{ bab } }
    T{ ##load-reference f 38 { gfg 1 1 tuple 57438726 gfg 7785907 } }
    T{ ##allot f 40 12 tuple 4 }
    T{ ##set-slot-imm f 38 40 1 7 }
    T{ ##set-slot-imm f 37 40 2 7 }
    T{ ##replace f 40 D: 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##call f bah }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##inc f R: 1 }
    T{ ##inc f D: 1 }
    T{ ##peek f 43 D: 1 }
    T{ ##peek f 44 D: 2 }
    T{ ##tagged>integer f 45 43 }
    T{ ##and-imm f 46 45 15 }
    T{ ##compare-integer-imm-branch f 46 7 cc= }
} 5 test-bb

V{
    T{ ##inc f D: 1 }
    T{ ##slot-imm f 58 43 1 7 }
    T{ ##slot-imm f 60 58 7 2 }
    T{ ##compare-imm-branch f 60 bab cc= }
} 6 test-bb

V{
    T{ ##branch }
} 7 test-bb

V{
    T{ ##inc f R: -1 }
    T{ ##inc f D: -1 }
    T{ ##set-slot-imm f 43 44 2 7 }
    T{ ##write-barrier-imm f 44 2 7 34 35 }
    T{ ##branch }
} 8 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 9 test-bb

V{
    T{ ##inc f D: 1 }
    T{ ##replace f 44 R: 0 }
    T{ ##replace-imm f bab D: 0 }
    T{ ##branch }
} 10 test-bb

V{
    T{ ##call f bad-slot-value }
    T{ ##branch }
} 11 test-bb

V{
    T{ ##no-tco }
} 12 test-bb

V{
    T{ ##inc f D: -1 }
    T{ ##branch }
} 13 test-bb

V{
    T{ ##inc f D: 1 }
    T{ ##replace f 44 R: 0 }
    T{ ##replace-imm f bab D: 0 }
    T{ ##branch }
} 14 test-bb

V{
    T{ ##call f bad-slot-value }
    T{ ##branch }
} 15 test-bb

V{
    T{ ##no-tco }
} 16 test-bb

0 1 edge
1 { 3 2 } edges
2 3 edge
3 4 edge
4 5 edge
5 { 6 13 } edges
6 { 7 10 } edges
7 8 edge
8 9 edge
10 11 edge
11 12 edge
13 14 edge
14 15 edge
15 16 edge

{ } [ test-interference ] unit-test

{ t } [ 43 45 test-vregs-intersect? ] unit-test
{ f } [ 43 45 test-vregs-interfere? ] unit-test

{ t } [ 43 46 test-vregs-intersect? ] unit-test
{ t } [ 43 46 test-vregs-interfere? ] unit-test

{ f } [ 45 46 test-vregs-intersect? ] unit-test
{ f } [ 45 46 test-vregs-interfere? ] unit-test

{ f } [ { 43 } { 45 } test-sets-interfere? nip ] unit-test

{ t f } [
    { 46 } { 43 } { 45 }
    [ [ <test-vreg-info> ] map ] tri@
    sets-interfere? [ sets-interfere? nip ] dip
] unit-test

V{
    T{ ##prologue f }
    T{ ##branch f }
} 0 test-bb

V{

    T{ ##inc f D: 1 }
    T{ ##peek f 31 D: 1 }
    T{ ##sar-imm f 16 31 4 }
    T{ ##load-integer f 17 0 }
    T{ ##copy f 33 17 int-rep }
    T{ ##branch f }
} 1 test-bb

V{
    T{ ##phi f 21 H{ { 1 33 } { 3 32 } } }
    T{ ##compare-integer-branch f 21 16 cc< }
} 2 test-bb

V{
    T{ ##add-imm f 27 21 1 }
    T{ ##copy f 32 27 int-rep }
    T{ ##branch f }
} 3 test-bb

V{
    T{ ##inc f D: -2 }
    T{ ##branch f }
} 4 test-bb

V{
    T{ ##epilogue f }
    T{ ##return f }
} 5 test-bb

0 1 edge
1 2 edge
2 { 3 4 } edges
3 2 edge
4 5 edge

{ } [ test-interference ] unit-test

{ f f } [
    { 33 } { 21 } { 32 }
    [ [ <test-vreg-info> ] map ] tri@
    sets-interfere? [ sets-interfere? nip ] dip
] unit-test

{ f } [ 33 21 test-vregs-intersect? ] unit-test
{ f } [ 32 21 test-vregs-intersect? ] unit-test
{ f } [ 32 33 test-vregs-intersect? ] unit-test
