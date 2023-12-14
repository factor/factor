! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums
alien.strings ascii classes.struct combinators combinators.smart
discord io io.backend io.encodings.utf8 io.files.info kernel
layouts libclang.ffi math sequences splitting strings ;
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

: clang-get-cstring ( CXString -- string )
    clang_getCString [ utf8 alien>string ] [ clang_disposeString ] bi ;

: remove-const ( strinng -- string' )
    "const" split1 [ [ blank? ] trim ] bi@ " " glue [ blank? ] trim ;

: cursor-type ( cursor -- string )
    ! [ "cursor display name" g... clang_getCursorDisplayName g... ] keep
    clang_getCursorType
    clang_getTypeSpelling clang-get-cstring ! "type spelling c string" g... dup g...
    remove-const ;

: cursor-name ( cursor -- string )
    clang_getCursorSpelling clang-get-cstring ;

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

: cxreturn-type>factor ( CXType -- string )
    {
        { [ dup kind>> CXType_Pointer = ] [
            clang_getPointeeType cxreturn-type>factor "*" append
        ] }
        { [ dup kind>> CXType_Elaborated = ] [
            clang_getCanonicalType cxreturn-type>factor
        ] }
        { [ dup kind>> CXType_Record = ] [
            clang_getTypeDeclaration clang_getCursorSpelling clang-get-cstring
        ] }
        [ kind>> cxprimitive-type>factor ]
    } cond ;

: cursor>args-info ( cursor -- args-info )
    cursor>args [ arg-info ] map ", " join ;

: function-cursor>string ( cursor -- string )
    [
        {
            [ drop "FUNCTION: " ]
            [ clang_getCursorResultType cxreturn-type>factor ]
            [ drop " " ]
            [ clang_getCursorSpelling clang-get-cstring ]
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

: with-clang-index ( quot: ( index -- ) -- )
    [ 0 0 clang_createIndex ] dip keep clang_disposeIndex ; inline

: with-clang-translation-unit ( idx source-file command-line-args nargs unsaved-files nunsaved-files options quot: ( tu -- ) -- )
    [ enum>number clang_parseTranslationUnit ] dip
    keep clang_disposeTranslationUnit ; inline

: with-clang-default-translation-unit ( path quot: ( path tu -- ) -- )
    dupd '[
        _ f 0 f 0 CXTranslationUnit_None [
            [ _ ] dip @
        ] with-clang-translation-unit
    ] with-clang-index ; inline

: with-clang-cursor ( path quot: ( path tu cursor -- ) -- )
    dupd '[
        _ f 0 f 0 CXTranslationUnit_None [
            [ _ ] dip dup clang_getTranslationUnitCursor @
        ] with-clang-translation-unit
    ] with-clang-index ; inline

: clang-get-file-max-range ( CXTranslationUnit path -- CXSourceRange )
    [ dupd clang_getFile 0 clang_getLocationForOffset ]
    [ dupd [ clang_getFile ] [ nip file-info size>> ] 2bi clang_getLocationForOffset ] 2bi
    clang_getRange ;

: parse-c-defines ( path -- )
    [
        swap
        ! tu path
        dupd clang-get-file-max-range ! tu CXRange
        f void* <ref>
        0 uint <ref>
        [ clang_tokenize ] 2keep
        [ void* deref ]
        [ uint deref <iota> ] bi*
        [
            ! tu void* int
            cell-bits 8 /i * swap <displaced-alien>
            clang_getTokenKind
        ] with { } map-as
        g... gflush
    ] with-clang-default-translation-unit ;

: parse-c-exports ( path -- )
    [
        2nip cursor-visitor f clang_visitChildren drop
    ] with-clang-cursor ;

! "resource:vm/factor.hpp" parse-include
: parse-include ( path -- )
    normalize-path
    {
        ! [ parse-c-defines ]
        [ parse-c-exports ]
    } cleave ;

! "/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/php/ext/sqlite3/libsqlite/sqlite3.h" parse-include