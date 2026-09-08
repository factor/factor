USING: byte-arrays compiler.cfg.instructions compiler.cfg.multiply-negate
compiler.test cpu.architecture cpu.arm.64 cpu.arm.64.assembler
cpu.arm.64.assembler.registers kernel kernel.private locals make math math.private
namespaces prettyprint sequences system tools.test ;
IN: compiler.cfg.multiply-negate
! Controlled before run: disable only the new pass and restore the exact
! original ARM constant-multiply lowering. All other compiler code is shared.
: fuse-multiply-negate ( cfg -- ) drop ;
IN: cpu.arm.64
M:: arm.64 %mul-imm ( DST SRC1 src2 -- )
    temp src2 (%load-immediate)
    DST SRC1 temp MUL ;
IN: arm64-gap-isa.before-codegen
f restartable-tests? set-global
{ 1 } [
    [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ]
    [ ##mneg? ] count-insns
] unit-test
{ 4 } [ [ X0 X1 3 %mul-imm ] B{ } make length ] unit-test
{ -42 } [ 6 7 [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ] compile-call ] unit-test
test-failures get length .
test-failures get empty? 0 1 ? exit
