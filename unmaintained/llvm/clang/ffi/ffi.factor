USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators system unix.types ;
IN: llvm.clang.ffi

<<
"libclang" {
    { [ os macosx?  ] [ "libclang.dylib" ] }
    { [ os windows? ] [ "clang.dll"      ] }
    { [ os unix?    ] [ "/usrlibclang.so"    ] }
} cond cdecl add-library
>>
LIBRARY: libclang

C-TYPE: CXTranslationUnitImpl

TYPEDEF: void* CXIndex
TYPEDEF: CXTranslationUnitImpl* CXTranslationUnit
TYPEDEF: void* CXClientData

STRUCT: CXUnsavedFile
    { Filename c-string }
    { Contents c-string }
    { Length   ulong    } ;

ENUM: CXAvailabilityKind
  CXAvailability_Available
  CXAvailability_Deprecated
  CXAvailability_NotAvailable ;

STRUCT: CXString
    { data          void* }
    { private_flags uint  } ;

FUNCTION: c-string clang_getCString ( CXString string ) ;
FUNCTION: void clang_disposeString ( CXString string ) ;

FUNCTION: CXIndex clang_createIndex ( int excludeDeclarationsFromPCH,
                                      int displayDiagnostics ) ;
FUNCTION: void clang_disposeIndex ( CXIndex index ) ;

TYPEDEF: void* CXFile

FUNCTION: CXString clang_getFileName ( CXFile SFile ) ;
FUNCTION: time_t clang_getFileTime ( CXFile SFile ) ;
FUNCTION: uint clang_isFileMultipleIncludeGuarded ( CXTranslationUnit tu, CXFile file ) ;
FUNCTION: CXFile clang_getFile ( CXTranslationUnit tu, c-string file_name ) ;

STRUCT: CXSourceLocation
    { ptr_data void*[2] }
    { int_data uint     } ;

STRUCT: CXSourceRange
    { ptr_data       void*[2] }
    { begin_int_data uint     }
    { end_int_data   uint     } ;

FUNCTION: CXSourceLocation clang_getNullLocation ( ) ;
FUNCTION: uint clang_equalLocations ( CXSourceLocation loc1, CXSourceLocation loc2 ) ;

FUNCTION: CXSourceLocation clang_getLocation ( CXTranslationUnit tu, CXFile file, uint line, uint column ) ;
FUNCTION: CXSourceLocation clang_getLocationForOffset ( CXTranslationUnit tu,
                                                        CXFile            file,
                                                        uint              offset ) ;

FUNCTION: CXSourceRange clang_getNullRange ( ) ;

FUNCTION: CXSourceRange clang_getRange ( CXSourceLocation begin,
                                         CXSourceLocation end ) ;

FUNCTION: void clang_getInstantiationLocation ( CXSourceLocation location,
                                                CXFile*          file,
                                                uint*            line,
                                                uint*            column,
                                                uint*            offset ) ;

FUNCTION: void clang_getSpellingLocation ( CXSourceLocation location,
                                           CXFile*          file,
                                           uint*            line,
                                           uint*            column,
                                           uint*            offset ) ;

FUNCTION: CXSourceLocation clang_getRangeStart ( CXSourceRange range ) ;
FUNCTION: CXSourceLocation clang_getRangeEnd ( CXSourceRange range ) ;

ENUM: CXDiagnosticSeverity
  CXDiagnostic_Ignored
  CXDiagnostic_Note
  CXDiagnostic_Warning
  CXDiagnostic_Error
  CXDiagnostic_Fatal ;

TYPEDEF: void* CXDiagnostic

FUNCTION: uint clang_getNumDiagnostics ( CXTranslationUnit Unit ) ;
FUNCTION: CXDiagnostic clang_getDiagnostic ( CXTranslationUnit Unit,
                                             uint              Index ) ;
FUNCTION: void clang_disposeDiagnostic ( CXDiagnostic Diagnostic ) ;

ENUM: CXDiagnosticDisplayOptions
    { CXDiagnostic_DisplaySourceLocation 0x01 }
    { CXDiagnostic_DisplayColumn         0x02 }
    { CXDiagnostic_DisplaySourceRanges   0x04 }
    { CXDiagnostic_DisplayOption         0x08 }
    { CXDiagnostic_DisplayCategoryId     0x10 }
    { CXDiagnostic_DisplayCategoryName   0x20 } ;

FUNCTION: CXString clang_formatDiagnostic ( CXDiagnostic Diagnostic,
                                            uint         Options ) ;
FUNCTION: uint clang_defaultDiagnosticDisplayOptions ( ) ;

FUNCTION: CXDiagnosticSeverity clang_getDiagnosticSeverity ( CXDiagnostic ) ;
FUNCTION: CXSourceLocation clang_getDiagnosticLocation ( CXDiagnostic ) ;
FUNCTION: CXString clang_getDiagnosticSpelling ( CXDiagnostic ) ;
FUNCTION: CXString clang_getDiagnosticOption ( CXDiagnostic Diag, CXString* Disable ) ;
FUNCTION: uint clang_getDiagnosticCategory ( CXDiagnostic ) ;
FUNCTION: CXString clang_getDiagnosticCategoryName ( uint Category ) ;
FUNCTION: uint clang_getDiagnosticNumRanges ( CXDiagnostic ) ;
FUNCTION: CXSourceRange clang_getDiagnosticRange ( CXDiagnostic Diagnostic, uint Range ) ;
FUNCTION: uint clang_getDiagnosticNumFixIts ( CXDiagnostic Diagnostic ) ;
FUNCTION: CXString clang_getDiagnosticFixIt ( CXDiagnostic   Diagnostic,
                                              uint           FixIt,
                                              CXSourceRange* ReplacementRange ) ;
FUNCTION: CXString clang_getTranslationUnitSpelling ( CXTranslationUnit CTUnit ) ;
FUNCTION: CXTranslationUnit clang_createTranslationUnitFromSourceFile ( CXIndex        CIdx,
                                                                        c-string       source_filename,
                                                                        int            num_clang_command_line_args,
                                                                        char**         clang_command_line_args,
                                                                        uint           num_unsaved_files,
                                                                        CXUnsavedFile* unsaved_files ) ;
FUNCTION: CXTranslationUnit clang_createTranslationUnit ( CXIndex CIdx, c-string ast_filename ) ;

ENUM: CXTranslationUnit_Flags
    { CXTranslationUnit_None                        0x00 }
    { CXTranslationUnit_DetailedPreprocessingRecord 0x01 }
    { CXTranslationUnit_Incomplete                  0x02 }
    { CXTranslationUnit_PrecompiledPreamble         0x04 }
    { CXTranslationUnit_CacheCompletionResults      0x08 }
    { CXTranslationUnit_CXXPrecompiledPreamble      0x10 }
    { CXTranslationUnit_CXXChainedPCH               0x20 }
    { CXTranslationUnit_NestedMacroInstantiations   0x40 } ;

FUNCTION: uint clang_defaultEditingTranslationUnitOptions ( ) ;
FUNCTION: CXTranslationUnit clang_parseTranslationUnit ( CXIndex        CIdx,
                                                         c-string       source_filename,
                                                         char**         command_line_args,
                                                         int            num_command_line_args,
                                                         CXUnsavedFile* unsaved_files,
                                                         uint           num_unsaved_files,
                                                         uint           options ) ;

ENUM: CXSaveTranslationUnit_Flags CXSaveTranslationUnit_None ;

FUNCTION: uint clang_defaultSaveOptions ( CXTranslationUnit TU ) ;
FUNCTION: int clang_saveTranslationUnit ( CXTranslationUnit TU,
                                          c-string          FileName,
                                          uint              options ) ;
FUNCTION: void clang_disposeTranslationUnit ( CXTranslationUnit ) ;

ENUM: CXReparse_Flags CXReparse_None ;

FUNCTION: uint clang_defaultReparseOptions ( CXTranslationUnit TU ) ;
FUNCTION: int clang_reparseTranslationUnit ( CXTranslationUnit TU,
                                             uint              num_unsaved_files,
                                             CXUnsavedFile*    unsaved_files,
                                             uint              options ) ;

ENUM: CXTUResourceUsageKind
    { CXTUResourceUsage_AST                                 1 }
    { CXTUResourceUsage_Identifiers                         2 }
    { CXTUResourceUsage_Selectors                           3 }
    { CXTUResourceUsage_GlobalCompletionResults             4 }
    { CXTUResourceUsage_SourceManagerContentCache           5 }
    { CXTUResourceUsage_AST_SideTables                      6 }
    { CXTUResourceUsage_SourceManager_Membuffer_Malloc      7 }
    { CXTUResourceUsage_SourceManager_Membuffer_MMap        8 }
    { CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc  9 }
    { CXTUResourceUsage_ExternalASTSource_Membuffer_MMap   10 }
    { CXTUResourceUsage_Preprocessor                       11 }
    { CXTUResourceUsage_PreprocessingRecord                12 }
    { CXTUResourceUsage_MEMORY_IN_BYTES_BEGIN               1 }
    { CXTUResourceUsage_MEMORY_IN_BYTES_END                12 }
    { CXTUResourceUsage_First                               1 }
    { CXTUResourceUsage_Last                               12 } ;

FUNCTION: c-string clang_getTUResourceUsageName ( CXTUResourceUsageKind kind ) ;

STRUCT: CXTUResourceUsageEntry
    { kind   CXTUResourceUsageKind }
    { amount ulong                 } ;

STRUCT: CXTUResourceUsage
    { data       void*                   }
    { numEntries uint                    }
    { entries    CXTUResourceUsageEntry* } ;

FUNCTION: CXTUResourceUsage clang_getCXTUResourceUsage ( CXTranslationUnit TU ) ;
FUNCTION: void clang_disposeCXTUResourceUsage ( CXTUResourceUsage usage ) ;

ENUM: CXCursorKind
    { CXCursor_UnexposedDecl                        1 }
    { CXCursor_StructDecl                           2 }
    { CXCursor_UnionDecl                            3 }
    { CXCursor_ClassDecl                            4 }
    { CXCursor_EnumDecl                             5 }
    { CXCursor_FieldDecl                            6 }
    { CXCursor_EnumConstantDecl                     7 }
    { CXCursor_FunctionDecl                         8 }
    { CXCursor_VarDecl                              9 }
    { CXCursor_ParmDecl                            10 }
    { CXCursor_ObjCInterfaceDecl                   11 }
    { CXCursor_ObjCCategoryDecl                    12 }
    { CXCursor_ObjCProtocolDecl                    13 }
    { CXCursor_ObjCPropertyDecl                    14 }
    { CXCursor_ObjCIvarDecl                        15 }
    { CXCursor_ObjCInstanceMethodDecl              16 }
    { CXCursor_ObjCClassMethodDecl                 17 }
    { CXCursor_ObjCImplementationDecl              18 }
    { CXCursor_ObjCCategoryImplDecl                19 }
    { CXCursor_TypedefDecl                         20 }
    { CXCursor_CXXMethod                           21 }
    { CXCursor_Namespace                           22 }
    { CXCursor_LinkageSpec                         23 }
    { CXCursor_Constructor                         24 }
    { CXCursor_Destructor                          25 }
    { CXCursor_ConversionFunction                  26 }
    { CXCursor_TemplateTypeParameter               27 }
    { CXCursor_NonTypeTemplateParameter            28 }
    { CXCursor_TemplateTemplateParameter           29 }
    { CXCursor_FunctionTemplate                    30 }
    { CXCursor_ClassTemplate                       31 }
    { CXCursor_ClassTemplatePartialSpecialization  32 }
    { CXCursor_NamespaceAlias                      33 }
    { CXCursor_UsingDirective                      34 }
    { CXCursor_UsingDeclaration                    35 }
    { CXCursor_TypeAliasDecl                       36 }
    { CXCursor_FirstDecl                            1 }
    { CXCursor_LastDecl                            36 }
    { CXCursor_FirstRef                            40 }
    { CXCursor_ObjCSuperClassRef                   40 }
    { CXCursor_ObjCProtocolRef                     41 }
    { CXCursor_ObjCClassRef                        42 }
    { CXCursor_TypeRef                             43 }
    { CXCursor_CXXBaseSpecifier                    44 }
    { CXCursor_TemplateRef                         45 }
    { CXCursor_NamespaceRef                        46 }
    { CXCursor_MemberRef                           47 }
    { CXCursor_LabelRef                            48 }
    { CXCursor_OverloadedDeclRef                   49 }
    { CXCursor_LastRef                             49 }
    { CXCursor_FirstInvalid                        70 }
    { CXCursor_InvalidFile                         70 }
    { CXCursor_NoDeclFound                         71 }
    { CXCursor_NotImplemented                      72 }
    { CXCursor_InvalidCode                         73 }
    { CXCursor_LastInvalid                         73 }
    { CXCursor_FirstExpr                          100 }
    { CXCursor_UnexposedExpr                      100 }
    { CXCursor_DeclRefExpr                        101 }
    { CXCursor_MemberRefExpr                      102 }
    { CXCursor_CallExpr                           103 }
    { CXCursor_ObjCMessageExpr                    104 }
    { CXCursor_BlockExpr                          105 }
    { CXCursor_LastExpr                           105 }
    { CXCursor_FirstStmt                          200 }
    { CXCursor_UnexposedStmt                      200 }
    { CXCursor_LabelStmt                          201 }
    { CXCursor_LastStmt                           201 }
    { CXCursor_TranslationUnit                    300 }
    { CXCursor_FirstAttr                          400 }
    { CXCursor_UnexposedAttr                      400 }
    { CXCursor_IBActionAttr                       401 }
    { CXCursor_IBOutletAttr                       402 }
    { CXCursor_IBOutletCollectionAttr             403 }
    { CXCursor_LastAttr                           403 }
    { CXCursor_PreprocessingDirective             500 }
    { CXCursor_MacroDefinition                    501 }
    { CXCursor_MacroInstantiation                 502 }
    { CXCursor_InclusionDirective                 503 }
    { CXCursor_FirstPreprocessing                 500 }
    { CXCursor_LastPreprocessing                  503 } ;

STRUCT: CXCursor
    { kind CXCursorKind }
    { data void*[3]     } ;

FUNCTION: CXCursor clang_getNullCursor ( ) ;
FUNCTION: CXCursor clang_getTranslationUnitCursor ( CXTranslationUnit ) ;
FUNCTION: uint clang_equalCursors ( CXCursor c1, CXCursor c2 ) ;
FUNCTION: uint clang_hashCursor ( CXCursor ) ;
FUNCTION: CXCursorKind clang_getCursorKind ( CXCursor ) ;
FUNCTION: uint clang_isDeclaration ( CXCursorKind ) ;
FUNCTION: uint clang_isReference ( CXCursorKind ) ;
FUNCTION: uint clang_isExpression ( CXCursorKind ) ;
FUNCTION: uint clang_isStatement ( CXCursorKind ) ;
FUNCTION: uint clang_isInvalid ( CXCursorKind ) ;
FUNCTION: uint clang_isTranslationUnit ( CXCursorKind ) ;
FUNCTION: uint clang_isPreprocessing ( CXCursorKind ) ;
FUNCTION: uint clang_isUnexposed ( CXCursorKind ) ;

ENUM: CXLinkageKind
  CXLinkage_Invalid
  CXLinkage_NoLinkage
  CXLinkage_Internal
  CXLinkage_UniqueExternal
  CXLinkage_External ;

ENUM: CXLanguageKind
  CXLanguage_Invalid
  CXLanguage_C
  CXLanguage_ObjC
  CXLanguage_CPlusPlus ;

FUNCTION: CXLinkageKind clang_getCursorLinkage ( CXCursor cursor ) ;
FUNCTION: CXAvailabilityKind clang_getCursorAvailability ( CXCursor cursor ) ;
FUNCTION: CXLanguageKind clang_getCursorLanguage ( CXCursor cursor ) ;

C-TYPE: CXCursorSetImpl
TYPEDEF: CXCursorSetImpl* CXCursorSet

FUNCTION: CXCursorSet clang_createCXCursorSet ( ) ;
FUNCTION: void clang_disposeCXCursorSet ( CXCursorSet cset ) ;
FUNCTION: uint clang_CXCursorSet_contains ( CXCursorSet cset, CXCursor cursor ) ;
FUNCTION: uint clang_CXCursorSet_insert ( CXCursorSet cset, CXCursor cursor ) ;
FUNCTION: CXCursor clang_getCursorSemanticParent ( CXCursor cursor ) ;
FUNCTION: CXCursor clang_getCursorLexicalParent ( CXCursor cursor ) ;
FUNCTION: void clang_getOverriddenCursors ( CXCursor cursor, CXCursor** overridden, uint* num_overridden ) ;
FUNCTION: void clang_disposeOverriddenCursors ( CXCursor* overridden ) ;
FUNCTION: CXFile clang_getIncludedFile ( CXCursor cursor ) ;
FUNCTION: CXCursor clang_getCursor ( CXTranslationUnit TU,
                                     CXSourceLocation location ) ;
FUNCTION: CXSourceLocation clang_getCursorLocation ( CXCursor ) ;
FUNCTION: CXSourceRange clang_getCursorExtent ( CXCursor ) ;

ENUM: CXTypeKind
    { CXType_Invalid             0 }
    { CXType_Unexposed           1 }
    { CXType_Void                2 }
    { CXType_Bool                3 }
    { CXType_Char_U              4 }
    { CXType_UChar               5 }
    { CXType_Char16              6 }
    { CXType_Char32              7 }
    { CXType_UShort              8 }
    { CXType_UInt                9 }
    { CXType_ULong              10 }
    { CXType_ULongLong          11 }
    { CXType_UInt128            12 }
    { CXType_Char_S             13 }
    { CXType_SChar              14 }
    { CXType_WChar              15 }
    { CXType_Short              16 }
    { CXType_Int                17 }
    { CXType_Long               18 }
    { CXType_LongLong           19 }
    { CXType_Int128             20 }
    { CXType_Float              21 }
    { CXType_Double             22 }
    { CXType_LongDouble         23 }
    { CXType_NullPtr            24 }
    { CXType_Overload           25 }
    { CXType_Dependent          26 }
    { CXType_ObjCId             27 }
    { CXType_ObjCClass          28 }
    { CXType_ObjCSel            29 }
    { CXType_FirstBuiltin        2 }
    { CXType_LastBuiltin        29 }
    { CXType_Complex           100 }
    { CXType_Pointer           101 }
    { CXType_BlockPointer      102 }
    { CXType_LValueReference   103 }
    { CXType_RValueReference   104 }
    { CXType_Record            105 }
    { CXType_Enum              106 }
    { CXType_Typedef           107 }
    { CXType_ObjCInterface     108 }
    { CXType_ObjCObjectPointer 109 }
    { CXType_FunctionNoProto   110 }
    { CXType_FunctionProto     111 } ;

STRUCT: CXType
    { kind CXTypeKind }
    { data void*[2]   } ;

FUNCTION: CXType clang_getCursorType ( CXCursor C ) ;
FUNCTION: uint clang_equalTypes ( CXType A, CXType B ) ;
FUNCTION: CXType clang_getCanonicalType ( CXType T ) ;
FUNCTION: uint clang_isConstQualifiedType ( CXType T ) ;
FUNCTION: uint clang_isVolatileQualifiedType ( CXType T ) ;
FUNCTION: uint clang_isRestrictQualifiedType ( CXType T ) ;
FUNCTION: CXType clang_getPointeeType ( CXType T ) ;
FUNCTION: CXCursor clang_getTypeDeclaration ( CXType T ) ;
FUNCTION: CXString clang_getDeclObjCTypeEncoding ( CXCursor C ) ;
FUNCTION: CXString clang_getTypeKindSpelling ( CXTypeKind K ) ;
FUNCTION: CXType clang_getResultType ( CXType T ) ;
FUNCTION: CXType clang_getCursorResultType ( CXCursor C ) ;
FUNCTION: uint clang_isPODType ( CXType T ) ;
FUNCTION: uint clang_isVirtualBase ( CXCursor ) ;

ENUM: CX_CXXAccessSpecifier
  CX_CXXInvalidAccessSpecifier
  CX_CXXPublic
  CX_CXXProtected
  CX_CXXPrivate ;

FUNCTION: CX_CXXAccessSpecifier clang_getCXXAccessSpecifier ( CXCursor ) ;
FUNCTION: uint clang_getNumOverloadedDecls ( CXCursor cursor ) ;
FUNCTION: CXCursor clang_getOverloadedDecl ( CXCursor cursor, uint index ) ;
FUNCTION: CXType clang_getIBOutletCollectionType ( CXCursor ) ;

ENUM: CXChildVisitResult
  CXChildVisit_Break
  CXChildVisit_Continue
  CXChildVisit_Recurse ;

CALLBACK: CXChildVisitResult CXCursorVisitor ( CXCursor     cursor,
                                               CXCursor     parent,
                                               CXClientData client_data ) ;

FUNCTION: uint clang_visitChildren ( CXCursor        parent,
                                     CXCursorVisitor visitor,
                                     CXClientData    client_data ) ;
FUNCTION: CXString clang_getCursorUSR ( CXCursor ) ;
FUNCTION: CXString clang_constructUSR_ObjCClass ( c-string class_name ) ;
FUNCTION: CXString clang_constructUSR_ObjCCategory ( c-string class_name,
                                                     c-string category_name ) ;
FUNCTION: CXString clang_constructUSR_ObjCProtocol ( c-string protocol_name ) ;
FUNCTION: CXString clang_constructUSR_ObjCIvar ( c-string name,
                                                 CXString classUSR ) ;
FUNCTION: CXString clang_constructUSR_ObjCMethod ( c-string name,
                                                   uint     isInstanceMethod,
                                                   CXString classUSR ) ;
FUNCTION: CXString clang_constructUSR_ObjCProperty ( c-string property,
                                                     CXString classUSR ) ;
FUNCTION: CXString clang_getCursorSpelling ( CXCursor ) ;
FUNCTION: CXString clang_getCursorDisplayName ( CXCursor ) ;
FUNCTION: CXCursor clang_getCursorReferenced ( CXCursor ) ;
FUNCTION: CXCursor clang_getCursorDefinition ( CXCursor ) ;
FUNCTION: uint clang_isCursorDefinition ( CXCursor ) ;
FUNCTION: CXCursor clang_getCanonicalCursor ( CXCursor ) ;
FUNCTION: uint clang_CXXMethod_isStatic ( CXCursor C ) ;
FUNCTION: uint clang_CXXMethod_isVirtual ( CXCursor C ) ;
FUNCTION: CXCursorKind clang_getTemplateCursorKind ( CXCursor C ) ;
FUNCTION: CXCursor clang_getSpecializedCursorTemplate ( CXCursor C ) ;

ENUM: CXTokenKind
  CXToken_Punctuation
  CXToken_Keyword
  CXToken_Identifier
  CXToken_Literal
  CXToken_Comment ;

STRUCT: CXToken
    { int_data uint[4] }
    { ptr_data void*   } ;

FUNCTION: CXTokenKind clang_getTokenKind ( CXToken ) ;
FUNCTION: CXString clang_getTokenSpelling ( CXTranslationUnit TU,
                                            CXToken           Token ) ;
FUNCTION: CXSourceLocation clang_getTokenLocation ( CXTranslationUnit TU,
                                                    CXToken           Token ) ;
FUNCTION: CXSourceRange clang_getTokenExtent ( CXTranslationUnit TU,
                                               CXToken           Token ) ;
FUNCTION: void clang_tokenize ( CXTranslationUnit TU,
                                CXSourceRange     Range,
                                CXToken**         Tokens,
                                uint*             NumTokens ) ;
FUNCTION: void clang_annotateTokens ( CXTranslationUnit TU,
                                      CXToken*          Tokens,
                                      uint              NumTokens,
                                      CXCursor*         Cursors ) ;
FUNCTION: void clang_disposeTokens ( CXTranslationUnit TU,
                                     CXToken*          Tokens,
                                     uint              NumTokens ) ;

FUNCTION: CXString clang_getCursorKindSpelling ( CXCursorKind Kind ) ;
FUNCTION: void clang_getDefinitionSpellingAndExtent ( CXCursor cursor,
                                                      char**   startBuf,
                                                      char**   endBuf,
                                                      uint*    startLine,
                                                      uint*    startColumn,
                                                      uint*    endLine,
                                                      uint*    endColumn ) ;
FUNCTION: void clang_enableStackTraces ( ) ;

CALLBACK: void executeOnThreadCallback ( void* ) ;
FUNCTION: void clang_executeOnThread ( executeOnThreadCallback* callback,
                                       void*                    user_data,
                                       uint                     stack_size ) ;

TYPEDEF: void* CXCompletionString

STRUCT: CXCompletionResult
    { CursorKind       CXCursorKind       }
    { CompletionString CXCompletionString } ;

ENUM: CXCompletionChunkKind
  CXCompletionChunk_Optional
  CXCompletionChunk_TypedText
  CXCompletionChunk_Text
  CXCompletionChunk_Placeholder
  CXCompletionChunk_Informative
  CXCompletionChunk_CurrentParameter
  CXCompletionChunk_LeftParen
  CXCompletionChunk_RightParen
  CXCompletionChunk_LeftBracket
  CXCompletionChunk_RightBracket
  CXCompletionChunk_LeftBrace
  CXCompletionChunk_RightBrace
  CXCompletionChunk_LeftAngle
  CXCompletionChunk_RightAngle
  CXCompletionChunk_Comma
  CXCompletionChunk_ResultType
  CXCompletionChunk_Colon
  CXCompletionChunk_SemiColon
  CXCompletionChunk_Equal
  CXCompletionChunk_HorizontalSpace
  CXCompletionChunk_VerticalSpace ;

FUNCTION: CXCompletionChunkKind clang_getCompletionChunkKind ( CXCompletionString completion_string,
                                                               uint               chunk_number ) ;
FUNCTION: CXString clang_getCompletionChunkText ( CXCompletionString completion_string,
                                                  uint               chunk_number ) ;
FUNCTION: CXCompletionString clang_getCompletionChunkCompletionString ( CXCompletionString completion_string,
                                                                        uint               chunk_number ) ;
FUNCTION: uint clang_getNumCompletionChunks ( CXCompletionString completion_string ) ;
FUNCTION: uint clang_getCompletionPriority ( CXCompletionString completion_string ) ;
FUNCTION: CXAvailabilityKind clang_getCompletionAvailability ( CXCompletionString completion_string ) ;

STRUCT: CXCodeCompleteResults
    { Results CXCompletionResult* }
    { NumResults uint             } ;

ENUM: CXCodeComplete_Flags
    { CXCodeComplete_IncludeMacros       1 }
    { CXCodeComplete_IncludeCodePatterns 2 } ;

FUNCTION: uint clang_defaultCodeCompleteOptions ( ) ;

FUNCTION: CXCodeCompleteResults* clang_codeCompleteAt ( CXTranslationUnit TU,
                                                        c-string          complete_filename,
                                                        uint              complete_line,
                                                        uint              complete_column,
                                                        CXUnsavedFile*    unsaved_files,
                                                        uint              num_unsaved_files,
                                                        uint              options ) ;

FUNCTION: void clang_sortCodeCompletionResults ( CXCompletionResult* Results, uint NumResults ) ;
FUNCTION: void clang_disposeCodeCompleteResults ( CXCodeCompleteResults* Results ) ;
FUNCTION: uint clang_codeCompleteGetNumDiagnostics ( CXCodeCompleteResults* Results ) ;

FUNCTION: CXDiagnostic clang_codeCompleteGetDiagnostic ( CXCodeCompleteResults* Results,
                                                         uint                   Index ) ;

FUNCTION: CXString clang_getClangVersion ( ) ;
FUNCTION: void clang_toggleCrashRecovery ( uint isEnabled ) ;

CALLBACK: void CXInclusionVisitor ( CXFile            included_file,
                                    CXSourceLocation* inclusion_stack,
                                    uint              include_len,
                                    CXClientData      client_data ) ;

FUNCTION: void clang_getInclusions ( CXTranslationUnit  tu,
                                     CXInclusionVisitor visitor,
                                     CXClientData       client_data ) ;
