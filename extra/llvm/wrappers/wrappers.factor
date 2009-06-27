USING: accessors alien.c-types alien.strings destructors kernel
llvm.core llvm.engine ;

IN: llvm.wrappers

: llvm-throw ( char* -- )
    [ alien>string ] [ LLVMDisposeMessage ] bi throw ;

: <dispose> ( alien class -- disposable ) new swap >>value ;

TUPLE: module value disposed ;
M: module dispose* value>> LLVMDisposeModule ;

: <module> ( name -- module )
    LLVMModuleCreateWithName module <dispose> ;

TUPLE: provider value disposed ;
M: provider dispose* value>> LLVMDisposeModuleProvider ;

: <provider> ( module -- module-provider )
    ! we don't want to dispose when an error occurs
    ! for example, retries with the same module wouldn't work
    ! but we do want to mark the module as disposed on success
    [ value>> LLVMCreateModuleProviderForExistingModule ]
    [ t >>disposed drop ] bi
    provider <dispose> ;

TUPLE: engine value disposed ;
M: engine dispose* value>> LLVMDisposeExecutionEngine ;

: <engine> ( provider -- engine )
    [
        value>> f <void*> f <void*>
        [ swapd 0 swap LLVMCreateJITCompiler drop ] 2keep
        *void* [ llvm-throw ] when* *void*
    ]
    [ t >>disposed drop ] bi
    engine <dispose> ;

: (add-block) ( name -- basic-block )
    "function" swap LLVMAppendBasicBlock ;

TUPLE: builder value disposed ;
M: builder dispose* value>> LLVMDisposeBuilder ;

: <builder> ( name -- builder )
    (add-block) LLVMCreateBuilder [ swap LLVMPositionBuilderAtEnd ] keep
    builder <dispose> ;