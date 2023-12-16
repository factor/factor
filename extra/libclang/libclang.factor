! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums
alien.strings ascii byte-arrays classes.struct combinators
combinators.smart discord io io.backend io.encodings.utf8
io.files.info kernel layouts libc libclang.ffi make math
sequences splitting strings ;
IN: libclang

STRUCT: malloced
    { byte-array void* }
    { len uint }
    { offset uint } ;

: <malloced> ( len -- malloced )
    malloced malloc-struct
        over 1 + <byte-array> malloc-byte-array >>byte-array
        swap >>len
        0 >>offset ;

: append-oom? ( malloced string -- ? )
    [ [ len>> ] [ offset>> ] bi - ]
    [ length ] bi* < ;

: realloc-malloced ( malloced -- malloced' )
    dup len>> 2 *
    '[ [ _ 1 + realloc ] change-byte-array ] keep >>len ;

: append-malloced ( malloced string -- )
    2dup append-oom?
    [ [ realloc-malloced ] dip append-malloced ] [
        [
            [
                [ offset>> ] [ byte-array>> ] bi <displaced-alien>
            ] dip [ utf8 string>alien ] [ length ] bi memcpy
        ] [
            '[ _ length + ] change-offset drop
        ] 2bi
    ] if ;

: malloced>string ( malloced -- string )
    [ byte-array>> utf8 alien>string ] [ free ] bi ;

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

: cursor>args ( CXCursor -- args/f )
    dup clang_Cursor_getNumArguments dup -1 = [
        2drop f
    ] [
        <iota> [
            clang_Cursor_getArgument
        ] with { } map-as
    ] if ;

: cxprimitive-type>factor ( CXType -- string )
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

: cursor>args-info ( CXCursor -- args-info )
    cursor>args [ arg-info ] map ", " join ;

: function>string ( CXCursor -- string )
    [
        {
            [ drop "FUNCTION: " ]
            [ clang_getCursorResultType cxreturn-type>factor ]
            [ drop " " ]
            [ clang_getCursorSpelling clang-get-cstring ]
            [ drop " ( " ]
            [ cursor>args-info dup empty? ")\n" " )\n" ? ]
        } cleave
    ] "" append-outputs-as ;

: typedef>string ( CXCursor -- string )
    [ clang_getTypedefDeclUnderlyingType cxreturn-type>factor ]
    [ clang_getCursorSpelling clang-get-cstring ] bi
    2dup = [
        2drop ""
    ] [
        " " glue "TYPEDEF: " "\n" surround
    ] if ;

: struct>string ( CXCursor -- string )
    clang_getCursorSpelling clang-get-cstring "STRUCT: " "\n" surround   ;

: cursor-visitor ( -- callback )
    [
        nip
        malloced memory>struct
        swap dup clang_getCursorKind
        {
            { CXCursor_FunctionDecl [ function>string append-malloced CXChildVisit_Continue ] }
            { CXCursor_TypedefDecl [ typedef>string append-malloced CXChildVisit_Continue ] }
            { CXCursor_StructDecl [ struct>string append-malloced CXChildVisit_Continue ] }
            [ dup g... gflush 3drop CXChildVisit_Recurse ]
        } case
    ] CXCursorVisitor ;

: with-clang-index ( quot: ( index -- string ) -- )
    [ 0 0 clang_createIndex ] dip keep clang_disposeIndex ; inline

: with-clang-translation-unit ( idx source-file command-line-args nargs unsaved-files nunsaved-files options quot: ( tu -- string ) -- )
    [ enum>number clang_parseTranslationUnit ] dip
    keep clang_disposeTranslationUnit ; inline

: with-clang-default-translation-unit ( path quot: ( path tu -- string ) -- )
    dupd '[
        _ f 0 f 0 CXTranslationUnit_None [
            [ _ ] dip @
        ] with-clang-translation-unit
    ] with-clang-index ; inline

: with-clang-cursor ( path quot: ( path tu cursor -- string ) -- )
    dupd '[
        _ f 0 f 0 CXTranslationUnit_None [
            [ _ ] dip dup clang_getTranslationUnitCursor @
        ] with-clang-translation-unit
    ] with-clang-index ; inline

: clang-get-file-max-range ( CXTranslationUnit path -- CXSourceRange )
    [ dupd clang_getFile 0 clang_getLocationForOffset ]
    [ dupd [ clang_getFile ] [ nip file-info size>> ] 2bi clang_getLocationForOffset ] 2bi
    clang_getRange ;

: parse-c-defines ( path -- string )
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
    ] with-clang-default-translation-unit ;

: parse-c-exports ( path -- string )
    [
        nip cursor-visitor rot file-info size>> 2 * <malloced>
        [ clang_visitChildren drop ] keep malloced>string
    ] with-clang-cursor ;

: parse-include ( path -- string )
    normalize-path
    {
        ! [ parse-c-defines ]
        [ parse-c-exports ]
    } cleave ;

! "/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/php/ext/sqlite3/libsqlite/sqlite3.h" parse-include