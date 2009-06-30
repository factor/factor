USING: accessors alien.c-types alien.strings
io.encodings.utf8 destructors kernel
llvm.core llvm.engine ;

IN: llvm.wrappers

: llvm-throw ( char* -- )
    [ utf8 alien>string ] [ LLVMDisposeMessage ] bi throw ;

: <dispose> ( alien class -- disposable ) new swap >>value ;

TUPLE: module value disposed ;
M: module dispose* value>> LLVMDisposeModule ;

: <module> ( name -- module )
    LLVMModuleCreateWithName module <dispose> ;

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

: (engine) ( provider -- engine )
    [
        value>> f <void*> f <void*>
        [ swapd 0 swap LLVMCreateJITCompiler drop ] 2keep
        *void* [ llvm-throw ] when* *void*
    ]
    [ t >>disposed drop ] bi
    engine <dispose> ;

: <engine> ( provider -- engine )
    [ (engine) ] with-disposal ;

: (add-block) ( name -- basic-block )
    "function" swap LLVMAppendBasicBlock ;

TUPLE: builder value disposed ;
M: builder dispose* value>> LLVMDisposeBuilder ;

: <builder> ( name -- builder )
    (add-block) LLVMCreateBuilder [ swap LLVMPositionBuilderAtEnd ] keep
    builder <dispose> ;

TUPLE: buffer value disposed ;
M: buffer dispose* value>> LLVMDisposeMemoryBuffer ;

: <buffer> ( path -- module )
    f <void*> f <void*>
    [ LLVMCreateMemoryBufferWithContentsOfFile drop ] 2keep
    *void* [ llvm-throw ] when* *void* buffer <dispose> ;