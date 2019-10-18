! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax assocs destructors
kernel llvm.core llvm.engine llvm.wrappers namespaces ;

IN: llvm.jit

SYMBOL: thejit

TUPLE: jit ee mps ;

: empty-engine ( -- engine )
    "initial-module" <module> <provider> <engine> ;

: <jit> ( -- jit )
    jit new empty-engine >>ee H{ } clone >>mps ;

: (remove-functions) ( function -- )
    thejit get ee>> value>> over LLVMFreeMachineCodeForFunction
    LLVMGetNextFunction dup ALIEN: 0 = [ drop ] [ (remove-functions) ] if ;

: remove-functions ( module -- )
    ! free machine code for each function in module
    LLVMGetFirstFunction dup ALIEN: 0 = [ drop ] [ (remove-functions) ] if ;

: remove-provider ( provider -- )
    thejit get ee>> value>> swap value>> f <void*> f <void*>
    [ LLVMRemoveModuleProvider drop ] 2keep *void* [ llvm-throw ] when*
    *void* module new swap >>value
    [ value>> remove-functions ] with-disposal ;

: remove-module ( name -- )
    dup thejit get mps>> at [
        remove-provider
        thejit get mps>> delete-at
    ] [ drop ] if* ;

: add-module ( module name -- )
    [ <provider> ] dip [ remove-module ] keep
    thejit get ee>> value>> pick
    [ [ value>> LLVMAddModuleProvider ] [ t >>disposed drop ] bi ] with-disposal
    thejit get mps>> set-at ;

: function-pointer ( name -- alien )
    thejit get ee>> value>> dup
    rot f <void*> [ LLVMFindFunction drop ] keep
    *void* LLVMGetPointerToGlobal ;

thejit [ <jit> ] initialize