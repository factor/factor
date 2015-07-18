! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data arrays assocs compiler.units
effects io.backend io.pathnames kernel llvm.core llvm.jit
llvm.reader llvm.types make namespaces sequences
specialized-arrays vocabs words ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:void*
IN: llvm.invoker

! get function name, ret type, param types and names

! load module
! iterate through functions in a module

TUPLE: function name alien return params ;

: params ( llvm-function -- param-list )
    dup LLVMCountParams c:void* <c-array>
    [ LLVMGetParams ] keep >array
    [ [ LLVMGetValueName ] [ LLVMTypeOf tref> ] bi 2array ] map ;

: <function> ( LLVMValueRef -- function )
    function new
    over LLVMGetValueName >>name
    over LLVMTypeOf tref> type>> return>> >>return
    swap params >>params ;

: (functions) ( llvm-function -- )
    [ dup , LLVMGetNextFunction (functions) ] when* ;

: functions ( llvm-module -- functions )
    LLVMGetFirstFunction [ (functions) ] { } make [ <function> ] map ;

: function-effect ( function -- effect )
    [ params>> keys ] [ return>> void? 0 1 ? ] bi <effect> ;

: install-function ( function -- )
    dup name>> "alien.llvm" create-vocab drop
    "alien.llvm" create-word swap
    [
        dup name>> function-pointer ,
        dup return>> c:lookup-c-type ,
        dup params>> [ second c:lookup-c-type ] map ,
        cdecl , \ alien-indirect ,
    ] [ ] make swap function-effect [ define-declared ] with-compilation-unit ;

: install-module ( name -- )
    current-jit mps>> at [
        module>> functions [ install-function ] each
    ] [ "no such module" throw ] if* ;

: install-bc ( path -- )
    [ normalize-path ] [ file-name ] bi
    [ load-into-jit ] keep install-module ;

<< "alien.llvm" create-vocab drop >>
