USING: llvm.ffi ;
IN: llvm

: initialize ( -- )
    LLVMGetGlobalPassRegistry LLVMInitializeCore ;

! https://github.com/fsprojects/llvm-fs/blob/master/src/LLVM/Target.fs
: initialize-native-target ( -- )
    LLVMInitializeX86TargetInfo
    LLVMInitializeX86Target
    LLVMInitializeX86TargetMC ;

: initialize-native-asm-printer ( -- )
    LLVMInitializeX86AsmPrinter ;
