! Copyright (C) 2017 Björn Lindqvist
USING: kernel llvm.ffi tools.test ;
IN: llvm.ffi.tests

{ } [
    "my_module" LLVMModuleCreateWithName
    dup LLVMDumpModule
    LLVMDisposeModule
] unit-test
