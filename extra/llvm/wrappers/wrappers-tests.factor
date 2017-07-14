USING: accessors alien destructors io.pathnames kernel llvm.ffi
llvm.reader llvm.wrappers tools.test ;
IN: llvm.wrappers.tests

: add.bc ( -- path )
    "resource:extra/llvm/wrappers/add.bc" absolute-path ;

{ 728 t } [
    add.bc <buffer>
    [ value>> [ LLVMGetBufferSize ] keep ] with-disposal alien?
] unit-test

{ "sum" 2 32 LLVMIntegerTypeKind } [
    add.bc load-module <engine>
    "sum" find-function
    [ LLVMGetValueName ]
    [ LLVMCountParams ]
    [
        LLVMTypeOf LLVMGetElementType LLVMGetReturnType
        [ LLVMGetIntTypeWidth ]
        [ LLVMGetTypeKind ] bi
    ] tri
] unit-test
