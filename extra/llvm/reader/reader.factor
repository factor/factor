! Copyright (C) 2009 Matthew Willis.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data destructors kernel llvm.ffi
llvm.wrappers ;

IN: llvm.reader

: buffer>module ( buffer -- module )
    [
        value>> f void* <ref> f void* <ref>
        [ LLVMParseBitcode drop ] 2keep
        void* deref [ llvm-throw ] when* void* deref
        module new swap >>value
    ] with-disposal ;

: load-module ( path -- module )
    <buffer> buffer>module ;
