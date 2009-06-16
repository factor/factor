USING: accessors alien.c-types alien.strings arrays
central destructors kernel llvm.core llvm.engine
quotations sequences specialized-arrays.alien ;

IN: llvm.bindings

: llvm-throw ( char** -- )
    [ alien>string ] [ LLVMDisposeMessage ] bi throw ;

DISPOSABLE-CENTRAL: module
CENTRAL: function
DISPOSABLE-CENTRAL: builder
DISPOSABLE-CENTRAL: engine

: <dispose> ( alien class -- disposable ) new swap >>value ;

TUPLE: LLVMModule value disposed ;
M: LLVMModule dispose* value>> LLVMDisposeModule ;

: <module> ( name -- module )
    LLVMModuleCreateWithName LLVMModule <dispose> ;

TUPLE: LLVMModuleProvider value disposed ;
M: LLVMModuleProvider dispose* value>> LLVMDisposeModuleProvider ;

: <provider> ( -- module-provider )
    module t >>disposed value>> LLVMCreateModuleProviderForExistingModule
    LLVMModuleProvider <dispose> ;

: (add-block) ( name -- basic-block )
    function swap LLVMAppendBasicBlock ;

TUPLE: LLVMBuilder value disposed ;
M: LLVMBuilder dispose* value>> LLVMDisposeBuilder ;

: <builder> ( name -- builder )
    (add-block) LLVMCreateBuilder [ swap LLVMPositionBuilderAtEnd ] keep
    LLVMBuilder <dispose> ;

TUPLE: LLVMExecutionEngine value disposed ;
M: LLVMExecutionEngine dispose* value>> LLVMDisposeExecutionEngine ;

: <engine> ( -- engine )
    <provider> [
        dup value>> f <void*> f <void*>
        [ swapd 0 swap LLVMCreateJITCompiler drop ] 2keep
        *void* [ llvm-throw ] when* *void* LLVMExecutionEngine <dispose>
        swap t >>disposed drop
    ] with-disposal ;

: resolve-type ( callable/alien -- type )
    dup callable? [ call( -- type ) ] when ;

: <function-type> ( args -- type )
    [ resolve-type ] map
    unclip swap [ >void*-array ] keep length 0 LLVMFunctionType ;

: >>cc ( function calling-convention -- function )
    dupd LLVMSetFunctionCallConv ;

: params>> ( function -- array )
    dup LLVMCountParams "LLVMValueRef" <c-array> [ LLVMGetParams ] keep
    byte-array>void*-array >array ;

: get-param ( name -- value )
    function params>> swap [ swap LLVMGetValueName = ] curry find nip ;

: set-param-names ( names function -- )
    params>> swap [ LLVMSetValueName ] 2each ;

: <function> ( args -- function )
    module value>> over first second pick
    [ first ] map <function-type> LLVMAddFunction LLVMCCallConv >>cc tuck
    [ rest [ second ] map ] dip set-param-names ;

: global>pointer ( value -- alien ) engine value>> swap LLVMGetPointerToGlobal ;

: find-function ( name -- fn )
    engine value>> swap f <void*> [ LLVMFindFunction drop ] keep *void* ;