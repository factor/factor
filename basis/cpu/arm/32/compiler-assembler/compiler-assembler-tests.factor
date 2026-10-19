USING: cpu.arm.32.assembler cpu.arm.32.compiler-assembler kernel
make tools.test namespaces ;
IN: cpu.arm.32.compiler-assembler.tests
{ { 0xee343b05 0xee343b45 0xee243b05 0xee843b05 } }
[ f emit-bytecode? [ [ D3 D4 D5 VADD D3 D4 D5 VSUB D3 D4 D5 VMUL D3 D4 D5 VDIV ] { } make ] with-variable ] unit-test
{ { 0xeeb13bc5 0xeeb03b45 0xed923b03 0xed023b03 } }
[ f emit-bytecode? [ [ D3 D5 VSQRT D3 D5 VMOV D3 R2 12 VLDR D3 R2 -12 VSTR ] { } make ] with-variable ] unit-test
{ { 0xeeb73ac5 0xeeb73bc5 0xee032a10 0xee132a10 } }
[ f emit-bytecode? [ [ D3 S10 VCVT-F64-F32 S6 D5 VCVT-F32-F64 S6 R2 VMOV-TO-S R2 S6 VMOV-FROM-S ] { } make ] with-variable ] unit-test
{ { 0xeeb83bc5 0xeebd3bc5 0xeeb43b45 } }
[ f emit-bytecode? [ [ D3 S10 VCVT-F64-S32 S6 D5 VCVT-S32-F64 D3 D5 VCMP ] { } make ] with-variable ] unit-test
{ { 0xeeb40bc1 0xeef1fa10 } }
[ f emit-bytecode? [ [ D0 D1 VCMPE PC VMRS ] { } make ] with-variable ] unit-test
{ { 0xed2d8b10 0xecbd8b10 } }
[ f emit-bytecode? [ [ VPUSH-D8-D15 VPOP-D8-D15 ] { } make ] with-variable ] unit-test
{ { 0xec54cb1f 0xec44cb1f } }
[ f emit-bytecode? [ [ R12 R4 D15 VMOV-DOUBLE-TO-CORE D15 R12 R4 VMOV-CORE-TO-DOUBLE ] { } make ] with-variable ] unit-test
