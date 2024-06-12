! Copyright (C) 2009 Matthew Willis, 2017 Björn Lindqvist.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings destructors
io.encodings.utf8 kernel llvm.ffi ;
IN: llvm.wrappers

ERROR: llvm-error message ;

: llvm-throw ( void* -- )
    [ utf8 alien>string ] [ LLVMDisposeMessage ] bi llvm-error ;

: llvm-throw-on-error ( quot -- )
    1guard 0 = [ drop ] [ void* deref llvm-throw ] if ; inline

: <dispose> ( alien class -- disposable ) new swap >>value ;

TUPLE: module value disposed ;
M: module dispose* value>> LLVMDisposeModule ;

: <module> ( name -- module )
    LLVMModuleCreateWithName module <dispose> ;

: verify-module ( module -- )
    value>> LLVMReturnStatusAction f void* <ref>
    [ LLVMVerifyModule ] llvm-throw-on-error ;

TUPLE: provider value module disposed ;
M: provider dispose* value>> LLVMDisposeModuleProvider ;

: (provider) ( module -- provider )
    [ value>> LLVMCreateModuleProviderForExistingModule provider <dispose> ]
    [ t >>disposed value>> ] bi
    >>module ;

: <provider> ( module -- provider )
    [ (provider) ] with-disposal ;

TUPLE: engine value disposed ;
M: engine dispose* value>> LLVMDisposeExecutionEngine ;

: (engine) ( LLVMModuleRef -- LLVMExecutionEngineRef )
    f void* <ref> swap dupd f void* <ref>
    [ LLVMCreateExecutionEngineForModule ] llvm-throw-on-error
    void* deref ;

: <engine> ( module -- engine )
    [
        [ value>> (engine) engine <dispose> ]
        [ t >>disposed drop ]  bi
    ] with-disposal ;

: find-function ( engine name -- function/f )
    [ value>> ] dip f void* <ref>
    [ LLVMFindFunction drop ] keep void* deref ;

: function-pointer ( engine function -- alien )
    [ value>> ] dip LLVMGetPointerToGlobal ;

TUPLE: buffer value disposed ;
M: buffer dispose* value>> LLVMDisposeMemoryBuffer ;

: <buffer> ( path -- buffer )
    f void* <ref> f void* <ref>
    [ LLVMCreateMemoryBufferWithContentsOfFile drop ] 2keep
    void* deref [ llvm-throw ] when* void* deref buffer <dispose> ;

: (add-block) ( value -- basic-block )
    "entry" LLVMAppendBasicBlock ;

TUPLE: builder value disposed ;
M: builder dispose* value>> LLVMDisposeBuilder ;

: <builder> ( value -- builder )
    (add-block) LLVMCreateBuilder [ swap LLVMPositionBuilderAtEnd ] keep
    builder <dispose> ;
