! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax assocs
destructors kernel llvm.core llvm.engine llvm.wrappers
namespaces ;

IN: llvm.jit

TUPLE: jit ee mps ;

: empty-engine ( -- engine )
    "initial-module" <module> <provider> <engine> ;

: <jit> ( -- jit )
    jit new empty-engine >>ee H{ } clone >>mps ;

: current-jit ( -- jit )
    \ current-jit global [ drop <jit> ] cache ;

: (remove-functions) ( function -- )
    current-jit ee>> value>> over LLVMFreeMachineCodeForFunction
    LLVMGetNextFunction dup ALIEN: 0 = [ drop ] [ (remove-functions) ] if ;

: remove-functions ( module -- )
    ! free machine code for each function in module
    LLVMGetFirstFunction dup ALIEN: 0 = [ drop ] [ (remove-functions) ] if ;

: remove-provider ( provider -- )
    current-jit ee>> value>> swap value>> f void* <ref> f void* <ref>
    [ LLVMRemoveModuleProvider drop ] 2keep void* deref [ llvm-throw ] when*
    void* deref module new swap >>value
    [ value>> remove-functions ] with-disposal ;

: remove-module ( name -- )
    dup current-jit mps>> at [
        remove-provider
        current-jit mps>> delete-at
    ] [ drop ] if* ;

: add-module ( module name -- )
    [ <provider> ] dip [ remove-module ] keep
    current-jit ee>> value>> pick
    [ [ value>> LLVMAddModuleProvider ] [ t >>disposed drop ] bi ] with-disposal
    current-jit mps>> set-at ;

: function-pointer ( name -- alien )
    current-jit ee>> value>> dup
    rot f void* <ref> [ LLVMFindFunction drop ] keep
    void* deref LLVMGetPointerToGlobal ;
