USING: accessors alien.c-types alien.syntax assocs destructors
kernel llvm.core llvm.engine llvm.wrappers namespaces ;

IN: llvm.jit

SYMBOL: thejit

TUPLE: jit ee mps ;

: empty-engine ( -- engine )
    "initial-module" <module> [
        <provider>
    ] with-disposal [
        <engine>
    ] with-disposal ;

: <jit> ( -- jit )
    jit new empty-engine >>ee H{ } clone >>mps ;

: (remove-functions) ( function -- )
    thejit get ee>> value>> over LLVMFreeMachineCodeForFunction
    LLVMGetNextFunction dup ALIEN: 0 = [ drop ] [ (remove-functions) ] if ;

: remove-functions ( module -- )
    ! free machine code for each function in module
    LLVMGetFirstFunction dup ALIEN: 0 = [ drop ] [ (remove-functions) ] if ;

: (remove-provider) ( provider -- )
    thejit get ee>> value>> swap value>> f <void*> f <void*>
    [ LLVMRemoveModuleProvider drop ] 2keep *void* [ llvm-throw ] when*
    *void* module new swap >>value
    [ value>> remove-functions ] with-disposal ;

: remove-provider ( name -- )
    dup thejit get mps>> at [
        (remove-provider)
        thejit get mps>> delete-at
    ] [ drop ] if* ;

: add-provider ( provider name -- )
    dup remove-provider
    thejit get ee>> value>>  pick value>> LLVMAddModuleProvider
    [ t >>disposed ] dip thejit get mps>> set-at ;

thejit [ <jit> ] initialize