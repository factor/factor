USING: accessors alien destructors io.pathnames kernel llvm.ffi
llvm.wrappers tools.test ;
IN: llvm.wrappers.tests

{ 728 t } [
    "resource:extra/llvm/wrappers/add.bc" absolute-path <buffer>
    [ value>> [ LLVMGetBufferSize ] keep ] with-disposal alien?
] unit-test
