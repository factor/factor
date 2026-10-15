USING: accessors byte-arrays compiler.cfg.build-stack-frame
compiler.cfg.instructions compiler.cfg.linearization compiler.cfg.stack-frame
compiler.cfg.utilities compiler.cfg.comparisons compiler.codegen.labels
compiler.codegen.relocation cpu.architecture cpu.m68k kernel make namespaces
system tools.test vectors words ;
IN: cpu.m68k.tests

{ 48 } [ M\ m68k.32 float-arithmetic-stack-space execute( -- n ) ] unit-test

! Hidden native calls must have their own argument and register-save area.
{ 48 } [
    m68k.32 \ cpu [
        { T{ ##mul-float } } insns>cfg dup build-stack-frame
        stack-frame>> params>>
    ] with-variable
] unit-test

! Scratch storage must precede both local allocations and register spills.
{ 48 48 80 } [
    m68k.32 \ cpu [
        {
            T{ ##div-float }
            T{ ##local-allot { dst 1 } { size 32 } { align 8 } }
        } insns>cfg dup build-stack-frame stack-frame>>
        [ params>> ] [ allot-area-base>> ] [ spill-area-base>> ] tri
    ] with-variable
] unit-test

{ B{ 32 1 } } [ [ 0 1 MV ] B{ } make ] unit-test
{ B{ 32 74 } } [ [ 8 10 MV ] B{ } make ] unit-test
{ B{ 32 10 } } [ [ 0 10 MV ] B{ } make ] unit-test
{ B{ 36 64 } } [ [ 10 0 MV ] B{ } make ] unit-test
{ B{ 112 255 } } [ [ 0 -1 LI ] B{ } make ] unit-test
{ B{ 32 60 0 0 0 0 } } [ [ 0 load-address ] B{ } make ] unit-test
{ B{ 32 124 0 0 0 0 } } [ [ 8 load-address ] B{ } make ] unit-test
! An aliased second operand must be copied before subtracting.
{ B{ 42 0 32 1 144 133 } } [
    [ 0 1 0 M\ m68k.32 %sub execute( dst a b -- ) ] B{ } make
] unit-test
{ 9 8 13 12 } [
    cc-o condition-code cc/o condition-code cc< condition-code cc/< condition-code
] unit-test
{ 4 11 6 9 } [
    cc< float-condition cc/< float-condition cc<> float-condition cc/<> float-condition
] unit-test
{ B{ 32 47 0 4 } } [ [ 0 SP 4 LW ] B{ } make ] unit-test
{ B{ 47 64 0 4 } } [ [ 0 SP 4 SW ] B{ } make ] unit-test
! Conditional branches skip a complete absolute jump; labels use full cells.
{ B{ 102 0 0 8 78 249 0 0 0 0 } } [
    [
        init-relocation V{ } clone label-table set
        [ <label> 7 branch ] B{ } make
    ] with-scope
] unit-test
