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
    { offset uint }
    { latest-offset uint } ;

: <malloced> ( len -- malloced )
    malloced malloc-struct
        over 1 + <byte-array> malloc-byte-array >>byte-array
        swap >>len
        0 >>offset
        0 >>latest-offset ;

: mark-malloced ( malloced -- malloced )
    dup offset>> >>latest-offset ;

: reset-malloced ( malloced -- malloced )
    dup latest-offset>> >>offset ;

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

: CXCursor>factor ( cursor -- string )
    dup clang_getCursorKind {
        { CXCursor_FunctionDecl [ drop f ] }
        { CXType_Pointer [ drop f ] }
        { CXType_Invalid [ drop f ] }
        [ 2drop f ]
    } case ;

: clang-get-cstring ( CXString -- string )
    clang_getCString [ utf8 alien>string ] [ clang_disposeString ] bi ;

: trim-blanks ( string -- string' )
    [ blank? ] trim ; inline

: remove-const ( strinng -- string' )
    "const" split1 [ trim-blanks ] bi@ " " glue trim-blanks ;

: cursor-type ( cursor -- string )
    clang_getCursorType
    clang_getTypeSpelling clang-get-cstring
    ! remove-const
    "const" ?head drop
    "*" ?tail [ trim-blanks "*" append ] when
    "struct " ?head drop ! [ trim-blanks ] when

    {
        { [ dup "unsigned char" = ] [ drop "uchar" ] }
        { [ "unsigned char" ?head ] [ trim-blanks "uchar" prepend ] }
        { [ "unsigned int" ?head ] [ trim-blanks "uint" prepend ] }
        ! { [ "*" ?tail ] [ trim-blanks "*" append ] }
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
    2dup = [
        2drop ""
    ] [
        " " glue "TYPEDEF: " "\n" surround
    ] if ;


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
            ! { CXCursor_TypedefDecl [ 2drop CXChildVisit_Continue ] }
            ! { CXCursor_StructDecl [ 2drop CXChildVisit_Continue ] }
            [ dup g...  3drop CXChildVisit_Recurse ]
        } case
        gflush
    ] CXCursorVisitor ;

: struct>string ( malloced CXCursor -- )
    [ mark-malloced ] dip
    tuck cursor-name "STRUCT: " prepend append-malloced
    [ field-visitor ] dip
    [ clang_visitChildren drop ] keep
    ! hack to removev typedefs like `typedef struct foo foo;`
    dup malloced-string "}" tail? [
        " ;\n" append-malloced drop
    ] [
        reset-malloced drop
    ] if ;

: cursor-visitor ( -- callback )
    [
        nip
        malloced memory>struct
        swap dup clang_getCursorKind
        {
            { CXCursor_Namespace [ 2drop CXChildVisit_Recurse ] }
            { CXCursor_FunctionDecl [ function>string append-malloced drop CXChildVisit_Continue ] }
            { CXCursor_TypedefDecl [ typedef>string append-malloced drop CXChildVisit_Continue ] }
            { CXCursor_StructDecl [ struct>string CXChildVisit_Continue ] }
            [ dup g... 3drop CXChildVisit_Recurse ]
        } case
    ] CXCursorVisitor
    gflush ;

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

! "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/include"

