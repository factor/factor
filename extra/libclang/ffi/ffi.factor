! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators io.directories io.pathnames kernel
sequences sorting.human system ;
IN: libclang.ffi

LIBRARY: clang

<<
: latest-libclang ( -- path/f )
    "/usr/lib/" ?qualified-directory-files
    [ file-name "llvm-" head? ] filter
    human-sort <reversed> ?first ;
>>

<< "clang" {
    { [ os windows? ] [ "libclang.dll" ] }
    { [ os macos? ] [ "/Library/Developer/CommandLineTools/usr/lib/libclang.dylib" ] }
    { [ os unix? ] [ latest-libclang "lib/libclang.so" append-path ] }
} cond cdecl add-library >>

CONSTANT: UINT_MAX 4294967295

TYPEDEF: void* CXClientData
TYPEDEF: void* CXCompilationDatabase
TYPEDEF: void* CXCompileCommand
TYPEDEF: void* CXCompileCommands
TYPEDEF: void* CXCompletionString
TYPEDEF: void* CXCursorSet
TYPEDEF: void* CXDiagnostic
TYPEDEF: void* CXDiagnosticSet
TYPEDEF: void* CXEvalResult
TYPEDEF: void* CXFile
TYPEDEF: void* CXIdxClientASTFile
TYPEDEF: void* CXIdxClientContainer
TYPEDEF: void* CXIdxClientEntity
TYPEDEF: void* CXIdxClientFile
TYPEDEF: void* CXIndex
TYPEDEF: void* CXIndexAction
TYPEDEF: void* CXModule
TYPEDEF: void* CXPrintingPolicy
TYPEDEF: void* CXRemapping
TYPEDEF: void* CXTargetInfo
TYPEDEF: void* CXTranslationUnit

STRUCT: CXToken
{ int_data uint[4] }
{ ptr_data void* } ;

ENUM: CXAvailabilityKind
{ CXAvailability_Available 0 }
{ CXAvailability_Deprecated 1 }
{ CXAvailability_NotAvailable 2 }
{ CXAvailability_NotAccessible 3 } ;

ENUM: CXBinaryOperatorKind
{ CXBinaryOperator_Invalid 0 } { CXBinaryOperator_PtrMemD 1 } { CXBinaryOperator_PtrMemI 2 }
{ CXBinaryOperator_Mul 3 } { CXBinaryOperator_Div 4 } { CXBinaryOperator_Rem 5 }
{ CXBinaryOperator_Add 6 } { CXBinaryOperator_Sub 7 } { CXBinaryOperator_Shl 8 }
{ CXBinaryOperator_Shr 9 } { CXBinaryOperator_Cmp 10 } { CXBinaryOperator_LT 11 }
{ CXBinaryOperator_GT 12 } { CXBinaryOperator_LE 13 } { CXBinaryOperator_GE 14 }
{ CXBinaryOperator_EQ 15 } { CXBinaryOperator_NE 16 } { CXBinaryOperator_And 17 }
{ CXBinaryOperator_Xor 18 } { CXBinaryOperator_Or 19 } { CXBinaryOperator_LAnd 20 }
{ CXBinaryOperator_LOr 21 } { CXBinaryOperator_Assign 22 } { CXBinaryOperator_MulAssign 23 }
{ CXBinaryOperator_DivAssign 24 } { CXBinaryOperator_RemAssign 25 } { CXBinaryOperator_AddAssign 26 }
{ CXBinaryOperator_SubAssign 27 } { CXBinaryOperator_ShlAssign 28 } { CXBinaryOperator_ShrAssign 29 }
{ CXBinaryOperator_AndAssign 30 } { CXBinaryOperator_XorAssign 31 } { CXBinaryOperator_OrAssign 32 }
{ CXBinaryOperator_Comma 33 } ;

ENUM: CXCallingConv
{ CXCallingConv_Default 0 }
{ CXCallingConv_C 1 }
{ CXCallingConv_X86StdCall 2 }
{ CXCallingConv_X86FastCall 3 }
{ CXCallingConv_X86ThisCall 4 }
{ CXCallingConv_X86Pascal 5 }
{ CXCallingConv_AAPCS 6 }
{ CXCallingConv_AAPCS_VFP 7 }
{ CXCallingConv_X86RegCall 8 }
{ CXCallingConv_IntelOclBicc 9 }
{ CXCallingConv_Win64 10 }
{ CXCallingConv_X86_64Win64 10 }
{ CXCallingConv_X86_64SysV 11 }
{ CXCallingConv_X86VectorCall 12 }
{ CXCallingConv_Swift 13 }
{ CXCallingConv_PreserveMost 14 }
{ CXCallingConv_PreserveAll 15 }
{ CXCallingConv_AArch64VectorCall 16 }
{ CXCallingConv_Invalid 100 }
{ CXCallingConv_Unexposed 200 }
{ CXCallingConv_SwiftAsync 17 }
{ CXCallingConv_AArch64SVEPCS 18 } ;

ENUM: CXChildVisitResult
{ CXChildVisit_Break 0 }
{ CXChildVisit_Continue 1 }
{ CXChildVisit_Recurse 2 } ;

ENUM: CXChoice
{ CXChoice_Default 0 }
{ CXChoice_Enabled 1 }
{ CXChoice_Disabled 2 } ;

ENUM: CXCommentInlineCommandRenderKind
{ CXCommentInlineCommandRenderKind_Normal 0 }
{ CXCommentInlineCommandRenderKind_Bold 1 }
{ CXCommentInlineCommandRenderKind_Monospaced 2 }
{ CXCommentInlineCommandRenderKind_Emphasized 3 } ;

ENUM: CXCommentKind
{ CXComment_Null 0 }
{ CXComment_Text 1 }
{ CXComment_InlineCommand 2 }
{ CXComment_HTMLStartTag 3 }
{ CXComment_HTMLEndTag 4 }
{ CXComment_Paragraph 5 }
{ CXComment_BlockCommand 6 }
{ CXComment_ParamCommand 7 }
{ CXComment_TParamCommand 8 }
{ CXComment_VerbatimBlockCommand 9 }
{ CXComment_VerbatimBlockLine 10 }
{ CXComment_VerbatimLine 11 }
{ CXComment_FullComment 12 } ;

ENUM: CXCommentParamPassDirection
{ CXCommentParamPassDirection_In 0 }
{ CXCommentParamPassDirection_Out 1 }
{ CXCommentParamPassDirection_InOut 2 } ;

ENUM: CXCompilationDatabase_Error
{ CXCompilationDatabase_NoError 0 }
{ CXCompilationDatabase_CanNotLoadDatabase 1 } ;

ENUM: CXCompletionChunkKind
{ CXCompletionChunk_Optional 0 }
{ CXCompletionChunk_TypedText 1 }
{ CXCompletionChunk_Text 2 }
{ CXCompletionChunk_Placeholder 3 }
{ CXCompletionChunk_Informative 4 }
{ CXCompletionChunk_CurrentParameter 5 }
{ CXCompletionChunk_LeftParen 6 }
{ CXCompletionChunk_RightParen 7 }
{ CXCompletionChunk_LeftBracket 8 }
{ CXCompletionChunk_RightBracket 9 }
{ CXCompletionChunk_LeftBrace 10 }
{ CXCompletionChunk_RightBrace 11 }
{ CXCompletionChunk_LeftAngle 12 }
{ CXCompletionChunk_RightAngle 13 }
{ CXCompletionChunk_Comma 14 }
{ CXCompletionChunk_ResultType 15 }
{ CXCompletionChunk_Colon 16 }
{ CXCompletionChunk_SemiColon 17 }
{ CXCompletionChunk_Equal 18 }
{ CXCompletionChunk_HorizontalSpace 19 }
{ CXCompletionChunk_VerticalSpace 20 } ;

ENUM: CXCursorKind
{ CXCursor_UnexposedDecl 1 } { CXCursor_StructDecl 2 } { CXCursor_UnionDecl 3 } { CXCursor_ClassDecl 4 }
{ CXCursor_EnumDecl 5 } { CXCursor_FieldDecl 6 } { CXCursor_EnumConstantDecl 7 } { CXCursor_FunctionDecl 8 }
{ CXCursor_VarDecl 9 } { CXCursor_ParmDecl 10 } { CXCursor_ObjCInterfaceDecl 11 } { CXCursor_ObjCCategoryDecl 12 }
{ CXCursor_ObjCProtocolDecl 13 } { CXCursor_ObjCPropertyDecl 14 } { CXCursor_ObjCIvarDecl 15 } { CXCursor_ObjCInstanceMethodDecl 16 }
{ CXCursor_ObjCClassMethodDecl 17 } { CXCursor_ObjCImplementationDecl 18 } { CXCursor_ObjCCategoryImplDecl 19 } { CXCursor_TypedefDecl 20 }
{ CXCursor_CXXMethod 21 } { CXCursor_Namespace 22 } { CXCursor_LinkageSpec 23 } { CXCursor_Constructor 24 }
{ CXCursor_Destructor 25 } { CXCursor_ConversionFunction 26 } { CXCursor_TemplateTypeParameter 27 } { CXCursor_NonTypeTemplateParameter 28 }
{ CXCursor_TemplateTemplateParameter 29 } { CXCursor_FunctionTemplate 30 } { CXCursor_ClassTemplate 31 } { CXCursor_ClassTemplatePartialSpecialization 32 }
{ CXCursor_NamespaceAlias 33 } { CXCursor_UsingDirective 34 } { CXCursor_UsingDeclaration 35 } { CXCursor_TypeAliasDecl 36 }
{ CXCursor_ObjCSynthesizeDecl 37 } { CXCursor_ObjCDynamicDecl 38 } { CXCursor_CXXAccessSpecifier 39 } { CXCursor_FirstDecl CXCursor_UnexposedDecl }
{ CXCursor_LastDecl CXCursor_CXXAccessSpecifier } { CXCursor_FirstRef 40 } { CXCursor_ObjCSuperClassRef 40 } { CXCursor_ObjCProtocolRef 41 }
{ CXCursor_ObjCClassRef 42 } { CXCursor_TypeRef 43 } { CXCursor_CXXBaseSpecifier 44 } { CXCursor_TemplateRef 45 }
{ CXCursor_NamespaceRef 46 } { CXCursor_MemberRef 47 } { CXCursor_LabelRef 48 } { CXCursor_OverloadedDeclRef 49 }
{ CXCursor_VariableRef 50 } { CXCursor_LastRef CXCursor_VariableRef } { CXCursor_FirstInvalid 70 } { CXCursor_InvalidFile 70 }
{ CXCursor_NoDeclFound 71 } { CXCursor_NotImplemented 72 } { CXCursor_InvalidCode 73 } { CXCursor_LastInvalid CXCursor_InvalidCode }
{ CXCursor_FirstExpr 100 } { CXCursor_UnexposedExpr 100 } { CXCursor_DeclRefExpr 101 } { CXCursor_MemberRefExpr 102 }
{ CXCursor_CallExpr 103 } { CXCursor_ObjCMessageExpr 104 } { CXCursor_BlockExpr 105 } { CXCursor_IntegerLiteral 106 }
{ CXCursor_FloatingLiteral 107 } { CXCursor_ImaginaryLiteral 108 } { CXCursor_StringLiteral 109 } { CXCursor_CharacterLiteral 110 }
{ CXCursor_ParenExpr 111 } { CXCursor_UnaryOperator 112 } { CXCursor_ArraySubscriptExpr 113 } { CXCursor_BinaryOperator 114 }
{ CXCursor_CompoundAssignOperator 115 } { CXCursor_ConditionalOperator 116 } { CXCursor_CStyleCastExpr 117 } { CXCursor_CompoundLiteralExpr 118 }
{ CXCursor_InitListExpr 119 } { CXCursor_AddrLabelExpr 120 } { CXCursor_StmtExpr 121 } { CXCursor_GenericSelectionExpr 122 }
{ CXCursor_GNUNullExpr 123 } { CXCursor_CXXStaticCastExpr 124 } { CXCursor_CXXDynamicCastExpr 125 } { CXCursor_CXXReinterpretCastExpr 126 }
{ CXCursor_CXXConstCastExpr 127 } { CXCursor_CXXFunctionalCastExpr 128 } { CXCursor_CXXTypeidExpr 129 } { CXCursor_CXXBoolLiteralExpr 130 }
{ CXCursor_CXXNullPtrLiteralExpr 131 } { CXCursor_CXXThisExpr 132 } { CXCursor_CXXThrowExpr 133 } { CXCursor_CXXNewExpr 134 }
{ CXCursor_CXXDeleteExpr 135 } { CXCursor_UnaryExpr 136 } { CXCursor_ObjCStringLiteral 137 } { CXCursor_ObjCEncodeExpr 138 }
{ CXCursor_ObjCSelectorExpr 139 } { CXCursor_ObjCProtocolExpr 140 } { CXCursor_ObjCBridgedCastExpr 141 } { CXCursor_PackExpansionExpr 142 }
{ CXCursor_SizeOfPackExpr 143 } { CXCursor_LambdaExpr 144 } { CXCursor_ObjCBoolLiteralExpr 145 } { CXCursor_ObjCSelfExpr 146 }
{ CXCursor_OMPArraySectionExpr 147 } { CXCursor_ObjCAvailabilityCheckExpr 148 } { CXCursor_FixedPointLiteral 149 } { CXCursor_OMPArrayShapingExpr 150 }
{ CXCursor_OMPIteratorExpr 151 } { CXCursor_CXXAddrspaceCastExpr 152 } { CXCursor_LastExpr CXCursor_CXXAddrspaceCastExpr } { CXCursor_FirstStmt 200 }
{ CXCursor_UnexposedStmt 200 } { CXCursor_LabelStmt 201 } { CXCursor_CompoundStmt 202 } { CXCursor_CaseStmt 203 }
{ CXCursor_DefaultStmt 204 } { CXCursor_IfStmt 205 } { CXCursor_SwitchStmt 206 } { CXCursor_WhileStmt 207 }
{ CXCursor_DoStmt 208 } { CXCursor_ForStmt 209 } { CXCursor_GotoStmt 210 } { CXCursor_IndirectGotoStmt 211 }
{ CXCursor_ContinueStmt 212 } { CXCursor_BreakStmt 213 } { CXCursor_ReturnStmt 214 } { CXCursor_GCCAsmStmt 215 }
{ CXCursor_AsmStmt CXCursor_GCCAsmStmt } { CXCursor_ObjCAtTryStmt 216 } { CXCursor_ObjCAtCatchStmt 217 } { CXCursor_ObjCAtFinallyStmt 218 }
{ CXCursor_ObjCAtThrowStmt 219 } { CXCursor_ObjCAtSynchronizedStmt 220 } { CXCursor_ObjCAutoreleasePoolStmt 221 } { CXCursor_ObjCForCollectionStmt 222 }
{ CXCursor_CXXCatchStmt 223 } { CXCursor_CXXTryStmt 224 } { CXCursor_CXXForRangeStmt 225 } { CXCursor_SEHTryStmt 226 }
{ CXCursor_SEHExceptStmt 227 } { CXCursor_SEHFinallyStmt 228 } { CXCursor_MSAsmStmt 229 } { CXCursor_NullStmt 230 }
{ CXCursor_DeclStmt 231 } { CXCursor_OMPParallelDirective 232 } { CXCursor_OMPSimdDirective 233 } { CXCursor_OMPForDirective 234 }
{ CXCursor_OMPSectionsDirective 235 } { CXCursor_OMPSectionDirective 236 } { CXCursor_OMPSingleDirective 237 } { CXCursor_OMPParallelForDirective 238 }
{ CXCursor_OMPParallelSectionsDirective 239 } { CXCursor_OMPTaskDirective 240 } { CXCursor_OMPMasterDirective 241 } { CXCursor_OMPCriticalDirective 242 }
{ CXCursor_OMPTaskyieldDirective 243 } { CXCursor_OMPBarrierDirective 244 } { CXCursor_OMPTaskwaitDirective 245 } { CXCursor_OMPFlushDirective 246 }
{ CXCursor_SEHLeaveStmt 247 } { CXCursor_OMPOrderedDirective 248 } { CXCursor_OMPAtomicDirective 249 } { CXCursor_OMPForSimdDirective 250 }
{ CXCursor_OMPParallelForSimdDirective 251 } { CXCursor_OMPTargetDirective 252 } { CXCursor_OMPTeamsDirective 253 } { CXCursor_OMPTaskgroupDirective 254 }
{ CXCursor_OMPCancellationPointDirective 255 } { CXCursor_OMPCancelDirective 256 } { CXCursor_OMPTargetDataDirective 257 } { CXCursor_OMPTaskLoopDirective 258 }
{ CXCursor_OMPTaskLoopSimdDirective 259 } { CXCursor_OMPDistributeDirective 260 } { CXCursor_OMPTargetEnterDataDirective 261 } { CXCursor_OMPTargetExitDataDirective 262 }
{ CXCursor_OMPTargetParallelDirective 263 } { CXCursor_OMPTargetParallelForDirective 264 } { CXCursor_OMPTargetUpdateDirective 265 } { CXCursor_OMPDistributeParallelForDirective 266 }
{ CXCursor_OMPDistributeParallelForSimdDirective 267 } { CXCursor_OMPDistributeSimdDirective 268 } { CXCursor_OMPTargetParallelForSimdDirective 269 } { CXCursor_OMPTargetSimdDirective 270 }
{ CXCursor_OMPTeamsDistributeDirective 271 } { CXCursor_OMPTeamsDistributeSimdDirective 272 } { CXCursor_OMPTeamsDistributeParallelForSimdDirective 273 } { CXCursor_OMPTeamsDistributeParallelForDirective 274 }
{ CXCursor_OMPTargetTeamsDirective 275 } { CXCursor_OMPTargetTeamsDistributeDirective 276 } { CXCursor_OMPTargetTeamsDistributeParallelForDirective 277 } { CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective 278 }
{ CXCursor_OMPTargetTeamsDistributeSimdDirective 279 } { CXCursor_BuiltinBitCastExpr 280 } { CXCursor_OMPMasterTaskLoopDirective 281 } { CXCursor_OMPParallelMasterTaskLoopDirective 282 }
{ CXCursor_OMPMasterTaskLoopSimdDirective 283 } { CXCursor_OMPParallelMasterTaskLoopSimdDirective 284 } { CXCursor_OMPParallelMasterDirective 285 } { CXCursor_OMPDepobjDirective 286 }
{ CXCursor_OMPScanDirective 287 } { CXCursor_OMPTileDirective 288 } { CXCursor_OMPCanonicalLoop 289 } { CXCursor_OMPInteropDirective 290 }
{ CXCursor_OMPDispatchDirective 291 } { CXCursor_OMPMaskedDirective 292 } { CXCursor_OMPUnrollDirective 293 } { CXCursor_OMPMetaDirective 294 }
{ CXCursor_OMPGenericLoopDirective 295 } { CXCursor_LastStmt CXCursor_OMPGenericLoopDirective } { CXCursor_TranslationUnit 300 } { CXCursor_FirstAttr 400 }
{ CXCursor_UnexposedAttr 400 } { CXCursor_IBActionAttr 401 } { CXCursor_IBOutletAttr 402 } { CXCursor_IBOutletCollectionAttr 403 }
{ CXCursor_CXXFinalAttr 404 } { CXCursor_CXXOverrideAttr 405 } { CXCursor_AnnotateAttr 406 } { CXCursor_AsmLabelAttr 407 }
{ CXCursor_PackedAttr 408 } { CXCursor_PureAttr 409 } { CXCursor_ConstAttr 410 } { CXCursor_NoDuplicateAttr 411 }
{ CXCursor_CUDAConstantAttr 412 } { CXCursor_CUDADeviceAttr 413 } { CXCursor_CUDAGlobalAttr 414 } { CXCursor_CUDAHostAttr 415 }
{ CXCursor_CUDASharedAttr 416 } { CXCursor_VisibilityAttr 417 } { CXCursor_DLLExport 418 } { CXCursor_DLLImport 419 }
{ CXCursor_NSReturnsRetained 420 } { CXCursor_NSReturnsNotRetained 421 } { CXCursor_NSReturnsAutoreleased 422 } { CXCursor_NSConsumesSelf 423 }
{ CXCursor_NSConsumed 424 } { CXCursor_ObjCException 425 } { CXCursor_ObjCNSObject 426 } { CXCursor_ObjCIndependentClass 427 }
{ CXCursor_ObjCPreciseLifetime 428 } { CXCursor_ObjCReturnsInnerPointer 429 } { CXCursor_ObjCRequiresSuper 430 } { CXCursor_ObjCRootClass 431 }
{ CXCursor_ObjCSubclassingRestricted 432 } { CXCursor_ObjCExplicitProtocolImpl 433 } { CXCursor_ObjCDesignatedInitializer 434 } { CXCursor_ObjCRuntimeVisible 435 }
{ CXCursor_ObjCBoxable 436 } { CXCursor_FlagEnum 437 } { CXCursor_ConvergentAttr 438 } { CXCursor_WarnUnusedAttr 439 }
{ CXCursor_WarnUnusedResultAttr 440 } { CXCursor_AlignedAttr 441 } { CXCursor_LastAttr CXCursor_AlignedAttr } { CXCursor_PreprocessingDirective 500 }
{ CXCursor_MacroDefinition 501 } { CXCursor_MacroExpansion 502 } { CXCursor_MacroInstantiation CXCursor_MacroExpansion } { CXCursor_InclusionDirective 503 }
{ CXCursor_FirstPreprocessing CXCursor_PreprocessingDirective } { CXCursor_LastPreprocessing CXCursor_InclusionDirective } { CXCursor_ModuleImportDecl 600 } { CXCursor_TypeAliasTemplateDecl 601 }
{ CXCursor_StaticAssert 602 } { CXCursor_FriendDecl 603 } { CXCursor_FirstExtraDecl CXCursor_ModuleImportDecl } { CXCursor_LastExtraDecl CXCursor_FriendDecl }
{ CXCursor_OverloadCandidate 700 } ;

ENUM: CXCursor_ExceptionSpecificationKind
{ CXCursor_ExceptionSpecificationKind_None 0 }
{ CXCursor_ExceptionSpecificationKind_DynamicNone 1 }
{ CXCursor_ExceptionSpecificationKind_Dynamic 2 }
{ CXCursor_ExceptionSpecificationKind_MSAny 3 }
{ CXCursor_ExceptionSpecificationKind_BasicNoexcept 4 }
{ CXCursor_ExceptionSpecificationKind_ComputedNoexcept 5 }
{ CXCursor_ExceptionSpecificationKind_Unevaluated 6 }
{ CXCursor_ExceptionSpecificationKind_Uninstantiated 7 }
{ CXCursor_ExceptionSpecificationKind_Unparsed 8 }
{ CXCursor_ExceptionSpecificationKind_NoThrow 9 } ;

ENUM: CXDiagnosticSeverity
{ CXDiagnostic_Ignored 0 }
{ CXDiagnostic_Note 1 }
{ CXDiagnostic_Warning 2 }
{ CXDiagnostic_Error 3 }
{ CXDiagnostic_Fatal 4 } ;

ENUM: CXErrorCode
{ CXError_Success 0 }
{ CXError_Failure 1 }
{ CXError_Crashed 2 }
{ CXError_InvalidArguments 3 }
{ CXError_ASTReadError 4 } ;

ENUM: CXEvalResultKind
{ CXEval_UnExposed 0 }
{ CXEval_Int 1 }
{ CXEval_Float 2 }
{ CXEval_ObjCStrLiteral 3 }
{ CXEval_StrLiteral 4 }
{ CXEval_CFStr 5 }
{ CXEval_Other 6 } ;

ENUM: CXIdxAttrKind
{ CXIdxAttr_Unexposed 0 }
{ CXIdxAttr_IBAction 1 }
{ CXIdxAttr_IBOutlet 2 }
{ CXIdxAttr_IBOutletCollection 3 } ;

ENUM: CXIdxEntityCXXTemplateKind
{ CXIdxEntity_NonTemplate 0 }
{ CXIdxEntity_Template 1 }
{ CXIdxEntity_TemplatePartialSpecialization 2 }
{ CXIdxEntity_TemplateSpecialization 3 } ;

ENUM: CXIdxEntityKind
{ CXIdxEntity_Unexposed 0 } { CXIdxEntity_Typedef 1 } { CXIdxEntity_Function 2 }
{ CXIdxEntity_Variable 3 } { CXIdxEntity_Field 4 } { CXIdxEntity_EnumConstant 5 }
{ CXIdxEntity_ObjCClass 6 } { CXIdxEntity_ObjCProtocol 7 } { CXIdxEntity_ObjCCategory 8 }
{ CXIdxEntity_ObjCInstanceMethod 9 } { CXIdxEntity_ObjCClassMethod 10 } { CXIdxEntity_ObjCProperty 11 }
{ CXIdxEntity_ObjCIvar 12 } { CXIdxEntity_Enum 13 } { CXIdxEntity_Struct 14 }
{ CXIdxEntity_Union 15 } { CXIdxEntity_CXXClass 16 } { CXIdxEntity_CXXNamespace 17 }
{ CXIdxEntity_CXXNamespaceAlias 18 } { CXIdxEntity_CXXStaticVariable 19 } { CXIdxEntity_CXXStaticMethod 20 }
{ CXIdxEntity_CXXInstanceMethod 21 } { CXIdxEntity_CXXConstructor 22 } { CXIdxEntity_CXXDestructor 23 }
{ CXIdxEntity_CXXConversionFunction 24 } { CXIdxEntity_CXXTypeAlias 25 } { CXIdxEntity_CXXInterface 26 }
{ CXIdxEntity_CXXConcept 27 } ;

ENUM: CXIdxEntityLanguage
{ CXIdxEntityLang_None 0 }
{ CXIdxEntityLang_C 1 }
{ CXIdxEntityLang_ObjC 2 }
{ CXIdxEntityLang_CXX 3 }
{ CXIdxEntityLang_Swift 4 } ;

ENUM: CXIdxEntityRefKind
{ CXIdxEntityRef_Direct 1 }
{ CXIdxEntityRef_Implicit 2 } ;

ENUM: CXIdxObjCContainerKind
{ CXIdxObjCContainer_ForwardRef 0 }
{ CXIdxObjCContainer_Interface 1 }
{ CXIdxObjCContainer_Implementation 2 } ;

ENUM: CXLanguageKind
{ CXLanguage_Invalid 0 }
{ CXLanguage_C 1 }
{ CXLanguage_ObjC 2 }
{ CXLanguage_CPlusPlus 3 } ;

ENUM: CXLinkageKind
{ CXLinkage_Invalid 0 }
{ CXLinkage_NoLinkage 1 }
{ CXLinkage_Internal 2 }
{ CXLinkage_UniqueExternal 3 }
{ CXLinkage_External 4 } ;

ENUM: CXLoadDiag_Error
{ CXLoadDiag_None 0 }
{ CXLoadDiag_Unknown 1 }
{ CXLoadDiag_CannotLoad 2 }
{ CXLoadDiag_InvalidFile 3 } ;

ENUM: CXPrintingPolicyProperty
{ CXPrintingPolicy_Indentation 0 }
{ CXPrintingPolicy_SuppressSpecifiers 1 }
{ CXPrintingPolicy_SuppressTagKeyword 2 }
{ CXPrintingPolicy_IncludeTagDefinition 3 }
{ CXPrintingPolicy_SuppressScope 4 }
{ CXPrintingPolicy_SuppressUnwrittenScope 5 }
{ CXPrintingPolicy_SuppressInitializers 6 }
{ CXPrintingPolicy_ConstantArraySizeAsWritten 7 }
{ CXPrintingPolicy_AnonymousTagLocations 8 }
{ CXPrintingPolicy_SuppressStrongLifetime 9 }
{ CXPrintingPolicy_SuppressLifetimeQualifiers 10 }
{ CXPrintingPolicy_SuppressTemplateArgsInCXXConstructors 11 }
{ CXPrintingPolicy_Bool 12 }
{ CXPrintingPolicy_Restrict 13 }
{ CXPrintingPolicy_Alignof 14 }
{ CXPrintingPolicy_UnderscoreAlignof 15 }
{ CXPrintingPolicy_UseVoidForZeroParams 16 }
{ CXPrintingPolicy_TerseOutput 17 }
{ CXPrintingPolicy_PolishForDeclaration 18 }
{ CXPrintingPolicy_Half 19 }
{ CXPrintingPolicy_MSWChar 20 }
{ CXPrintingPolicy_IncludeNewlines 21 }
{ CXPrintingPolicy_MSVCFormatting 22 }
{ CXPrintingPolicy_ConstantsAsWritten 23 }
{ CXPrintingPolicy_SuppressImplicitBase 24 }
{ CXPrintingPolicy_FullyQualifiedName 25 } ;

ENUM: CXRefQualifierKind
{ CXRefQualifier_None 0 }
{ CXRefQualifier_LValue 1 }
{ CXRefQualifier_RValue 2 } ;

ENUM: CXResult
{ CXResult_Success 0 }
{ CXResult_Invalid 1 }
{ CXResult_VisitBreak 2 } ;

ENUM: CXSaveError
{ CXSaveError_None 0 }
{ CXSaveError_Unknown 1 }
{ CXSaveError_TranslationErrors 2 }
{ CXSaveError_InvalidTU 3 } ;

ENUM: CXTLSKind
{ CXTLS_None 0 }
{ CXTLS_Dynamic 1 }
{ CXTLS_Static 2 } ;

ENUM: CXTUResourceUsageKind
{ CXTUResourceUsage_AST 1 }
{ CXTUResourceUsage_Identifiers 2 }
{ CXTUResourceUsage_Selectors 3 }
{ CXTUResourceUsage_GlobalCompletionResults 4 }
{ CXTUResourceUsage_SourceManagerContentCache 5 }
{ CXTUResourceUsage_AST_SideTables 6 }
{ CXTUResourceUsage_SourceManager_Membuffer_Malloc 7 }
{ CXTUResourceUsage_SourceManager_Membuffer_MMap 8 }
{ CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc 9 }
{ CXTUResourceUsage_ExternalASTSource_Membuffer_MMap 10 }
{ CXTUResourceUsage_Preprocessor 11 }
{ CXTUResourceUsage_PreprocessingRecord 12 }
{ CXTUResourceUsage_SourceManager_DataStructures 13 }
{ CXTUResourceUsage_Preprocessor_HeaderSearch 14 } ;

ENUM: CXTemplateArgumentKind
{ CXTemplateArgumentKind_Null 0 }
{ CXTemplateArgumentKind_Type 1 }
{ CXTemplateArgumentKind_Declaration 2 }
{ CXTemplateArgumentKind_NullPtr 3 }
{ CXTemplateArgumentKind_Integral 4 }
{ CXTemplateArgumentKind_Template 5 }
{ CXTemplateArgumentKind_TemplateExpansion 6 }
{ CXTemplateArgumentKind_Expression 7 }
{ CXTemplateArgumentKind_Pack 8 }
{ CXTemplateArgumentKind_Invalid 9 } ;

ENUM: CXTokenKind
{ CXToken_Punctuation 0 }
{ CXToken_Keyword 1 }
{ CXToken_Identifier 2 }
{ CXToken_Literal 3 }
{ CXToken_Comment 4 } ;

ENUM: CXTypeKind { CXType_Invalid 0 } { CXType_Unexposed 1 } { CXType_Void 2 } { CXType_Bool 3 }
{ CXType_Char_U 4 } { CXType_UChar 5 } { CXType_Char16 6 } { CXType_Char32 7 }
{ CXType_UShort 8 } { CXType_UInt 9 } { CXType_ULong 10 } { CXType_ULongLong 11 }
{ CXType_UInt128 12 } { CXType_Char_S 13 } { CXType_SChar 14 } { CXType_WChar 15 }
{ CXType_Short 16 } { CXType_Int 17 } { CXType_Long 18 } { CXType_LongLong 19 }
{ CXType_Int128 20 } { CXType_Float 21 } { CXType_Double 22 } { CXType_LongDouble 23 }
{ CXType_NullPtr 24 } { CXType_Overload 25 } { CXType_Dependent 26 } { CXType_ObjCId 27 }
{ CXType_ObjCClass 28 } { CXType_ObjCSel 29 } { CXType_Float128 30 } { CXType_Half 31 }
{ CXType_Float16 32 } { CXType_ShortAccum 33 } { CXType_Accum 34 } { CXType_LongAccum 35 }
{ CXType_UShortAccum 36 } { CXType_UAccum 37 } { CXType_ULongAccum 38 } { CXType_BFloat16 39 }
{ CXType_Ibm128 40 } { CXType_FirstBuiltin CXType_Void } { CXType_LastBuiltin CXType_Ibm128 } { CXType_Complex 100 }
{ CXType_Pointer 101 } { CXType_BlockPointer 102 } { CXType_LValueReference 103 } { CXType_RValueReference 104 }
{ CXType_Record 105 } { CXType_Enum 106 } { CXType_Typedef 107 } { CXType_ObjCInterface 108 }
{ CXType_ObjCObjectPointer 109 } { CXType_FunctionNoProto 110 } { CXType_FunctionProto 111 } { CXType_ConstantArray 112 }
{ CXType_Vector 113 } { CXType_IncompleteArray 114 } { CXType_VariableArray 115 } { CXType_DependentSizedArray 116 }
{ CXType_MemberPointer 117 } { CXType_Auto 118 } { CXType_Elaborated 119 } { CXType_Pipe 120 }
{ CXType_OCLImage1dRO 121 } { CXType_OCLImage1dArrayRO 122 } { CXType_OCLImage1dBufferRO 123 } { CXType_OCLImage2dRO 124 }
{ CXType_OCLImage2dArrayRO 125 } { CXType_OCLImage2dDepthRO 126 } { CXType_OCLImage2dArrayDepthRO 127 } { CXType_OCLImage2dMSAARO 128 }
{ CXType_OCLImage2dArrayMSAARO 129 } { CXType_OCLImage2dMSAADepthRO 130 } { CXType_OCLImage2dArrayMSAADepthRO 131 } { CXType_OCLImage3dRO 132 }
{ CXType_OCLImage1dWO 133 } { CXType_OCLImage1dArrayWO 134 } { CXType_OCLImage1dBufferWO 135 } { CXType_OCLImage2dWO 136 }
{ CXType_OCLImage2dArrayWO 137 } { CXType_OCLImage2dDepthWO 138 } { CXType_OCLImage2dArrayDepthWO 139 } { CXType_OCLImage2dMSAAWO 140 }
{ CXType_OCLImage2dArrayMSAAWO 141 } { CXType_OCLImage2dMSAADepthWO 142 } { CXType_OCLImage2dArrayMSAADepthWO 143 } { CXType_OCLImage3dWO 144 }
{ CXType_OCLImage1dRW 145 } { CXType_OCLImage1dArrayRW 146 } { CXType_OCLImage1dBufferRW 147 } { CXType_OCLImage2dRW 148 }
{ CXType_OCLImage2dArrayRW 149 } { CXType_OCLImage2dDepthRW 150 } { CXType_OCLImage2dArrayDepthRW 151 } { CXType_OCLImage2dMSAARW 152 }
{ CXType_OCLImage2dArrayMSAARW 153 } { CXType_OCLImage2dMSAADepthRW 154 } { CXType_OCLImage2dArrayMSAADepthRW 155 } { CXType_OCLImage3dRW 156 }
{ CXType_OCLSampler 157 } { CXType_OCLEvent 158 } { CXType_OCLQueue 159 } { CXType_OCLReserveID 160 }
{ CXType_ObjCObject 161 } { CXType_ObjCTypeParam 162 } { CXType_Attributed 163 } { CXType_OCLIntelSubgroupAVCMcePayload 164 }
{ CXType_OCLIntelSubgroupAVCImePayload 165 } { CXType_OCLIntelSubgroupAVCRefPayload 166 } { CXType_OCLIntelSubgroupAVCSicPayload 167 }
{ CXType_OCLIntelSubgroupAVCMceResult 168 } { CXType_OCLIntelSubgroupAVCImeResult 169 } { CXType_OCLIntelSubgroupAVCRefResult 170 }
{ CXType_OCLIntelSubgroupAVCSicResult 171 } { CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout 172 }
{ CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout 173 } { CXType_OCLIntelSubgroupAVCImeSingleRefStreamin 174 }
{ CXType_OCLIntelSubgroupAVCImeDualRefStreamin 175 } { CXType_ExtVector 176 } { CXType_Atomic 177 }
{ CXType_BTFTagAttributed 178 } ;

ENUM: CXTypeLayoutError
{ CXTypeLayoutError_Invalid -1 }
{ CXTypeLayoutError_Incomplete -2 }
{ CXTypeLayoutError_Dependent -3 }
{ CXTypeLayoutError_NotConstantSize -4 }
{ CXTypeLayoutError_InvalidFieldName -5 }
{ CXTypeLayoutError_Undeduced -6 } ;

ENUM: CXVisibilityKind
{ CXVisibility_Invalid 0 }
{ CXVisibility_Hidden 1 }
{ CXVisibility_Protected 2 }
{ CXVisibility_Default 3 } ;

ENUM: CXTypeNullabilityKind
{ CXTypeNullability_NonNull 0 }
{ CXTypeNullability_Nullable 1 }
{ CXTypeNullability_Unspecified 2 }
{ CXTypeNullability_Invalid 3 }
{ CXTypeNullability_NullableResult 4 } ;

ENUM: CXUnaryOperatorKind
{ CXUnaryOperator_Invalid 0 }
{ CXUnaryOperator_PostInc 1 }
{ CXUnaryOperator_PostDec 2 }
{ CXUnaryOperator_PreInc 3 }
{ CXUnaryOperator_PreDec 4 }
{ CXUnaryOperator_AddrOf 5 }
{ CXUnaryOperator_Deref 6 }
{ CXUnaryOperator_Plus 7 }
{ CXUnaryOperator_Minus 8 }
{ CXUnaryOperator_Not 9 }
{ CXUnaryOperator_LNot 10 }
{ CXUnaryOperator_Real 11 }
{ CXUnaryOperator_Imag 12 }
{ CXUnaryOperator_Extension 13 }
{ CXUnaryOperator_Coawait 14 } ;

ENUM: CXVisitorResult
{ CXVisit_Break 0 }
{ CXVisit_Continue 1 } ;

ENUM: CX_CXXAccessSpecifier
{ CX_CXXInvalidAccessSpecifier 0 }
{ CX_CXXPublic 1 }
{ CX_CXXProtected 2 }
{ CX_CXXPrivate 3 } ;

ENUM: CX_StorageClass
{ CX_SC_Invalid 0 }
{ CX_SC_None 1 }
{ CX_SC_Extern 2 }
{ CX_SC_Static 3 }
{ CX_SC_PrivateExtern 4 }
{ CX_SC_OpenCLWorkGroupLocal 5 }
{ CX_SC_Auto 6 }
{ CX_SC_Register 7 } ;

ENUM: CXCodeComplete_Flags
{ CXCodeComplete_IncludeMacros 1 }
{ CXCodeComplete_IncludeCodePatterns 2 }
{ CXCodeComplete_IncludeBriefComments 4 }
{ CXCodeComplete_SkipPreamble 8 }
{ CXCodeComplete_IncludeCompletionsWithFixIts 16 } ;

ENUM: CXCompletionContext
{ CXCompletionContext_Unexposed 0 }
{ CXCompletionContext_AnyType 1 }
{ CXCompletionContext_AnyValue 2 }
{ CXCompletionContext_ObjCObjectValue 4 }
{ CXCompletionContext_ObjCSelectorValue 8 }
{ CXCompletionContext_CXXClassTypeValue 16 }
{ CXCompletionContext_DotMemberAccess 32 }
{ CXCompletionContext_ArrowMemberAccess 64 }
{ CXCompletionContext_ObjCPropertyAccess 128 }
{ CXCompletionContext_EnumTag 256 }
{ CXCompletionContext_UnionTag 512 }
{ CXCompletionContext_StructTag 1024 }
{ CXCompletionContext_ClassTag 2048 }
{ CXCompletionContext_Namespace 4096 }
{ CXCompletionContext_NestedNameSpecifier 8192 }
{ CXCompletionContext_ObjCInterface 16384 }
{ CXCompletionContext_ObjCProtocol 32768 }
{ CXCompletionContext_ObjCCategory 65536 }
{ CXCompletionContext_ObjCInstanceMessage 131072 }
{ CXCompletionContext_ObjCClassMessage 262144 }
{ CXCompletionContext_ObjCSelectorName 524288 }
{ CXCompletionContext_MacroName 1048576 }
{ CXCompletionContext_NaturalLanguage 2097152 }
{ CXCompletionContext_IncludedFile 4194304 }
{ CXCompletionContext_Unknown 8388607 } ;

ENUM: CXDiagnosticDisplayOptions
{ CXDiagnostic_DisplaySourceLocation 1 }
{ CXDiagnostic_DisplayColumn 2 }
{ CXDiagnostic_DisplaySourceRanges 4 }
{ CXDiagnostic_DisplayOption 8 }
{ CXDiagnostic_DisplayCategoryId 16 }
{ CXDiagnostic_DisplayCategoryName 32 } ;

ENUM: CXGlobalOptFlags
{ CXGlobalOpt_None 0 }
{ CXGlobalOpt_ThreadBackgroundPriorityForIndexing 1 }
{ CXGlobalOpt_ThreadBackgroundPriorityForEditing 2 }
{ CXGlobalOpt_ThreadBackgroundPriorityForAll 3 } ;

ENUM: CXIdxDeclInfoFlags
{ CXIdxDeclFlag_Skipped 1 } ;

ENUM: CXIndexOptFlags
{ CXIndexOptNone 0 }
{ CXIndexOptSuppressRedundantRefs 1 }
{ CXIndexOptIndexFunctionLocalSymbols 2 }
{ CXIndexOptIndexImplicitTemplateInstantiations 4 }
{ CXIndexOptSuppressWarnings 8 }
{ CXIndexOptSkipParsedBodiesInSession 16 } ;

ENUM: CXNameRefFlags
{ CXNameRange_WantQualifier 1 }
{ CXNameRange_WantTemplateArgs 2 }
{ CXNameRange_WantSinglePiece 4 } ;

ENUM: CXObjCDeclQualifierKind
{ CXObjCDeclQualifier_None 0 }
{ CXObjCDeclQualifier_In 1 }
{ CXObjCDeclQualifier_Inout 2 }
{ CXObjCDeclQualifier_Out 4 }
{ CXObjCDeclQualifier_Bycopy 8 }
{ CXObjCDeclQualifier_Byref 16 }
{ CXObjCDeclQualifier_Oneway 32 } ;

ENUM: CXObjCPropertyAttrKind
{ CXObjCPropertyAttr_noattr 0 }
{ CXObjCPropertyAttr_readonly 1 }
{ CXObjCPropertyAttr_getter 2 }
{ CXObjCPropertyAttr_assign 4 }
{ CXObjCPropertyAttr_readwrite 8 }
{ CXObjCPropertyAttr_retain 16 }
{ CXObjCPropertyAttr_copy 32 }
{ CXObjCPropertyAttr_nonatomic 64 }
{ CXObjCPropertyAttr_setter 128 }
{ CXObjCPropertyAttr_atomic 256 }
{ CXObjCPropertyAttr_weak 512 }
{ CXObjCPropertyAttr_strong 1024 }
{ CXObjCPropertyAttr_unsafe_unretained 2048 }
{ CXObjCPropertyAttr_class 4096 } ;

ENUM: CXReparse_Flags
{ CXReparse_None 0 } ;

ENUM: CXSaveTranslationUnit_Flags
{ CXSaveTranslationUnit_None 0 } ;

ENUM: CXSymbolRole
{ CXSymbolRole_None 0 }
{ CXSymbolRole_Declaration 1 }
{ CXSymbolRole_Definition 2 }
{ CXSymbolRole_Reference 4 }
{ CXSymbolRole_Read 8 }
{ CXSymbolRole_Write 16 }
{ CXSymbolRole_Call 32 }
{ CXSymbolRole_Dynamic 64 }
{ CXSymbolRole_AddressOf 128 }
{ CXSymbolRole_Implicit 256 } ;

ENUM: CXTranslationUnit_Flags
{ CXTranslationUnit_None 0 }
{ CXTranslationUnit_DetailedPreprocessingRecord 1 }
{ CXTranslationUnit_Incomplete 2 }
{ CXTranslationUnit_PrecompiledPreamble 4 }
{ CXTranslationUnit_CacheCompletionResults 8 }
{ CXTranslationUnit_ForSerialization 16 }
{ CXTranslationUnit_CXXChainedPCH 32 }
{ CXTranslationUnit_SkipFunctionBodies 64 }
{ CXTranslationUnit_IncludeBriefCommentsInCodeCompletion 128 }
{ CXTranslationUnit_CreatePreambleOnFirstParse 256 }
{ CXTranslationUnit_KeepGoing 512 }
{ CXTranslationUnit_SingleFileParse 1024 }
{ CXTranslationUnit_LimitSkipFunctionBodiesToPreamble 2048 }
{ CXTranslationUnit_IncludeAttributedTypes 4096 }
{ CXTranslationUnit_VisitImplicitAttributes 8192 }
{ CXTranslationUnit_IgnoreNonErrorsFromIncludedFiles 16384 }
{ CXTranslationUnit_RetainExcludedConditionalBlocks 32768 } ;

STRUCT: CXCompletionResult
{ CursorKind CXCursorKind }
{ CompletionString CXCompletionString } ;

STRUCT: CXCodeCompleteResults
{ Results CXCompletionResult* }
{ NumResults uint } ;

STRUCT: CXComment
{ ASTNode void* }
{ TranslationUnit CXTranslationUnit } ;

STRUCT: CXCursor
{ kind CXCursorKind }
{ xdata int }
{ data void*[3] } ;

STRUCT: CXCursorAndRangeVisitor
{ context void* }
{ visit void* } ;

STRUCT: CXFileUniqueID
{ data ulonglong[3] } ;

STRUCT: CXIdxLoc
{ ptr_data void*[2] }
{ int_data uint } ;

STRUCT: CXIdxAttrInfo
{ kind CXIdxAttrKind }
{ cursor CXCursor }
{ loc CXIdxLoc } ;

STRUCT: CXType
    { kind CXTypeKind }
    { data void*[2] } ;

STRUCT: CXString
    { data c-string }
    { private_flags uint } ;

STRUCT: CXStringSet
    { Strings CXString* }
    { Count uint } ;

STRUCT: CXSourceLocation
    { ptr_data void*[2]  }
    { data uint } ;

STRUCT: CXSourceRange
    { ptr_data void*[2]  }
    { begin_int_data uint }
    { end_int_data uint } ;

STRUCT: CXSourceRangeList
    { count uint }
    { ranges CXSourceRange* } ;

! STRUCT: CXDiagnostic
!     { data void*[3] } ;

STRUCT: CXUnsavedFile
{ Filename char* }
{ Contents char* }
{ Length ulong } ;


FUNCTION: CXIndex clang_createIndex ( int excludeDeclarationsFromPCH, int displayDiagnostics )

FUNCTION: CXTranslationUnit clang_parseTranslationUnit (
    CXIndex CIdx, c-string source_filename,
    char** command_line_args, int num_command_line_args,
    CXUnsavedFile *unsaved_files, uint num_unsaved_files,
    uint options )

FUNCTION: void clang_disposeIndex ( CXIndex index )
FUNCTION: void clang_disposeTranslationUnit ( CXTranslationUnit c )

FUNCTION: CXCursor clang_getTranslationUnitCursor ( CXTranslationUnit c )

FUNCTION: CXCursorKind clang_getCursorKind ( CXCursor c )

CALLBACK: CXChildVisitResult CXCursorVisitor ( CXCursor cursor, CXCursor parent, CXClientData client_data )

FUNCTION: CXString clang_getCursorKindSpelling ( CXCursorKind Kind )
FUNCTION: void clang_getDefinitionSpellingAndExtent (
    CXCursor cursor, char **startBuf, char **endBuf, uint *startLine,
    uint *startColumn, uint *endLine, uint *endColumn
)
FUNCTION: void clang_enableStackTraces ( )
FUNCTION: void clang_executeOnThread ( void* fn, void *user_data, uint stack_size )


FUNCTION: CXString clang_getCursorSpelling ( CXCursor C )

FUNCTION: CXType clang_getCursorType ( CXCursor C )
FUNCTION: CXType clang_getCanonicalType ( CXType T )
FUNCTION: CXType clang_getPointeeType ( CXType T )
FUNCTION: CXType clang_getResultType ( CXType T )
FUNCTION: CXType clang_getCursorResultType ( CXCursor C )
FUNCTION: CXType clang_getCursorReceiverType ( CXCursor C )
FUNCTION: CXType clang_getTypedefDeclUnderlyingType ( CXCursor C )
FUNCTION: CXType clang_getEnumDeclIntegerType ( CXCursor C )
FUNCTION: longlong clang_getEnumConstantDeclValue ( CXCursor C )
FUNCTION: ulonglong clang_getEnumConstantDeclUnsignedValue ( CXCursor C )
FUNCTION: CXType clang_getArrayElementType ( CXType T )
FUNCTION: uint clang_getArraySize ( CXType T )
FUNCTION: CXType clang_Type_getObjCObjectBaseType ( CXType T )
FUNCTION: CXType clang_getIBOutletCollectionType ( CXCursor C )
FUNCTION: CXType clang_getCursorReferenceQualifier ( CXCursor C )
FUNCTION: CXType clang_Cursor_getReceiverType ( CXCursor C )

FUNCTION: CXTypeKind clang_getTypeKind ( CXType CT )
FUNCTION: CXString clang_getTypeSpelling ( CXType CT )
FUNCTION: CXString clang_getTypeKindSpelling ( CXTypeKind K )

FUNCTION: int clang_Cursor_getNumArguments ( CXCursor C )
FUNCTION: CXType clang_getArgType ( CXType C, uint i )
FUNCTION: CXCursor clang_Cursor_getArgument ( CXCursor C, uint i )

FUNCTION: CXFile clang_getFile ( CXTranslationUnit tu, c-string file_name )
FUNCTION: CXString clang_getFileName ( CXFile SFile )
FUNCTION: uint clang_getFileTime ( CXFile SFile )
FUNCTION: CXSourceLocation clang_getLocation ( CXTranslationUnit tu, CXFile file, uint line, uint column )
FUNCTION: CXSourceLocation clang_getNullLocation ( )
FUNCTION: uint clang_equalLocations ( CXSourceLocation loc1, CXSourceLocation loc2 )
FUNCTION: CXSourceLocation clang_getLocationForOffset ( CXTranslationUnit tu, CXFile file, uint offset )
FUNCTION: int clang_Location_isInSystemHeader ( CXSourceLocation location )
FUNCTION: int clang_Location_isFromMainFile ( CXSourceLocation location )
FUNCTION: CXSourceRange clang_getNullRange ( )
FUNCTION: int clang_equalRanges ( CXSourceRange range1, CXSourceRange range2 )
FUNCTION: int clang_Range_isNull ( CXSourceRange range )
FUNCTION: void clang_getExpansionLocation (
    CXSourceLocation location, CXFile *file, uint *line,
    uint *column, uint *offset
)
FUNCTION: void clang_getPresumedLocation (
    CXSourceLocation location, CXString *filename, uint *line,
    uint *column
)
FUNCTION: void clang_getInstantiationLocation (
    CXSourceLocation location, CXFile *file, uint *line,
    uint *column, uint *offset
    )
FUNCTION: void clang_getSpellingLocation (
    CXSourceLocation location, CXFile *file, uint *line,
    uint *column, uint *offset
)
FUNCTION: void clang_getFileLocation (
    CXSourceLocation location, CXFile *file, uint *line,
    uint *column, uint *offset
)

FUNCTION: CXFile clang_getIncludedFile ( CXCursor cursor )
FUNCTION: CXSourceLocation clang_getCursorLocation ( CXCursor cursor )
FUNCTION: CXSourceRange clang_getCursorExtent ( CXCursor cursor )
FUNCTION: CXSourceLocation clang_getRangeStart ( CXSourceRange range )
FUNCTION: CXSourceLocation clang_getRangeEnd ( CXSourceRange range )
FUNCTION: CXSourceRangeList* clang_getSkippedRanges ( CXTranslationUnit tu, CXFile file )
FUNCTION: CXSourceRangeList* clang_getAllSkippedRanges ( CXTranslationUnit tu )
FUNCTION: void clang_disposeSourceRangeList ( CXSourceRangeList *ranges )
FUNCTION: CXDiagnosticSet clang_getDiagnosticSetFromTU ( CXTranslationUnit Unit )

FUNCTION: void clang_tokenize ( CXTranslationUnit tu, CXSourceRange range, CXToken **tokens, uint *numTokens )
FUNCTION: void clang_disposeTokens ( CXTranslationUnit tu, CXToken *tokens, uint numTokens )
FUNCTION: void clang_annotateTokens ( CXTranslationUnit tu, CXToken *tokens, uint numTokens, CXCursor *cursors )
FUNCTION: CXToken* clang_getToken ( CXTranslationUnit tu, CXSourceLocation location )
FUNCTION: CXSourceRange clang_getTokenExtent ( CXTranslationUnit tu, CXToken token )
FUNCTION: CXTokenKind clang_getTokenKind ( CXToken token )
FUNCTION: CXString clang_getTokenSpelling ( CXTranslationUnit tu, CXToken token )
FUNCTION: CXSourceLocation clang_getTokenLocation ( CXTranslationUnit tu, CXToken token )
FUNCTION: CXString clang_getCursorDisplayName ( CXCursor C )
FUNCTION: CXString clang_getCursorUSR ( CXCursor C )
FUNCTION: CXString clang_constructUSR_ObjCClass ( char *class_name )
FUNCTION: CXString clang_constructUSR_ObjCCategory ( char *class_name, char *category_name )
FUNCTION: CXString clang_constructUSR_ObjCProtocol ( char *protocol_name )
FUNCTION: CXString clang_constructUSR_ObjCIvar ( char *name, CXString classUSR )
FUNCTION: CXString clang_constructUSR_ObjCMethod ( char *name, uint isInstanceMethod, CXString classUSR )
FUNCTION: CXString clang_constructUSR_ObjCProperty ( char *property, CXString classUSR )

FUNCTION: CXCursor clang_getTypeDeclaration ( CXType T )
FUNCTION: uint clang_getNumFields ( CXType T )
FUNCTION: CXCursor clang_getFieldDecl ( CXType T, uint i )
FUNCTION: uint clang_Cursor_getNumTemplateArguments ( CXCursor C )
FUNCTION: CXType clang_Cursor_getTemplateArgumentType ( CXCursor C, uint i )
FUNCTION: int clang_Cursor_getTemplateArgumentValue ( CXCursor C, uint i )
FUNCTION: CXCursor clang_Cursor_getTemplateArgumentCursor ( CXCursor C, uint i )
FUNCTION: uint clang_Cursor_getNumSpecializations ( CXCursor C )
FUNCTION: CXCursor clang_Cursor_getSpecialization ( CXCursor C, uint i )
FUNCTION: CXSourceRange clang_Cursor_getCommentRange ( CXCursor C )
FUNCTION: CXString clang_Cursor_getRawCommentText ( CXCursor C )
FUNCTION: CXString clang_Cursor_getBriefCommentText ( CXCursor C )
FUNCTION: CXString clang_Cursor_getMangling ( CXCursor C )
FUNCTION: CXString clang_Cursor_getCXXManglings ( CXCursor C )
FUNCTION: CXStringSet* clang_Cursor_getObjCManglings ( CXCursor C )
FUNCTION: CXString clang_Cursor_getObjCSelectorIndexName ( CXCursor C )
FUNCTION: CXString clang_Cursor_getObjCPropertyGetterName ( CXCursor C )
FUNCTION: CXString clang_Cursor_getObjCPropertySetterName ( CXCursor C )
FUNCTION: CXString clang_Cursor_getObjCDeclQualifiers ( CXCursor C )
FUNCTION: CXTranslationUnit clang_Cursor_getTranslationUnit ( CXCursor C )
FUNCTION: uint clang_Cursor_isObjCOptional ( CXCursor C )
FUNCTION: uint clang_Cursor_isVariadic ( CXCursor C )

FUNCTION: CXCursor clang_getCursorSemanticParent ( CXCursor cursor )
FUNCTION: CXCursor clang_getCursorLexicalParent ( CXCursor cursor )
FUNCTION: void clang_getOverriddenCursors ( CXCursor cursor, CXCursor **overridden, uint *num_overridden )
FUNCTION: void clang_disposeOverriddenCursors ( CXCursor *overridden )
FUNCTION: uint clang_getNumOverloadedDecls ( CXCursor cursor )
FUNCTION: void clang_getOverloadedDecl ( CXCursor cursor, uint index )

FUNCTION: CXString clang_getClangVersion ( )
FUNCTION: CXSourceRange clang_getRange ( CXSourceLocation begin, CXSourceLocation end )
FUNCTION: char* clang_getCString ( CXString string )
FUNCTION: void clang_disposeString ( CXString string )
FUNCTION: void clang_disposeStringSet ( CXStringSet *set )

FUNCTION: uint clang_visitChildren (
    CXCursor parent,
    CXCursorVisitor visitor,
    CXClientData client_data
)
