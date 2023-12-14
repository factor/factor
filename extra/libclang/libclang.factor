! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums
ascii classes.struct combinators combinators.smart discord io
io.backend io.files.info kernel layouts libclang.ffi math
sequences splitting ;
IN: libclang

: function-arg-cursor-visitor ( -- callback )
    [
        2drop
    ] CXCursorVisitor ;

: CXCursor>factor ( cursor -- string )
    dup clang_getCursorKind {
        { CXCursor_FunctionDecl [ drop f ] }
        { CXType_Pointer [ drop f ] }
        { CXType_Invalid [ drop f ] }
        [ 2drop f ]
    } case ;

: remove-const ( strinng -- string' )
    "const" split1 [ [ blank? ] trim ] bi@ " " glue [ blank? ] trim ;

: cursor-type ( cursor -- string )
    ! [ "cursor display name" g... clang_getCursorDisplayName g... ] keep
    clang_getCursorType
    clang_getTypeSpelling clang_getCString ! "type spelling c string" g... dup g...
    remove-const ;

: cursor-name ( cursor -- string )
    clang_getCursorSpelling data>> ;

: arg-info ( cursor -- string )
    [ cursor-type ] [ cursor-name [ "dummy" ] when-empty ] bi " " glue ;

: cursor>args ( cursor -- args/f )
    dup clang_Cursor_getNumArguments dup -1 = [
        2drop f
    ] [
        <iota> [
            clang_Cursor_getArgument
        ] with { } map-as
    ] if ;

: cxprimitive-type>factor ( type -- string )
    {
        { CXType_Bool [ "bool" ] }
        { CXType_Char_S [ "char" ] }
        { CXType_Char_U [ "uchar" ] }
        { CXType_SChar [ "char" ] }
        { CXType_UChar [ "uchar" ] }
        { CXType_Short [ "short" ] }
        { CXType_UShort [ "ushort" ] }
        { CXType_Int [ "int" ] }
        { CXType_UInt [ "uint" ] }
        { CXType_Long [ "long" ] }
        { CXType_ULong [ "ulong" ] }
        { CXType_LongLong [ "longlong" ] }
        { CXType_ULongLong [ "ulonglong" ] }
        { CXType_Float [ "float" ] }
        { CXType_Double [ "double" ] }
        { CXType_Void [ "void" ] }
        [ drop "" ]
    } case ;

: cxreturn-type>factor ( type -- string )
    {
        { [ dup kind>> CXType_Pointer = ] [
            clang_getPointeeType cxreturn-type>factor "*" append
        ] }
        { [ dup kind>> CXType_Elaborated = ] [
            ! segfault
            ! clang_getCanonicalType dup kind>> CXType_Record = [
            !     ! "canon" g... dup g...
            !     clang_getCString
            ! ] when kind>> cxprimitive-type>factor

            ! Buggy compilation, disable previous section
            clang_getCanonicalType dup kind>> CXType_Record = [
                "canon" g... dup g...
                clang_getCString
            ] [ kind>> cxprimitive-type>factor ] if
        ] }
        ! { [ dup kind>> CXType_Record = ] [
        !     drop ""
        ! ] }
        [ kind>> cxprimitive-type>factor ]
    } cond ;

: cursor>args-info ( cursor -- args-info )
    cursor>args [ arg-info ] map ", " join ;

: function-cursor>string ( cursor -- string )
    [
        {
            [ drop "FUNCTION: " ]
            [ clang_getCursorType clang_getResultType cxreturn-type>factor ]
            [ drop " " ]
            [ clang_getCursorSpelling data>> ]
            [ drop " ( " ]
            [ cursor>args-info dup empty? ")" " )" ? ]
        } cleave
    ] "" append-outputs-as ;

: cursor-visitor ( -- callback )
    [
        2drop dup clang_getCursorKind
        {
            { CXCursor_FunctionDecl [ function-cursor>string gprint ] }
            [ 2drop ]
        } case
        gflush
        CXChildVisit_Recurse
    ] CXCursorVisitor ;

! "resource:vm/factor.hpp" parse-include
! "C:\\Program Files\\LLVM\\include\\clang-c\\index.h"

: clang-get-file-max-range ( CXTranslationUnit path -- CXSourceRange )
    [ dupd clang_getFile 0 clang_getLocationForOffset ]
    [ dupd [ clang_getFile ] [ nip file-info size>> ] 2bi clang_getLocationForOffset ] 2bi
    clang_getRange ;

: parse-c-defines ( path -- )
    dup '[
        _
        f 0
        f 0
        CXTranslationUnit_None enum>number
        clang_parseTranslationUnit
        dup

        [ ]
        [ _ clang-get-file-max-range ] bi
        f void* <ref>
        0 uint <ref>
        [ clang_tokenize ] 2keep
        [ void* deref ]
        [ uint deref <iota> ] bi*
        [
            ! tu void* int
            nipd
            cell-bits 8 /i * swap <displaced-alien>
            clang_getTokenKind
        ] with with { } map-as g...
        gflush
    ] with-clang-index ;

: parse-c-exports ( path -- )
    '[
        _
        f 0 f 0 CXTranslationUnit_None enum>number
        clang_parseTranslationUnit
        clang_getTranslationUnitCursor
        cursor-visitor f
        clang_visitChildren drop
    ] with-clang-index ;

! "resource:vm/factor.hpp" parse-include
: parse-include ( path -- )
    normalize-path
    {
        ! [ parse-c-defines ]
        [ parse-c-exports ]
    } cleave ;

! "/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/php/ext/sqlite3/libsqlite/sqlite3.h" parse-include