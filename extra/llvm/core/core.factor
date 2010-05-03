! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax system sequences combinators kernel alien.c-types ;

IN: llvm.core

<<

: add-llvm-library ( name -- )
    dup
    {
        { [ os macosx? ] [ "/usr/local/lib/lib" ".dylib" surround ] }
        { [ os windows? ] [ ".dll" append ] }
        { [ os unix? ] [ "lib" ".so" surround ] }
    } cond cdecl add-library ;

"LLVMSystem" add-llvm-library
"LLVMSupport" add-llvm-library
"LLVMCore" add-llvm-library
"LLVMBitReader" add-llvm-library

>>

! llvm-c/Core.h

LIBRARY: LLVMCore

TYPEDEF: uint unsigned
TYPEDEF: unsigned enum

ENUM: LLVMAttribute
    { LLVMZExtAttribute         BIN: 1 }
    { LLVMSExtAttribute         BIN: 10 }
    { LLVMNoReturnAttribute     BIN: 100 }
    { LLVMInRegAttribute        BIN: 1000 }
    { LLVMStructRetAttribute    BIN: 10000 }
    { LLVMNoUnwindAttribute     BIN: 100000 }
    { LLVMNoAliasAttribute      BIN: 1000000 }
    { LLVMByValAttribute        BIN: 10000000 }
    { LLVMNestAttribute         BIN: 100000000 }
    { LLVMReadNoneAttribute     BIN: 1000000000 }
    { LLVMReadOnlyAttribute     BIN: 10000000000 } ;

ENUM: LLVMTypeKind
  LLVMVoidTypeKind
  LLVMFloatTypeKind
  LLVMDoubleTypeKind
  LLVMX86_FP80TypeKind
  LLVMFP128TypeKind
  LLVMPPC_FP128TypeKind
  LLVMLabelTypeKind
  LLVMMetadataTypeKind
  LLVMIntegerTypeKind
  LLVMFunctionTypeKind
  LLVMStructTypeKind
  LLVMArrayTypeKind
  LLVMPointerTypeKind
  LLVMOpaqueTypeKind
  LLVMVectorTypeKind ;

ENUM: LLVMLinkage
  LLVMExternalLinkage
  LLVMLinkOnceLinkage
  LLVMWeakLinkage
  LLVMAppendingLinkage
  LLVMInternalLinkage
  LLVMDLLImportLinkage
  LLVMDLLExportLinkage
  LLVMExternalWeakLinkage
  LLVMGhostLinkage ;

ENUM: LLVMVisibility
  LLVMDefaultVisibility
  LLVMHiddenVisibility
  LLVMProtectedVisibility ;

ENUM: LLVMCallConv
  { LLVMCCallConv             0 }
  { LLVMFastCallConv          8 }
  { LLVMColdCallConv          9 }
  { LLVMX86StdcallCallConv    64 }
  { LLVMX86FastcallCallConv   65 } ;

ENUM: LLVMIntPredicate
  { LLVMIntEQ                 32 }
  { LLVMIntNE                 33 }
  { LLVMIntUGT                34 }
  { LLVMIntUGE                35 }
  { LLVMIntULT                36 }
  { LLVMIntULE                37 }
  { LLVMIntSGT                38 }
  { LLVMIntSGE                39 }
  { LLVMIntSLT                40 }
  { LLVMIntSLE                41 } ;

ENUM: LLVMRealPredicate
  LLVMRealPredicateFalse
  LLVMRealOEQ
  LLVMRealOGT
  LLVMRealOGE
  LLVMRealOLT
  LLVMRealOLE
  LLVMRealONE
  LLVMRealORD
  LLVMRealUNO
  LLVMRealUEQ
  LLVMRealUGT
  LLVMRealUGE
  LLVMRealULT
  LLVMRealULE
  LLVMRealUNE
  LLVMRealPredicateTrue ;

! Opaque Types

TYPEDEF: void* LLVMModuleRef

TYPEDEF: void* LLVMPassManagerRef

TYPEDEF: void* LLVMModuleProviderRef

TYPEDEF: void* LLVMTypeRef

TYPEDEF: void* LLVMTypeHandleRef

TYPEDEF: void* LLVMValueRef

TYPEDEF: void* LLVMBasicBlockRef

TYPEDEF: void* LLVMBuilderRef

TYPEDEF: void* LLVMMemoryBufferRef

! Functions

FUNCTION: void LLVMDisposeMessage ( c-string Message ) ;

FUNCTION: LLVMModuleRef LLVMModuleCreateWithName ( c-string ModuleID ) ;

FUNCTION: int LLVMAddTypeName ( LLVMModuleRef M, c-string Name, LLVMTypeRef Ty ) ;

FUNCTION: void LLVMDisposeModule ( LLVMModuleRef M ) ;

FUNCTION: void LLVMDumpModule ( LLVMModuleRef M ) ;

FUNCTION: LLVMModuleProviderRef
LLVMCreateModuleProviderForExistingModule ( LLVMModuleRef M ) ;

FUNCTION: void LLVMDisposeModuleProvider ( LLVMModuleProviderRef MP ) ;

! Types

! LLVM types conform to the following hierarchy:
!  
!    types:
!      integer type
!      real type
!      function type
!      sequence types:
!        array type
!        pointer type
!        vector type
!      void type
!      label type
!      opaque type

! See llvm::LLVMTypeKind::getTypeID.
FUNCTION: LLVMTypeKind LLVMGetTypeKind ( LLVMTypeRef Ty ) ;

! Operations on integer types
FUNCTION: LLVMTypeRef LLVMInt1Type ( ) ;
FUNCTION: LLVMTypeRef LLVMInt8Type ( ) ;
FUNCTION: LLVMTypeRef LLVMInt16Type ( ) ;
FUNCTION: LLVMTypeRef LLVMInt32Type ( ) ;
FUNCTION: LLVMTypeRef LLVMInt64Type ( ) ;
FUNCTION: LLVMTypeRef LLVMIntType ( unsigned NumBits ) ;
FUNCTION: unsigned LLVMGetIntTypeWidth ( LLVMTypeRef IntegerTy ) ;

! Operations on real types
FUNCTION: LLVMTypeRef LLVMFloatType ( ) ;
FUNCTION: LLVMTypeRef LLVMDoubleType ( ) ;
FUNCTION: LLVMTypeRef LLVMX86FP80Type ( ) ;
FUNCTION: LLVMTypeRef LLVMFP128Type ( ) ;
FUNCTION: LLVMTypeRef LLVMPPCFP128Type ( ) ;

! Operations on function types
FUNCTION: LLVMTypeRef
LLVMFunctionType ( LLVMTypeRef ReturnType, LLVMTypeRef* ParamTypes, unsigned ParamCount, int IsVarArg ) ;
FUNCTION: int LLVMIsFunctionVarArg ( LLVMTypeRef FunctionTy ) ;
FUNCTION: LLVMTypeRef LLVMGetReturnType ( LLVMTypeRef FunctionTy ) ;
FUNCTION: unsigned LLVMCountParamTypes ( LLVMTypeRef FunctionTy ) ;
FUNCTION: void LLVMGetParamTypes ( LLVMTypeRef FunctionTy, LLVMTypeRef* Dest ) ;

! Operations on struct types
FUNCTION: LLVMTypeRef
LLVMStructType ( LLVMTypeRef* ElementTypes, unsigned ElementCount, int Packed ) ;
FUNCTION: unsigned LLVMCountStructElementTypes ( LLVMTypeRef StructTy ) ;
FUNCTION: void LLVMGetStructElementTypes ( LLVMTypeRef StructTy, LLVMTypeRef* Dest ) ;
FUNCTION: int LLVMIsPackedStruct ( LLVMTypeRef StructTy ) ;

! Operations on array, pointer, and vector types (sequence types)
FUNCTION: LLVMTypeRef LLVMArrayType ( LLVMTypeRef ElementType, unsigned ElementCount ) ;
FUNCTION: LLVMTypeRef LLVMPointerType ( LLVMTypeRef ElementType, unsigned AddressSpace ) ;
FUNCTION: LLVMTypeRef LLVMVectorType ( LLVMTypeRef ElementType, unsigned ElementCount ) ;

FUNCTION: LLVMTypeRef LLVMGetElementType ( LLVMTypeRef Ty ) ;
FUNCTION: unsigned LLVMGetArrayLength ( LLVMTypeRef ArrayTy ) ;
FUNCTION: unsigned LLVMGetPointerAddressSpace ( LLVMTypeRef PointerTy ) ;
FUNCTION: unsigned LLVMGetVectorSize ( LLVMTypeRef VectorTy ) ;

! Operations on other types
FUNCTION: LLVMTypeRef LLVMVoidType ( ) ;
FUNCTION: LLVMTypeRef LLVMLabelType ( ) ;
FUNCTION: LLVMTypeRef LLVMOpaqueType ( ) ;

! Operations on type handles
FUNCTION: LLVMTypeHandleRef LLVMCreateTypeHandle ( LLVMTypeRef PotentiallyAbstractTy ) ;
FUNCTION: void LLVMRefineType ( LLVMTypeRef AbstractTy, LLVMTypeRef ConcreteTy ) ;
FUNCTION: LLVMTypeRef LLVMResolveTypeHandle ( LLVMTypeHandleRef TypeHandle ) ;
FUNCTION: void LLVMDisposeTypeHandle ( LLVMTypeHandleRef TypeHandle ) ;

! Types end

FUNCTION: unsigned LLVMCountParams ( LLVMValueRef Fn ) ;

FUNCTION: void LLVMGetParams ( LLVMValueRef Fn, LLVMValueRef* Params ) ;

FUNCTION: LLVMValueRef
LLVMAddFunction ( LLVMModuleRef M, c-string Name, LLVMTypeRef FunctionTy ) ;

FUNCTION: LLVMValueRef LLVMGetFirstFunction ( LLVMModuleRef M ) ;

FUNCTION: LLVMValueRef LLVMGetNextFunction ( LLVMValueRef Fn ) ;

FUNCTION: unsigned LLVMGetFunctionCallConv ( LLVMValueRef Fn ) ;

FUNCTION: void LLVMSetFunctionCallConv ( LLVMValueRef Fn, unsigned CC ) ;

FUNCTION: LLVMBasicBlockRef
LLVMAppendBasicBlock ( LLVMValueRef Fn, c-string Name ) ;

FUNCTION: LLVMValueRef LLVMGetBasicBlockParent ( LLVMBasicBlockRef BB ) ;

! Values

FUNCTION: LLVMTypeRef LLVMTypeOf ( LLVMValueRef Val ) ;
FUNCTION: c-string LLVMGetValueName ( LLVMValueRef Val ) ;
FUNCTION: void LLVMSetValueName ( LLVMValueRef Val, c-string Name ) ;
FUNCTION: void LLVMDumpValue ( LLVMValueRef Val ) ;

! Instruction Builders

FUNCTION: LLVMBuilderRef LLVMCreateBuilder ( ) ;
FUNCTION: void LLVMPositionBuilder
( LLVMBuilderRef Builder, LLVMBasicBlockRef Block, LLVMValueRef Instr ) ;
FUNCTION: void LLVMPositionBuilderBefore
( LLVMBuilderRef Builder, LLVMValueRef Instr ) ;
FUNCTION: void LLVMPositionBuilderAtEnd
( LLVMBuilderRef Builder, LLVMBasicBlockRef Block ) ;
FUNCTION: LLVMBasicBlockRef LLVMGetInsertBlock
( LLVMBuilderRef Builder ) ;
FUNCTION: void LLVMClearInsertionPosition
( LLVMBuilderRef Builder ) ;
FUNCTION: void LLVMInsertIntoBuilder
( LLVMBuilderRef Builder, LLVMValueRef Instr ) ;
FUNCTION: void LLVMDisposeBuilder
( LLVMBuilderRef Builder ) ;

! IB Terminators

FUNCTION: LLVMValueRef LLVMBuildRetVoid
( LLVMBuilderRef Builder ) ;
FUNCTION: LLVMValueRef LLVMBuildRet
( LLVMBuilderRef Builder, LLVMValueRef V ) ;
FUNCTION: LLVMValueRef LLVMBuildBr
( LLVMBuilderRef Builder, LLVMBasicBlockRef Dest ) ;
FUNCTION: LLVMValueRef LLVMBuildCondBr
( LLVMBuilderRef Builder, LLVMValueRef If, LLVMBasicBlockRef Then, LLVMBasicBlockRef Else ) ;
FUNCTION: LLVMValueRef LLVMBuildSwitch
( LLVMBuilderRef Builder, LLVMValueRef V, LLVMBasicBlockRef Else, unsigned NumCases ) ;
FUNCTION: LLVMValueRef LLVMBuildInvoke
( LLVMBuilderRef Builder, LLVMValueRef Fn, LLVMValueRef* Args, unsigned NumArgs,
  LLVMBasicBlockRef Then, LLVMBasicBlockRef Catch, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildUnwind
( LLVMBuilderRef Builder ) ;
FUNCTION: LLVMValueRef LLVMBuildUnreachable
( LLVMBuilderRef Builder ) ;

! IB Add Case to Switch

FUNCTION: void LLVMAddCase
( LLVMValueRef Switch, LLVMValueRef OnVal, LLVMBasicBlockRef Dest ) ;

! IB Arithmetic

FUNCTION: LLVMValueRef LLVMBuildAdd
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildSub
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildMul
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildUDiv
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildSDiv
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildFDiv
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildURem
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildSRem
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildFRem
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildShl
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildLShr
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildAShr
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildAnd
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildOr
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildXor
( LLVMBuilderRef Builder, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildNeg
( LLVMBuilderRef Builder, LLVMValueRef V, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildNot
( LLVMBuilderRef Builder, LLVMValueRef V, c-string Name ) ;

! IB Memory

FUNCTION: LLVMValueRef LLVMBuildMalloc
( LLVMBuilderRef Builder, LLVMTypeRef Ty, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildArrayMalloc
( LLVMBuilderRef Builder, LLVMTypeRef Ty, LLVMValueRef Val, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildAlloca
( LLVMBuilderRef Builder, LLVMTypeRef Ty, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildArrayAlloca
( LLVMBuilderRef Builder, LLVMTypeRef Ty, LLVMValueRef Val, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildFree
( LLVMBuilderRef Builder, LLVMValueRef PointerVal ) ;
FUNCTION: LLVMValueRef LLVMBuildLoad
( LLVMBuilderRef Builder, LLVMValueRef PointerVal, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildStore
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMValueRef Ptr ) ;
FUNCTION: LLVMValueRef LLVMBuildGEP
( LLVMBuilderRef B, LLVMValueRef Pointer, LLVMValueRef* Indices,
  unsigned NumIndices, c-string Name ) ;

! IB Casts

FUNCTION: LLVMValueRef LLVMBuildTrunc
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildZExt
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildSExt
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildFPToUI
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildFPToSI
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildUIToFP
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildSIToFP
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildFPTrunc
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildFPExt
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildPtrToInt
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildIntToPtr
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildBitCast
( LLVMBuilderRef Builder, LLVMValueRef Val, LLVMTypeRef DestTy, c-string Name ) ;

! IB Comparisons

FUNCTION: LLVMValueRef LLVMBuildICmp
( LLVMBuilderRef Builder, LLVMIntPredicate Op, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildFCmp
( LLVMBuilderRef Builder, LLVMRealPredicate Op, LLVMValueRef LHS, LLVMValueRef RHS, c-string Name ) ;

! IB Misc Instructions

FUNCTION: LLVMValueRef LLVMBuildPhi
( LLVMBuilderRef Builder, LLVMTypeRef Ty, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildCall
( LLVMBuilderRef Builder, LLVMValueRef Fn, LLVMValueRef* Args, unsigned NumArgs, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildSelect
( LLVMBuilderRef Builder, LLVMValueRef If, LLVMValueRef Then, LLVMValueRef Else, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildVAArg
( LLVMBuilderRef Builder, LLVMValueRef List, LLVMTypeRef Ty, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildExtractElement
( LLVMBuilderRef Builder, LLVMValueRef VecVal, LLVMValueRef Index, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildInsertElement
( LLVMBuilderRef Builder, LLVMValueRef VecVal, LLVMValueRef EltVal, LLVMValueRef Index, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildShuffleVector
( LLVMBuilderRef Builder, LLVMValueRef V1, LLVMValueRef V2, LLVMValueRef Mask, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildExtractValue
( LLVMBuilderRef Builder, LLVMValueRef AggVal, unsigned Index, c-string Name ) ;
FUNCTION: LLVMValueRef LLVMBuildInsertValue
( LLVMBuilderRef Builder, LLVMValueRef AggVal, LLVMValueRef EltVal, unsigned Index, c-string Name ) ;

! Memory Buffers/Bit Reader

FUNCTION: int LLVMCreateMemoryBufferWithContentsOfFile
( c-string Path, LLVMMemoryBufferRef* OutMemBuf, c-string* OutMessage ) ;

FUNCTION: void LLVMDisposeMemoryBuffer ( LLVMMemoryBufferRef MemBuf ) ;

LIBRARY: LLVMBitReader

FUNCTION: int LLVMParseBitcode
( LLVMMemoryBufferRef MemBuf, LLVMModuleRef* OutModule, c-string* OutMessage ) ;
 
FUNCTION: int LLVMGetBitcodeModuleProvider
( LLVMMemoryBufferRef MemBuf, LLVMModuleProviderRef* OutMP, c-string* OutMessage ) ;
