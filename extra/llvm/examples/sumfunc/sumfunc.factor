USING: accessors alien.c-types alien.data arrays destructors kernel
llvm.ffi llvm.wrappers sequences ;
IN: llvm.examples.sumfunc

! From:
! https://pauladamsmith.com/blog/2015/01/how-to-get-started-with-llvm-c-api.html
: add-function ( module name type -- value )
    [ value>> ] 2dip LLVMAddFunction ;

: dump-module ( module -- )
    value>> LLVMDumpModule ;

: create-sum-type ( -- type )
    LLVMInt32Type LLVMInt32Type LLVMInt32Type 2array
    [ void* >c-array ] [ length ] bi 0 LLVMFunctionType ;

: create-sum-body ( sum -- )
    dup <builder> [
        value>>
        ! sum builder
        swap dupd
        [ 0 LLVMGetParam ] [ 1 LLVMGetParam ] bi
        ! builder builder p0 p1
        "tmp" LLVMBuildAdd
        LLVMBuildRet drop
    ] with-disposal ;

: create-sum-function ( -- )
    "my_module" <module> [
        [ "sum" create-sum-type add-function create-sum-body ]
        [ verify-module ] [ dump-module ] tri
    ] with-disposal ;
