! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax destructors kernel
llvm.core llvm.engine llvm.jit llvm.wrappers ;

IN: llvm.reader

: buffer>module ( buffer -- module )
    [
        value>> f <void*> f <void*>
        [ LLVMParseBitcode drop ] 2keep
        *void* [ llvm-throw ] when* *void*
        module new swap >>value
    ] with-disposal ;

: load-module ( path -- module )
    <buffer> buffer>module ;

: load-into-jit ( path name -- )
    [ load-module ] dip add-module ;