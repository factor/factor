! Copyright (C) 2009 Matthew Willis, 2017 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax combinators
kernel ldcache system ;
IN: llvm.ffi

<< "llvm" {
    { [ os linux? ] [ "LLVM-3.9" find-so ] }
    { [ os macosx? ] [ "/usr/local/opt/llvm/lib/libLLVM.dylib" ] }
    [ f ]
} cond [ cdecl add-library ] [ drop ] if*
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
TYPEDEF: void* LLVMValueRef
TYPEDEF: void* LLVMBasicBlockRef
TYPEDEF: void* LLVMBuilderRef
TYPEDEF: void* LLVMMemoryBufferRef
TYPEDEF: void* LLVMTargetRef
TYPEDEF: void* LLVMPassRegistryRef

! Type types
ENUM: LLVMTypeKind
    LLVMVoidTypeKind
    LLVMHalfTypeKind
    LLVMFloatTypeKind
    LLVMDoubleTypeKind
    LLVMX86_FP80TypeKind
    LLVMFP128TypeKind
    LLVMPPC_FP128TypeKind
    LLVMLabelTypeKind
    LLVMIntegerTypeKind
    LLVMFunctionTypeKind
    LLVMStructTypeKind
    LLVMArrayTypeKind
    LLVMPointerTypeKind
    LLVMVectorTypeKind
    LLVMMetadataTypeKind
    LLVMX86_MMXTypeKind
    LLVMTokenTypeKind ;

! Modules
FUNCTION: LLVMModuleRef LLVMModuleCreateWithName ( c-string ModuleID )
FUNCTION: void LLVMDisposeModule ( LLVMModuleRef M )
FUNCTION: void LLVMDumpModule ( LLVMModuleRef M )
FUNCTION: LLVMBool LLVMVerifyModule ( LLVMModuleRef M, int Action, char **OutMessage )
FUNCTION: c-string LLVMGetTarget ( LLVMModuleRef M )

! Types

! ! Basic  types
FUNCTION: LLVMTypeRef LLVMFloatType ( )
FUNCTION: LLVMTypeRef LLVMDoubleType ( )

FUNCTION: LLVMTypeRef LLVMX86FP80Type ( )
FUNCTION: LLVMTypeRef LLVMFP128Type ( )
FUNCTION: LLVMTypeRef LLVMPPCFP128Type ( )

FUNCTION: LLVMTypeRef LLVMVoidType ( )
FUNCTION: LLVMTypeRef LLVMLabelType ( )

! ! Integer type
FUNCTION: LLVMTypeRef LLVMInt1Type ( )
FUNCTION: LLVMTypeRef LLVMInt8Type ( )
FUNCTION: LLVMTypeRef LLVMInt16Type ( )
FUNCTION: LLVMTypeRef LLVMInt32Type ( )
FUNCTION: LLVMTypeRef LLVMInt64Type ( )
FUNCTION: LLVMTypeRef LLVMIntType ( unsigned NumBits )
FUNCTION: unsigned LLVMGetIntTypeWidth ( LLVMTypeRef IntegerTy )

! ! Array type
FUNCTION: LLVMTypeRef LLVMArrayType ( LLVMTypeRef ElementType, unsigned ElementCount )
FUNCTION: unsigned LLVMGetArrayLength ( LLVMTypeRef ArrayTy )

! ! Pointer type
FUNCTION: LLVMTypeRef LLVMPointerType ( LLVMTypeRef ElementType, unsigned AddressSpace )

! ! Vector type
FUNCTION: LLVMTypeRef LLVMVectorType ( LLVMTypeRef ElementType, unsigned ElementCount )
FUNCTION: unsigned LLVMGetVectorSize ( LLVMTypeRef VectorTy )

! ! Function type
FUNCTION: LLVMTypeRef LLVMFunctionType ( LLVMTypeRef ReturnType,
                                         LLVMTypeRef* ParamTypes,
                                         unsigned ParamCount, int IsVarArg )
FUNCTION: LLVMTypeRef LLVMGetReturnType ( LLVMTypeRef FunctionTy )
FUNCTION: int LLVMIsFunctionVarArg ( LLVMTypeRef FunctionTy )
FUNCTION: unsigned LLVMCountParamTypes ( LLVMTypeRef FunctionTy )
FUNCTION: void LLVMGetParamTypes ( LLVMTypeRef FunctionTy, LLVMTypeRef* Dest )

! ! Struct type
FUNCTION: LLVMTypeRef LLVMStructType ( LLVMTypeRef* ElementTypes,
                                       unsigned ElementCount, int Packed )
FUNCTION: int LLVMIsPackedStruct ( LLVMTypeRef StructTy )
FUNCTION: unsigned LLVMCountStructElementTypes ( LLVMTypeRef StructTy )
FUNCTION: void LLVMGetStructElementTypes ( LLVMTypeRef StructTy, LLVMTypeRef* Dest )

! ! Type util
FUNCTION: LLVMTypeKind LLVMGetTypeKind ( LLVMTypeRef Ty )
FUNCTION: LLVMTypeRef LLVMGetElementType ( LLVMTypeRef Ty )

! Values
FUNCTION: LLVMValueRef LLVMAddFunction ( LLVMModuleRef M,
                                         c-string Name,
                                         LLVMTypeRef FunctionTy )
FUNCTION: LLVMValueRef LLVMGetParam ( LLVMValueRef Fn,
                                      unsigned index )
FUNCTION: c-string LLVMGetValueName ( LLVMValueRef Val )
FUNCTION: unsigned LLVMCountParams ( LLVMValueRef Fn )
FUNCTION: LLVMTypeRef LLVMTypeOf ( LLVMValueRef Val )
FUNCTION: void LLVMDumpValue ( LLVMValueRef Val )

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
FUNCTION: LLVMValueRef LLVMBuildMul ( LLVMBuilderRef Builder,
                                      LLVMValueRef LHS,
                                      LLVMValueRef RHS,
                                      c-string Name )
FUNCTION: LLVMValueRef LLVMBuildRet ( LLVMBuilderRef Builder,
                                      LLVMValueRef V )

! Execution Engines
FUNCTION: LLVMBool LLVMCreateExecutionEngineForModule (
    LLVMExecutionEngineRef* OutEE,
    LLVMModuleRef M,
    char **OutMessage )
FUNCTION: void LLVMDisposeExecutionEngine ( LLVMExecutionEngineRef E )
FUNCTION: uint64_t LLVMGetGlobalValueAddress ( LLVMExecutionEngineRef E, c-string name )
FUNCTION: LLVMBool LLVMFindFunction ( LLVMExecutionEngineRef E,
                                      c-string name,
                                      LLVMValueRef OutFn )
FUNCTION: void* LLVMGetPointerToGlobal ( LLVMExecutionEngineRef EE,
                                         LLVMValueRef Global )

! Memory buffers
FUNCTION: LLVMBool LLVMCreateMemoryBufferWithContentsOfFile (
    c-string Path,
    LLVMMemoryBufferRef* OutMemBuf,
    c-string* OutMessage )
FUNCTION: void LLVMDisposeMemoryBuffer ( LLVMMemoryBufferRef MemBuf )
FUNCTION: size_t LLVMGetBufferSize ( LLVMMemoryBufferRef MemBuf )
! Deprecated and should be replaced with LLVMParseBitcode2.
FUNCTION: int LLVMParseBitcode ( LLVMMemoryBufferRef MemBuf,
                                 LLVMModuleRef* OutModule,
                                 c-string* OutMessage )

! Module providers
FUNCTION: LLVMModuleProviderRef LLVMCreateModuleProviderForExistingModule ( LLVMModuleRef M )
FUNCTION: void LLVMDisposeModuleProvider ( LLVMModuleProviderRef MP )

! Targets
FUNCTION: LLVMTargetRef LLVMGetFirstTarget ( )
FUNCTION: c-string LLVMGetTargetName ( LLVMTargetRef T )

! Messages
FUNCTION: void LLVMDisposeMessage ( char *Message )

! Pass Registry
FUNCTION: LLVMPassRegistryRef LLVMGetGlobalPassRegistry ( )

! Initialization
FUNCTION: void LLVMInitializeCore ( LLVMPassRegistryRef PR )
FUNCTION: void LLVMLinkInMCJIT ( )
FUNCTION: void LLVMInitializeX86AsmPrinter ( )
FUNCTION: void LLVMInitializeX86TargetInfo ( )
FUNCTION: void LLVMInitializeX86Target ( )
FUNCTION: void LLVMInitializeX86TargetMC ( )

! Removed symbols: LLVMCreateJITCompiler, LLVMCreateTypeHandle, LLVMOpaqueType
