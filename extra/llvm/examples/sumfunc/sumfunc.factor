USING: alien.c-types alien.data arrays destructors kernel llvm.ffi
locals math sequences ;
IN: llvm.examples.sumfunc

! From:
! https://pauladamsmith.com/blog/2015/01/how-to-get-started-with-llvm-c-api.html
ERROR: llvm-verify message ;

: declare-function ( module name ret params -- value )
    [ void* >c-array ] [ length ] bi 0 LLVMFunctionType LLVMAddFunction ;

: verify-module ( module -- )
    ! Does it leak?
    LLVMReturnStatusAction
    { c-string } [ LLVMVerifyModule ] with-out-parameters
    swap 0 = [ drop ] [ llvm-verify ] if ;

: with-module ( name quot -- )
    [
        swap LLVMModuleCreateWithName
        &LLVMDisposeModule
        [ swap call ]
        [ dup verify-module LLVMDumpModule ] bi
    ] with-destructors ; inline

: with-builder ( quot -- )
    [
        LLVMCreateBuilder &LLVMDisposeBuilder swap call
    ] with-destructors ; inline


: create-execution-engine-for-module ( module -- engine )
    [ f LLVMExecutionEngineRef <ref> dup ] dip f
    LLVMCreateExecutionEngineForModule drop
    LLVMExecutionEngineRef deref ;

: with-execution-engine ( module quot -- )
    [
        swap create-execution-engine-for-module
        &LLVMDisposeExecutionEngine
        swap call
    ] with-destructors ; inline

: create-sum-body ( sum -- )
    [
        ! sum builder
        over "entry" LLVMAppendBasicBlock
        ! sum builder bb
        dupd LLVMPositionBuilderAtEnd
        ! sum builder
        swap dupd [ 0 LLVMGetParam ] [ 1 LLVMGetParam ] bi
        ! builder builder p0 p1
        "tmp" LLVMBuildAdd
        LLVMBuildRet drop
    ] with-builder ;

:: create-sum-function ( -- )
    "my_module" [
        "sum" LLVMInt32Type LLVMInt32Type LLVMInt32Type 2array
        declare-function create-sum-body
    ] with-module ;
