! Copyright (C) 2009 Matthew Willis, 2017 Björn Lindqvist
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax ldcache ;
IN: llvm.ffi

<<
"llvm" "LLVM-3.8" find-so cdecl add-library
>>

LIBRARY: llvm

CONSTANT: LLVMAbortProcessAction    0
CONSTANT: LLVMPrintMessageAction    1
CONSTANT: LLVMReturnStatusAction    2

TYPEDEF: uint unsigned
TYPEDEF: unsigned enum
TYPEDEF: int LLVMBool

! Reference types
TYPEDEF: void* LLVMExecutionEngineRef
TYPEDEF: void* LLVMModuleRef
TYPEDEF: void* LLVMPassManagerRef
TYPEDEF: void* LLVMModuleProviderRef
TYPEDEF: void* LLVMTypeRef
TYPEDEF: void* LLVMTypeHandleRef
TYPEDEF: void* LLVMValueRef
TYPEDEF: void* LLVMBasicBlockRef
TYPEDEF: void* LLVMBuilderRef
TYPEDEF: void* LLVMMemoryBufferRef

! Modules
FUNCTION: LLVMModuleRef LLVMModuleCreateWithName ( c-string ModuleID )
FUNCTION: void LLVMDisposeModule ( LLVMModuleRef M )
FUNCTION: void LLVMDumpModule ( LLVMModuleRef M )
FUNCTION: LLVMBool LLVMVerifyModule ( LLVMModuleRef M, int Action, char **OutMessage )
FUNCTION: c-string LLVMGetTarget ( LLVMModuleRef M )
DESTRUCTOR: LLVMDisposeModule

! Types
FUNCTION: LLVMTypeRef LLVMInt1Type ( )
FUNCTION: LLVMTypeRef LLVMInt8Type ( )
FUNCTION: LLVMTypeRef LLVMInt16Type ( )
FUNCTION: LLVMTypeRef LLVMInt32Type ( )
FUNCTION: LLVMTypeRef LLVMInt64Type ( )
FUNCTION: LLVMTypeRef LLVMIntType ( unsigned NumBits )
FUNCTION: LLVMTypeRef LLVMFunctionType ( LLVMTypeRef ReturnType,
                                         LLVMTypeRef* ParamTypes,
                                         unsigned ParamCount, int IsVarArg )

! Values
FUNCTION: LLVMValueRef LLVMAddFunction ( LLVMModuleRef M,
                                         c-string Name,
                                         LLVMTypeRef FunctionTy )
FUNCTION: LLVMValueRef LLVMGetParam ( LLVMValueRef Fn,
                                      unsigned index )
FUNCTION: c-string LLVMGetValueName ( LLVMValueRef Val )

! Basic blocks
FUNCTION: LLVMBasicBlockRef LLVMAppendBasicBlock ( LLVMValueRef Fn,
                                                   c-string Name )

! Builders
FUNCTION: LLVMBuilderRef LLVMCreateBuilder ( )
FUNCTION: void LLVMDisposeBuilder ( LLVMBuilderRef Builder )
FUNCTION: void LLVMPositionBuilderBefore ( LLVMBuilderRef Builder,
                                           LLVMValueRef Instr )
FUNCTION: void LLVMPositionBuilderAtEnd ( LLVMBuilderRef Builder,
                                          LLVMBasicBlockRef Block )

FUNCTION: LLVMValueRef LLVMBuildAdd ( LLVMBuilderRef Builder,
                                      LLVMValueRef LHS,
                                      LLVMValueRef RHS,
                                      c-string Name )
FUNCTION: LLVMValueRef LLVMBuildSub ( LLVMBuilderRef Builder,
                                      LLVMValueRef LHS,
                                      LLVMValueRef RHS,
                                      c-string Name )
FUNCTION: LLVMValueRef LLVMBuildRet ( LLVMBuilderRef Builder,
                                      LLVMValueRef V )
DESTRUCTOR: LLVMDisposeBuilder

! Engines
FUNCTION: LLVMBool LLVMCreateExecutionEngineForModule (
    LLVMExecutionEngineRef* OutEE,
    LLVMModuleRef M,
    char **OutMessage )
FUNCTION: void LLVMDisposeExecutionEngine ( LLVMExecutionEngineRef E )
DESTRUCTOR: LLVMDisposeExecutionEngine

! Memory buffers
FUNCTION: LLVMBool LLVMCreateMemoryBufferWithContentsOfFile (
    c-string Path,
    LLVMMemoryBufferRef* OutMemBuf,
    c-string* OutMessage )
FUNCTION: void LLVMDisposeMemoryBuffer ( LLVMMemoryBufferRef MemBuf )
FUNCTION: size_t LLVMGetBufferSize ( LLVMMemoryBufferRef MemBuf )
FUNCTION: int LLVMParseBitcode ( LLVMMemoryBufferRef MemBuf,
                                 LLVMModuleRef* OutModule,
                                 c-string* OutMessage )

! Module providers
FUNCTION: LLVMModuleProviderRef LLVMCreateModuleProviderForExistingModule ( LLVMModuleRef M )
FUNCTION: void LLVMDisposeModuleProvider ( LLVMModuleProviderRef MP )

! Messages
FUNCTION: void LLVMDisposeMessage ( char *Message )
