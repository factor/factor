! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.libraries alien.syntax llvm.core ;
IN: llvm.engine

<<

"LLVMExecutionEngine" add-llvm-library
"LLVMTarget" add-llvm-library
"LLVMAnalysis" add-llvm-library
"LLVMipa" add-llvm-library
"LLVMTransformUtils" add-llvm-library
"LLVMScalarOpts" add-llvm-library
"LLVMCodeGen" add-llvm-library
"LLVMAsmPrinter" add-llvm-library
"LLVMSelectionDAG" add-llvm-library
"LLVMX86CodeGen" add-llvm-library
"LLVMJIT" add-llvm-library
"LLVMInterpreter" add-llvm-library

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
( LLVMExecutionEngineRef *OutEE, LLVMModuleProviderRef MP, char** OutError ) ;

FUNCTION: int LLVMCreateJITCompiler
( LLVMExecutionEngineRef* OutJIT, LLVMModuleProviderRef MP, unsigned OptLevel, char** OutError ) ;

FUNCTION: void LLVMDisposeExecutionEngine ( LLVMExecutionEngineRef EE ) ;

FUNCTION: void LLVMFreeMachineCodeForFunction ( LLVMExecutionEngineRef EE, LLVMValueRef F ) ;

FUNCTION: void LLVMAddModuleProvider ( LLVMExecutionEngineRef EE, LLVMModuleProviderRef MP ) ;

FUNCTION: int LLVMRemoveModuleProvider
( LLVMExecutionEngineRef EE, LLVMModuleProviderRef MP, LLVMModuleRef* OutMod, char** OutError ) ;

FUNCTION: int LLVMFindFunction
( LLVMExecutionEngineRef EE, char* Name, LLVMValueRef* OutFn ) ;

FUNCTION: void* LLVMGetPointerToGlobal ( LLVMExecutionEngineRef EE, LLVMValueRef Global ) ;

FUNCTION: LLVMGenericValueRef LLVMRunFunction
( LLVMExecutionEngineRef EE, LLVMValueRef F, unsigned NumArgs, LLVMGenericValueRef* Args ) ;