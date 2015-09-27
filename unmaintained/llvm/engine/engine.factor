! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax kernel
llvm.core sequences ;
IN: llvm.engine

<<
{
    "LLVMExecutionEngine" "LLVMTarget" "LLVMAnalysis" "LLVMipa"
    "LLVMTransformUtils" "LLVMScalarOpts" "LLVMCodeGen"
    "LLVMAsmPrinter" "LLVMSelectionDAG" "LLVMX86CodeGen"
    "LLVMJIT" "LLVMInterpreter"
} [ add-llvm-library ] each
>>

! llvm-c/ExecutionEngine.h

LIBRARY: LLVMExecutionEngine

TYPEDEF: void* LLVMGenericValueRef
TYPEDEF: void* LLVMExecutionEngineRef

FUNCTION: LLVMGenericValueRef LLVMCreateGenericValueOfInt
( LLVMTypeRef Ty, ulonglong N, int IsSigned ) ;

FUNCTION: ulonglong LLVMGenericValueToInt
( LLVMGenericValueRef GenVal, int IsSigned ) ;

FUNCTION: int LLVMCreateExecutionEngine
( LLVMExecutionEngineRef *OutEE, LLVMModuleProviderRef MP, c-string* OutError ) ;

FUNCTION: int LLVMCreateJITCompiler
( LLVMExecutionEngineRef* OutJIT, LLVMModuleProviderRef MP, unsigned OptLevel, c-string* OutError ) ;

FUNCTION: void LLVMDisposeExecutionEngine ( LLVMExecutionEngineRef EE ) ;

FUNCTION: void LLVMFreeMachineCodeForFunction ( LLVMExecutionEngineRef EE, LLVMValueRef F ) ;

FUNCTION: void LLVMAddModuleProvider ( LLVMExecutionEngineRef EE, LLVMModuleProviderRef MP ) ;

FUNCTION: int LLVMRemoveModuleProvider
( LLVMExecutionEngineRef EE, LLVMModuleProviderRef MP, LLVMModuleRef* OutMod, c-string* OutError ) ;

FUNCTION: int LLVMFindFunction
( LLVMExecutionEngineRef EE, c-string Name, LLVMValueRef* OutFn ) ;

FUNCTION: void* LLVMGetPointerToGlobal ( LLVMExecutionEngineRef EE, LLVMValueRef Global ) ;

FUNCTION: LLVMGenericValueRef LLVMRunFunction
( LLVMExecutionEngineRef EE, LLVMValueRef F, unsigned NumArgs, LLVMGenericValueRef* Args ) ;
