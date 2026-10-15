! Generate ARM32 base-AAPCS VM boxing transports; softfp-native.c executes them.
! Run with ARM32 backend sources refreshed in the host compiler image.
USING: cpu.architecture cpu.arm.32 cpu.arm.32.assembler cpu.arm.32.compiler-assembler generic io.encodings.binary io.files kernel literals make namespaces ;
emit-bytecode? on have-BX? on
[ VPUSH-D8-D15 D0 float-rep softfp-unbox-result R0 D0 >S VMOV-FROM-S VPOP-D8-D15 LR BX ] B{ } make
"/tmp/arm32-backend-softfp-float.bin" binary set-file-contents
[ VPUSH-D8-D15 D0 double-rep softfp-unbox-result R0 R1 D0 VMOV-DOUBLE-TO-CORE VPOP-D8-D15 LR BX ] B{ } make
"/tmp/arm32-backend-softfp-double.bin" binary set-file-contents
[ VPUSH-D8-D15 D0 R0 R1 VMOV-CORE-TO-DOUBLE D0 double-rep softfp-box-arguments VPOP-D8-D15 LR BX ] B{ } make
"/tmp/arm32-backend-softfp-double-box.bin" binary set-file-contents
[ VPUSH-D8-D15 D0 >S R0 VMOV-TO-S D0 float-rep softfp-box-arguments VPOP-D8-D15 LR BX ] B{ } make
"/tmp/arm32-backend-softfp-float-box.bin" binary set-file-contents
