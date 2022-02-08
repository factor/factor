! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries
alien.syntax classes.struct combinators io io.backend kernel
prettyprint system ;
IN: libclang

LIBRARY: clang

<< "clang" {
    { [ os windows? ] [ "libclang.dll" ] }
    { [ os macosx? ] [ "libclang.dylib" ] }
    { [ os unix? ] [ "libclang.so" ] }
} cond cdecl add-library >>

TYPEDEF: void* CXTranslationUnitImpl
TYPEDEF: void* CXIndex
TYPEDEF: CXTranslationUnitImpl* CXTranslationUnit
TYPEDEF: void* CXClientData

STRUCT: CXUnsavedFile
{ Filename char* }
{ Contents char* }
{ Length ulong } ;

ENUM: CXCursorKind
{ CXCursor_UnexposedDecl 1 }
{ CXCursor_StructDecl 2 }
{ CXCursor_UnionDecl 3 }
{ CXCursor_TranslationUnit 300 } ;

ENUM: CXChildVisitResult
{ CXChildVisit_Break 0 }
{ CXChildVisit_Continue 1 }
{ CXChildVisit_Recurse 2 } ;

ENUM: CXTypeKind
{ CXType_Invalid 0 }
{ CXType_Unexposed 1 }
{ CXType_Void 2 }
{ CXType_Bool 3 }
{ CXType_Char_U 4 }
{ CXType_UChar 5 }
{ CXType_Char16 6 }
{ CXType_Char32 7 }
{ CXType_UShort 8 } ;



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
FUNCTION: CXString clang_getTypeSpelling ( CXType CT )
FUNCTION: CXString clang_getTypeKindSpelling ( CXTypeKind K )

FUNCTION: uint clang_visitChildren (
    CXCursor parent,
    CXCursorVisitor visitor,
    CXClientData client_data
    )

: cursor-visitor ( -- callback )
    [
        2drop
        {
            [ clang_getCursorType clang_getTypeSpelling data>> . ]
            [ clang_getCursorSpelling data>> . ]
            [ clang_getCursorKind clang_getCursorKindSpelling data>> . ]
        } cleave
        nl
        CXChildVisit_Recurse
    ] CXCursorVisitor ;

! "resource:vm/factor.hpp"
! "C:\\Program Files\\LLVM\\include\\clang-c\\index.h"
: parse-include ( path -- )
    normalize-path
    '[
        _
        f 0 f 0 0 clang_parseTranslationUnit clang_getTranslationUnitCursor
        cursor-visitor f
        clang_visitChildren drop
    ] with-clang-index ;
