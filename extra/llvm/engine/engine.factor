! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.libraries alien.syntax llvm.core ;
IN: llvm.engine

<<

"LLVMExecutionEngine" "/usr/local/lib/libLLVMExecutionEngine.dylib" "cdecl" add-library

"LLVMTarget" "/usr/local/lib/libLLVMTarget.dylib" "cdecl" add-library

"LLVMAnalysis" "/usr/local/lib/libLLVMAnalysis.dylib" "cdecl" add-library

"LLVMipa" "/usr/local/lib/libLLVMipa.dylib" "cdecl" add-library

"LLVMTransformUtils" "/usr/local/lib/libLLVMTransformUtils.dylib" "cdecl" add-library

"LLVMScalarOpts" "/usr/local/lib/libLLVMScalarOpts.dylib" "cdecl" add-library

"LLVMCodeGen" "/usr/local/lib/libLLVMCodeGen.dylib" "cdecl" add-library

"LLVMAsmPrinter" "/usr/local/lib/libLLVMAsmPrinter.dylib" "cdecl" add-library

"LLVMSelectionDAG" "/usr/local/lib/libLLVMSelectionDAG.dylib" "cdecl" add-library

"LLVMX86CodeGen" "/usr/local/lib/libLLVMX86CodeGen.dylib" "cdecl" add-library

"LLVMJIT" "/usr/local/lib/libLLVMJIT.dylib" "cdecl" add-library

"LLVMInterpreter.dylib" "/usr/local/lib/libLLVMInterpreter.dylib" "cdecl" add-library

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