! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators kernel system ;
IN: libclang.ffi

LIBRARY: clang

<< "clang" {
    { [ os windows? ] [ "libclang.dll" ] }
    { [ os macosx? ] [ "/Library/Developer/CommandLineTools/usr/lib/libclang.dylib" ] }
    { [ os unix? ] [ "/usr/lib/llvm-10/lib/libclang.so" ] }
} cond cdecl add-library >>

CONSTANT: UINT_MAX 4294967295

TYPEDEF: void* CXTranslationUnitImpl
TYPEDEF: void* CXIndex
TYPEDEF: CXTranslationUnitImpl* CXTranslationUnit
TYPEDEF: void* CXClientData
TYPEDEF: void* CXFile

STRUCT: CXToken
{ int_data uint[4] }
{ ptr_data void* } ;

ENUM: CXTokenKind
{ CXToken_Punctuation 0 }
{ CXToken_Keyword 1 }
{ CXToken_Identifier 2 }
{ CXToken_Literal 3 }
{ CXToken_Comment 4 } ;

STRUCT: CXUnsavedFile
{ Filename char* }
{ Contents char* }
{ Length ulong } ;

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

ENUM: CXChildVisitResult
{ CXChildVisit_Break 0 }
{ CXChildVisit_Continue 1 }
{ CXChildVisit_Recurse 2 } ;

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
{ CXType_OCLIntelSubgroupAVCImePayloadSingleRefStreamout 178 } { CXType_OCLIntelSubgroupAVCImePayloadDualRefStreamout 179 } { CXType_OCLIntelSubgroupAVCImeInputPayload 180 }
{ CXType_OCLIntelSubgroupAVCImeInputPayloads 181 }
{ CXType_OCLIntelSubgroupAVCRefPayloads 182 }
{ CXType_OCLIntelSubgroupAVCSicPayloads 183 }
{ CXType_OCLIntelSubgroupAVCMceInputPayload 184 }
{ CXType_OCLIntelSubgroupAVCMceInputPayloads 185 }
{ CXType_OCLIntelSubgroupAVCMotionEstimationForwardIntegerINTEL 186 }
{ CXType_OCLIntelSubgroupAVCMotionEstimationBackwardIntegerINTEL 187 }
{ CXType_OCLIntelSubgroupAVCMotionEstimationBidirectionalIntegerINTEL 188 }
{ CXType_OCLIntelSubgroupAVCMotionEstimationForwardDualReferenceINTEL 189 }
{ CXType_OCLIntelSubgroupAVCMotionEstimationBackwardDualReferenceINTEL 190 }
{ CXType_OCLIntelSubgroupAVCMotionEstimationBidirectionalDualReferenceINTEL 191 }
{ CXType_OCLIntelSubgroupAVCMotionEstimationInterlacedINTEL 192 }
{ CXType_OCLIntelSubgroupAVCMotionEstimationInterlacedDualReferenceINTEL 193 }
{ CXType_OCLIntelSubgroupAVCEvaluateWithSingleReferenceINTEL 194 }
{ CXType_OCLIntelSubgroupAVCEvaluateWithDualReferenceINTEL 195 }
{ CXType_OCLIntelSubgroupAVCDualReferenceInterlacedINTEL 196 }
{ CXType_OCLIntelSubgroupAVCDualReferenceInterlacedWithSingleReferenceINTEL 197 }
{ CXType_OCLIntelSubgroupAVCDualReferenceInterlacedWithDualReferenceINTEL 198 }
{ CXType_OCLIntelSubgroupAVCEvaluateWithSingleReferenceStreaminINTEL 199 }
{ CXType_OCLIntelSubgroupAVCEvaluateWithDualReferenceStreaminINTEL 200 }
{ CXType_OCLIntelSubgroupAVCEvaluateWithSingleReferenceStreamoutINTEL 201 }
{ CXType_OCLIntelSubgroupAVCEvaluateWithDualReferenceStreamoutINTEL 202 } ;

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
{ CXTranslationUnit_VisitImplicitAttributes 8192 } ;

STRUCT: CXCursor
{ kind CXCursorKind }
{ xdata int }
{ data void*[3] } ;

STRUCT: CXType
    { kind CXTypeKind }
    { data void*[2] } ;

STRUCT: CXString
    { data c-string }
    { private_flags uint } ;

STRUCT: CXStringSet
    { Strings CXString* }
    { Count uint } ;

TYPEDEF: void* CXSourceLocation
! STRUCT: CXSourceLocation
!     { ptr_data void*[2]  }
!     { data uint } ;

TYPEDEF: void* CXSourceRange
! STRUCT: CXSourceRange
!     { ptr_data void*[2]  }
!     { begin_int_data uint }
!     { end_int_data uint } ;

FUNCTION: CXIndex clang_createIndex ( int excludeDeclarationsFromPCH, int displayDiagnostics )

FUNCTION: CXTranslationUnit clang_parseTranslationUnit (
    CXIndex CIdx, c-string source_filename,
    char** command_line_args, int num_command_line_args,
    CXUnsavedFile *unsaved_files, uint num_unsaved_files,
    uint options )

FUNCTION: void clang_disposeIndex ( CXIndex index )
FUNCTION: void clang_disposeTranslationUnit ( CXTranslationUnit c )

: with-clang-index ( quot: ( index -- ) -- )
    [ 0 0 clang_createIndex ] dip keep clang_disposeIndex ; inline

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
FUNCTION: CXType clang_getEnumConstantDeclValue ( CXCursor C )
FUNCTION: CXType clang_getEnumConstantDeclUnsignedValue ( CXCursor C )
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

FUNCTION: CXFile clang_getFile ( CXTranslationUnit tu, char* file_name )
FUNCTION: CXSourceLocation clang_getLocationForOffset ( CXTranslationUnit tu, CXFile file, uint offset )
FUNCTION: void clang_tokenize ( CXTranslationUnit tu, CXSourceRange range, CXToken **tokens, uint *numTokens )
FUNCTION: void clang_disposeTokens ( CXTranslationUnit tu, CXToken *tokens, uint numTokens )
FUNCTION: CXTokenKind clang_getTokenKind ( CXToken token )
FUNCTION: CXString clang_getTokenSpelling ( CXTranslationUnit tu, CXToken token )
FUNCTION: CXString clang_getCursorDisplayName ( CXCursor C )
FUNCTION: CXString clang_getCursorUSR ( CXCursor C )
FUNCTION: CXString clang_constructUSR_ObjCClass ( char *class_name )
FUNCTION: CXString clang_constructUSR_ObjCCategory ( char *class_name, char *category_name )
FUNCTION: CXString clang_constructUSR_ObjCProtocol ( char *protocol_name )
FUNCTION: CXString clang_constructUSR_ObjCIvar ( char *name, CXString classUSR )
FUNCTION: CXString clang_constructUSR_ObjCMethod ( char *name, uint isInstanceMethod, CXString classUSR )
FUNCTION: CXString clang_constructUSR_ObjCProperty ( char *property, CXString classUSR )

FUNCTION: CXSourceRange clang_getRange ( CXSourceLocation begin, CXSourceLocation end )
FUNCTION: c-string clang_getCString ( CXString string )
FUNCTION: void clang_disposeString ( CXString string )
FUNCTION: void clang_disposeStringSet ( CXStringSet *set )



FUNCTION: uint clang_visitChildren (
    CXCursor parent,
    CXCursorVisitor visitor,
    CXClientData client_data
    )
