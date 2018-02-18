! Copyright (C) 2017 Björn Lindqvist
USING: kernel llvm.ffi tools.test ;

{ } [
    "my_module" LLVMModuleCreateWithName
    ! dup LLVMDumpModule
    LLVMDisposeModule
] unit-test

{ 10 } [
    LLVMInt32Type 10 LLVMVectorType LLVMGetVectorSize
] unit-test

{ 32 } [
    LLVMInt32Type LLVMGetIntTypeWidth
] unit-test
