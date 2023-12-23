! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums
alien.strings ascii byte-arrays classes.struct combinators
combinators.short-circuit combinators.smart discord io
io.backend io.encodings.utf8 io.files.info kernel layouts libc
libclang.ffi make math math.parser sequences sequences.private
splitting strings ;
IN: libclang

STRUCT: malloced
    { byte-array void* }
    { len uint }
    { offset uint }
    { marked-offset uint } ;

: <malloced> ( len -- malloced )
    malloced malloc-struct
        over 1 + <byte-array> malloc-byte-array >>byte-array
        swap >>len
        0 >>offset
        0 >>marked-offset ;

: mark-malloced ( malloced -- malloced )
    dup offset>> >>marked-offset ;

: since-reset ( malloced -- string )
    [ marked-offset>> ] [ byte-array>> ] bi
    <displaced-alien> utf8 alien>string ;

: reset-malloced ( malloced -- malloced string )
    [ since-reset ]
    [ dup marked-offset>> >>offset ] bi swap ;

: malloced-string ( malloced -- string )
    byte-array>> utf8 alien>string ;

: append-oom? ( malloced string -- ? )
    [ [ len>> ] [ offset>> ] bi - ]
    [ length ] bi* < ;

: realloc-malloced ( malloced -- malloced' )
    dup len>> 2 *
    '[ [ _ 1 + realloc ] change-byte-array ] keep >>len ;

: append-malloced ( malloced string -- malloced )
    2dup append-oom?
    [ [ realloc-malloced ] dip append-malloced ] [
        [
            [
                [ offset>> ] [ byte-array>> ] bi <displaced-alien>
            ] dip [ utf8 string>alien ] [ length ] bi memcpy
        ] [
            '[ _ length + ] change-offset
        ] 2bi
    ] if ;

: malloced>string ( malloced -- string )
    [ byte-array>> utf8 alien>string ] [ free ] bi ;

: clang-get-cstring ( CXString -- string )
    clang_getCString [ utf8 alien>string ] [ clang_disposeString ] bi ;

: trim-blanks ( string -- string' )
    [ blank? ] trim ; inline

: cut-tail ( string quot -- before after ) (trim-tail) cut ; inline

: cell-bytes ( -- n )
    cell-bits 8 /i ; inline

: get-tokens ( tokens ntokens -- tokens )
    <iota> cell-bytes '[
        _ * swap <displaced-alien>
        clang_getTokenKind
    ] with { } map-as ;

: clang-get-file-max-range ( CXTranslationUnit path -- CXSourceRange )
    [ dupd clang_getFile 0 clang_getLocationForOffset ]
    [ dupd [ clang_getFile ] [ nip file-info size>> ] 2bi clang_getLocationForOffset ] 2bi
    clang_getRange ;

: clang-tokenize ( CXTranslationUnit CXSourceRange -- tokens ntokens )
    f void* <ref>
    0 uint <ref>
    [ clang_tokenize ] 2keep
    [ void* deref ]
    [ uint deref ] bi* ;

: tokenize-path ( tu path -- tokens ntokens )
    [ drop ] [ clang-get-file-max-range ] 2bi
    clang-tokenize ;

: tokenize-translation-unit ( CXTranslationUnit -- tokens ntokens )
    [ ] [ clang_getTranslationUnitCursor clang_getCursorExtent ] bi
    clang-tokenize ;

: tokenize-cursor ( cursor -- tokens ntokens )
    [ clang_Cursor_getTranslationUnit ] [ clang_getCursorExtent ] bi
    clang-tokenize ;

: dispose-tokens ( cursor tokens ntokens -- )
    [ clang_Cursor_getTranslationUnit ] 2dip clang_disposeTokens ;

:: with-cursor-tokens ( cursor quot: ( tu token -- obj ) -- )
    cursor clang_Cursor_getTranslationUnit :> tu
    cursor tokenize-cursor :> ( tokens ntokens )
    tokens ntokens <iota>
    cell-bytes :> bytesize
    quot
    '[
        [ tu ] 2dip bytesize * swap <displaced-alien> @
    ] with { } map-as
    tu tokens ntokens dispose-tokens ; inline

: clang-get-token-spelling ( CXTranslationUnit CXToken -- string )
    clang_getTokenSpelling clang-get-cstring ;

: cursor-type ( cursor -- string )
    clang_getCursorType
    clang_getTypeSpelling clang-get-cstring

    "const" ?head drop

    [ CHAR: * = ] cut-tail
    [ [ trim-blanks ] dip append ] when*

    "struct " ?head drop
    {
        { [ dup "_Bool" = ] [ drop "bool" ] }
        { [ "int8_t" ?head ] [ trim-blanks "char" prepend ] }
        { [ "int16_t" ?head ] [ trim-blanks "short" prepend ] }
        { [ "int32_t" ?head ] [ trim-blanks "int" prepend ] }
        { [ "int64_t" ?head ] [ trim-blanks "longlong" prepend ] }
        { [ "uint8_t" ?head ] [ trim-blanks "uchar" prepend ] }
        { [ "uint16_t" ?head ] [ trim-blanks "ushort" prepend ] }
        { [ "uint32_t" ?head ] [ trim-blanks "uint" prepend ] }
        { [ "uint64_t" ?head ] [ trim-blanks "ulonglong" prepend ] }
        { [ "signed char" ?head ] [ trim-blanks "char" prepend ] }
        { [ "signed short" ?head ] [ trim-blanks "short" prepend ] }
        { [ "signed int" ?head ] [ trim-blanks "int" prepend ] }
        { [ "signed long" ?head ] [ trim-blanks "long" prepend ] }
        { [ "unsigned char" ?head ] [ trim-blanks "uchar" prepend ] }
        { [ "unsigned short" ?head ] [ trim-blanks "ushort" prepend ] }
        { [ "unsigned int" ?head ] [ trim-blanks "uint" prepend ] }
        { [ "unsigned long" ?head ] [ trim-blanks "ulong" prepend ] }
        { [ dup "(*)" swap subseq? ] [ drop "void*" ] }
        [ ]
    } cond ;

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
            clang_getPointeeType dup g... gflush cxreturn-type>factor "*" append
        ] }
        { [ dup kind>> CXType_Elaborated = ] [
            clang_getCanonicalType cxreturn-type>factor
        ] }
        { [ dup kind>> CXType_Record = ] [
            clang_getTypeDeclaration cursor-name
        ] }
        { [ dup kind>> CXType_FunctionProto = ] [
            ! inside a CXType_Pointer, so we get `void*` from that case
            drop "void"
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
            [ cursor-name ]
            [ drop " ( " ]
            [ cursor>args-info dup empty? ")\n" " )\n" ? ]
        } cleave
    ] "" append-outputs-as ;

: typedef>string ( CXCursor -- string )
    [ clang_getTypedefDeclUnderlyingType cxreturn-type>factor ]
    [ cursor-name ] bi
    2dup { [ and ] [ = ] } 2||
    [ nip "TYPEDEF: void* " "\n" surround ] [ " " glue "TYPEDEF: " "\n" surround ] if ;

: field-visitor ( -- callback )
    [
        nip
        malloced memory>struct
        swap dup clang_getCursorKind
        {
            { CXCursor_FieldDecl [
                [ cursor-name ] [ cursor-type ] bi " " glue
                "\n  { " " }" surround
                append-malloced drop
                CXChildVisit_Continue
            ] }
            [ dup g... 3drop CXChildVisit_Recurse ]
        } case
        gflush
    ] CXCursorVisitor ;

: struct>string ( malloced CXCursor -- )
    [ mark-malloced ] dip
    tuck cursor-name append-malloced
    [ field-visitor ] dip
    [ clang_visitChildren drop ] keep
    ! hack to removev typedefs like `typedef struct foo foo;`
    dup malloced-string "}" tail? [
        reset-malloced "STRUCT: " " ;\n" surround
        append-malloced drop
    ] [
        reset-malloced "TYPEDEF: void* " "\n" surround
        append-malloced drop
    ] if ;

: enum-visitor ( -- callback )
    [
        nip
        malloced memory>struct
        swap dup clang_getCursorKind
        {
            { CXCursor_EnumConstantDecl [
                "enum" gprint
                [
                    [ clang-get-token-spelling ] with-cursor-tokens
                    first
                ] [
                    clang_getEnumConstantDeclUnsignedValue number>string
                ] bi
                " " glue
                "\n  { " " }" surround
                append-malloced drop
                CXChildVisit_Continue
            ] }
            ! { CXCursor_IntegerLiteral [
            !     "integer" gprint
            !     [ clang-get-token-spelling ] with-cursor-tokens
            !     first " " " }" surround append-malloced drop
            !     CXChildVisit_Continue
            ! ] }
            [ "omg" g... 3dup [ g... ] tri@ 3drop CXChildVisit_Recurse ]
        } case
        gflush
    ] CXCursorVisitor ;

: enum>string ( malloced CXCursor -- )
    [ mark-malloced ] dip
    tuck cursor-name "ENUM: " prepend append-malloced
    [ enum-visitor ] dip
    [ clang_visitChildren drop ] keep
    " ;\n" append-malloced drop ;

: cursor-visitor ( -- callback )
    [
        nip
        malloced memory>struct
        swap dup clang_getCursorKind
        dup g... gflush
        {
            { CXCursor_Namespace [ 2drop CXChildVisit_Recurse ] }
            { CXCursor_FunctionDecl [ function>string append-malloced drop CXChildVisit_Continue ] }
            { CXCursor_TypedefDecl [ typedef>string append-malloced drop CXChildVisit_Continue ] }
            { CXCursor_StructDecl [ struct>string CXChildVisit_Continue ] }
            { CXCursor_EnumDecl [ enum>string CXChildVisit_Continue ] }
            ! { CXType_FunctionProto [ cursor-name "C-TYPE: " "\n" surround append-malloced drop CXChildVisit_Continue ] }
            [ dup g... 3drop CXChildVisit_Recurse ]
        } case
    ] CXCursorVisitor
    gflush ;

: with-clang-index ( quot: ( index -- string ) -- )
    [ 0 0 clang_createIndex ] dip keep clang_disposeIndex ; inline

: with-clang-translation-unit ( idx source-file command-line-args nargs unsaved-files nunsaved-files options quot: ( tu -- string ) -- )
    [ enum>number clang_parseTranslationUnit ] dip
    keep clang_disposeTranslationUnit ; inline

: with-clang-default-translation-unit ( path quot: ( tu path -- string ) -- )
    dupd '[
        _ f 0 f 0 CXTranslationUnit_None [
            _ @
        ] with-clang-translation-unit
    ] with-clang-index ; inline

: with-clang-cursor ( path quot: ( tu path cursor -- string ) -- )
    dupd '[
        _ f 0 f 0 CXTranslationUnit_None [
            _ over clang_getTranslationUnitCursor @
        ] with-clang-translation-unit
    ] with-clang-index ; inline

: parse-c-defines ( path -- string )
    [
        tokenize-path
        [
            ! tu void* int
            cell-bits 8 /i * swap <displaced-alien>
            clang_getTokenKind
        ] with { } map-as
    ] with-clang-default-translation-unit ;

: parse-c-exports ( path -- string )
    [
        nipd cursor-visitor rot file-info size>> 2 * <malloced>
        [ clang_visitChildren drop ] keep malloced>string
    ] with-clang-cursor ;

: parse-include ( path -- string )
    normalize-path
    {
        ! [ parse-c-defines ]
        [ parse-c-exports ]
    } cleave ;

! "/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/php/ext/sqlite3/libsqlite/sqlite3.h" parse-include

! "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/include"

