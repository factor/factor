! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums
alien.strings ascii assocs byte-arrays classes classes.struct
combinators combinators.extras combinators.short-circuit
combinators.smart discord io io.backend io.encodings.utf8
io.files.info kernel layouts libc libclang.ffi make math
math.parser multiline namespaces prettyprint sequences
sequences.private sets sorting splitting strings ;
IN: libclang

SYMBOL: clang-state
: clang-state> ( -- clang-state ) clang-state get-global ;

! todo: typedefs
TUPLE: libclang-state
    defs-counter c-defs-by-name c-defs-by-order
    c-forms child-forms
    unnamed-table unnamed-counter
    out-forms-counter out-forms out-forms-written ;

: <libclang-state> ( -- state )
    libclang-state new
        0 >>defs-counter
        H{ } clone >>c-defs-by-name
        H{ } clone >>c-defs-by-order
        V{ } clone >>c-forms
        H{ } clone >>child-forms
        0 >>unnamed-counter
        H{ } clone >>unnamed-table
        0 >>out-forms-counter
        H{ } clone >>out-forms
        HS{ } clone >>out-forms-written ;

GENERIC: def>out-form ( obj -- string )

: save-out-form ( string -- )
    [
        dup clang-state> out-forms-written>> in? [
            drop
        ] [
            clang-state>
            [
                [ out-forms-counter>> counter ]
                [ out-forms>> set-at ] bi
            ]
            [ out-forms-written>> adjoin ] 2bi
        ] if
    ] unless-empty ;

! some forms must be defined out of order, e.g. anonymous unions/structs
: def>out-forms ( obj -- )
    def>out-form save-out-form ;

: peek-current-form ( -- n )
    clang-state> c-forms>> ?last ; inline

SLOT: parent-order
SLOT: order

: push-child-form ( form -- )
    ! dup order>> c-defs-by-order get-global set-at ; inline
    dup parent-order>> clang-state> child-forms>> push-at ; inline

: with-new-form ( quot -- n )
    clang-state> [ defs-counter>> counter ] [ c-forms>> ] bi push
    call
    clang-state> c-forms>> pop ; inline

ERROR: unknown-form name ;
GENERIC: print-deferred ( obj -- )
M: object print-deferred
    type>> clang-state> c-defs-by-name>> ?at [ def>out-forms ] [ unknown-form ] if ;

: unnamed? ( string -- ? ) "(unnamed" swap subseq? ; inline
: append-counter ( string counter -- string' ) counter number>string append ; inline
: unnamed-exists? ( string -- value/key ? ) clang-state> unnamed-table>> ?at ; inline
: lookup-unnamed ( type string -- type-name )
    unnamed-exists? [
        nip
    ] [
        [ clang-state> unnamed-counter>> append-counter ] dip
        " " split1-last nip
        "RECORDING: " gwrite dup g... gflush
        [ clang-state> unnamed-table>> set-at ] keepd
    ] if ; inline

: ?unnamed ( string type -- string' ? )
    over unnamed? [
        swap lookup-unnamed t
    ] [
        drop f
    ] if ;

TUPLE: c-function
    { return-type string }
    { name string }
    { args string }
    { order integer } ;

: <c-function> ( return-type name args -- c-function )
    c-function new
        swap >>args
        swap >>name
        swap >>return-type
        clang-state> defs-counter>> counter >>order ;


TUPLE: c-struct
    { name string }
    { order integer } ;

: <c-struct> ( name order -- c-struct )
    c-struct new
        swap >>order
        swap >>name ;


TUPLE: c-union
    { name string }
    { order integer } ;

: <c-union> ( name order -- c-union )
    c-union new
        swap >>order
        swap >>name ;


TUPLE: c-enum
    { name string }
    slots
    { order integer } ;

: <c-enum> ( name order -- c-enum )
    c-enum new
        swap >>order
        swap >>name ;


TUPLE: c-arg
    { name string }
    { type string }
    { parent-order integer }
    { order integer } ;

: <c-arg> ( name type -- c-arg )
    c-arg new
        swap >>type
        swap >>name
        peek-current-form >>parent-order
        clang-state> defs-counter>> counter >>order ;


TUPLE: c-field
    { name string }
    { type string }
    { parent-order integer }
    { order integer } ;

: <c-field> ( name type -- c-field )
    c-field new
        swap >>type
        swap >>name
        peek-current-form >>parent-order
        clang-state> defs-counter>> counter >>order ;


TUPLE: c-typedef
    { type string }
    { name string }
    { order integer } ;

: <c-typedef> ( type name -- c-typedef )
    c-typedef new
        swap >>name
        swap >>type
        clang-state> defs-counter>> counter >>order ;

M: c-function def>out-form
    [
        {
            [ drop "FUNCTION: " ]
            [ return-type>> " " ]
            [ name>> " ( " ]
            [ args>> dup empty? ")\n" " )\n" ? ]
        } cleave
    ] "" append-outputs-as ;

: ignore-typedef? ( typedef -- ? )
    [ type>> ] [ name>> ] bi
    { [ = ] [ [ empty? ] either? ] } 2|| ;

M: c-typedef def>out-form
    dup ignore-typedef? [
        drop ""
    ] [
        [
            {
                [ drop "TYPEDEF: " ]
                [ type>> " " ]
                [ name>> ]
            } cleave
        ] "" append-outputs-as
    ] if ;

ERROR: unknown-child-forms order ;
M: c-field def>out-form
    [
        {
            [ drop "  { " ]
            [ name>> " " ]
            [ type>> " }" ]
        } cleave
    ] "" append-outputs-as ;

: lookup-order ( obj -- order )
    type>> clang-state> c-defs-by-name>> at [ order>> ] ?call -1 or ;

: print-defers ( current-order slots -- )
    [
        tuck lookup-order < [
            print-deferred
        ] [
            drop
        ] if
    ] with each ;

: empty-struct? ( c-struct -- ? )
    order>> clang-state> child-forms>> key? not ;

M: c-struct def>out-form
    dup empty-struct? [
        name>> "C-TYPE: " prepend
    ] [
        [
            {
                [ drop "STRUCT: " ]
                [ name>> "\n" ]
                [
                    order>> dup clang-state> child-forms>> ?at [ drop { } ] unless
                    [ print-defers ]
                    [ nip [ def>out-form ] map "\n" join " ;\n" append ] 2bi
                ]
            } cleave
        ] "" append-outputs-as
    ] if ;

M: c-enum def>out-form
    [
        {
            [ drop "ENUM: " ]
            [ name>> "\n" ]
            [
                order>> dup clang-state> child-forms>> ?at [ drop { } ] unless
                [ print-defers ]
                [ nip [ def>out-form ] map "\n" join " ;\n" append ] 2bi
            ]
        } cleave
    ] "" append-outputs-as ;

M: c-union def>out-form
    [
        {
            [ drop "UNION-STRUCT: " ]
            [ name>> "\n" ]
            [
                order>> dup clang-state> child-forms>> ?at [ drop { } ] unless
                [ print-defers ]
                [ nip [ def>out-form ] map "\n" join " ;\n" append ] 2bi
            ]
        } cleave
    ] "" append-outputs-as ;

M: object def>out-form
    class-of name>> "unknown object: " prepend ;

: set-definition ( named -- )
    [ dup name>> clang-state> c-defs-by-name>> set-at ]
    [ dup order>> clang-state> c-defs-by-order>> set-at ] bi ;

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

DEFER: cursor>c-struct
DEFER: cursor>c-union

:: cursor-type ( cursor -- string )
    cursor clang_getCursorType clang_getTypeSpelling clang-get-cstring

    "const" ?head drop

    [ CHAR: * = ] cut-tail
    [ [ trim-blanks ] dip append ] when*

    dup :> type
    {
        { [ dup "struct " head? ] [
            " " split1-last nip
            clang-state> unnamed-table>> ?at or
        ] }

        ! libclang uses two forms for unnamed union (why!?)
        ! union (unnamed at /Users/erg/factor/elf2.h:39:3)
        ! union (unnamed union at /Users/erg/factor/elf2.h:39:3)
        { [ dup "union " head? ] [
            " " split1-last nip
            clang-state> unnamed-table>> ?at or
        ] }
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
    clang_getCursorSpelling clang-get-cstring "" ?unnamed drop ;

: ?cursor-name ( cursor unnamed-type -- string )
    [ clang_getCursorSpelling clang-get-cstring ] dip ?unnamed drop ;

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

: cursor>c-function ( CXCursor -- )
    [ clang_getCursorResultType cxreturn-type>factor ]
    [ cursor-name ]
    [ cursor>args-info ] tri <c-function> set-definition ;

: cursor>c-typedef ( CXCursor -- )
    [ clang_getTypedefDeclUnderlyingType cxreturn-type>factor ]
    [ cursor-name ] bi <c-typedef> set-definition ;

: cursor>c-field ( CXCursor -- )
    [ cursor-name ] [ cursor-type ] bi <c-field> dup g... gflush push-child-form ;

DEFER: cursor-visitor

: cursor>enum ( CXCursor -- )
    [
        [ cursor-name ] [ cursor-visitor ] bi
        f clang_visitChildren drop
    ] with-new-form <c-enum> set-definition ;

: cursor>c-union ( CXCursor -- )
    [
        "cursor>union start" g...
        peek-current-form g... gflush

        [ "Union" ?cursor-name "name: " gwrite dup g... gflush ] keep
        cursor-visitor f clang_visitChildren drop

        "cursor>union finish" g... gflush
        peek-current-form g... gflush
    ] with-new-form
    <c-union> dup g... gflush set-definition ;

: cursor>c-struct ( CXCursor -- )
    [
        "cursor>c-struct start" g...
        peek-current-form g... gflush

        [ "Struct" ?cursor-name ] keep
        cursor-visitor f clang_visitChildren drop

        "cursor>c-struct finish" g... gflush
        peek-current-form g... gflush
    ] with-new-form
    <c-struct> dup g... gflush set-definition ;

: cursor-visitor ( -- callback )
    [
        2drop
        dup clang_getCursorKind
        dup "cursor-visitor got: " gwrite g... gflush
        {
            { CXCursor_Namespace [ drop CXChildVisit_Recurse ] }
            { CXCursor_FunctionDecl [ cursor>c-function CXChildVisit_Continue ] }
            { CXCursor_TypedefDecl [ cursor>c-typedef CXChildVisit_Continue ] }
            { CXCursor_UnionDecl [ cursor>c-union CXChildVisit_Continue ] }
            { CXCursor_StructDecl [ cursor>c-struct CXChildVisit_Continue ] }
            { CXCursor_EnumDecl [ cursor>enum CXChildVisit_Continue ] }
            { CXCursor_VarDecl [ drop CXChildVisit_Continue ] }

            { CXCursor_FieldDecl [
                cursor>c-field CXChildVisit_Continue
            ] }
            { CXCursor_EnumConstantDecl [
                [
                    [ clang-get-token-spelling ] with-cursor-tokens
                    first
                ] [
                    clang_getEnumConstantDeclUnsignedValue number>string
                ] bi
                <c-field> push-child-form
                CXChildVisit_Continue
            ] }
            [
                "cursor-visitor unhandled: " gwrite dup g... gflush
                2drop CXChildVisit_Recurse
            ]
        } case
    ] CXCursorVisitor
    gflush ;

: with-clang-index ( quot: ( index -- ) -- )
    [ 0 0 clang_createIndex ] dip keep clang_disposeIndex ; inline

: with-clang-translation-unit ( idx source-file command-line-args nargs unsaved-files nunsaved-files options quot: ( tu -- ) -- )
    [ enum>number clang_parseTranslationUnit ] dip
    keep clang_disposeTranslationUnit ; inline

: with-clang-default-translation-unit ( path quot: ( tu path -- ) -- )
    dupd '[
        _ f 0 f 0 CXTranslationUnit_None [
            _ @
        ] with-clang-translation-unit
    ] with-clang-index ; inline

: with-clang-cursor ( path quot: ( tu path cursor -- ) -- )
    dupd '[
        _ f 0 f 0 CXTranslationUnit_None [
            _ over clang_getTranslationUnitCursor @
        ] with-clang-translation-unit
    ] with-clang-index ; inline

! : parse-c-defines ( path -- )
!     [
!         tokenize-path
!         [
!             ! tu void* int
!             cell-bits 8 /i * swap <displaced-alien>
!             clang_getTokenKind
!         ] with { } map-as
!     ] with-clang-default-translation-unit ;

: parse-c-exports ( path -- )
    [
        2nip cursor-visitor f clang_visitChildren drop
    ] with-clang-cursor ;

: write-c-defs ( -- )
    clang-state> c-defs-by-order>>
    sort-keys values
    [ def>out-forms ] each
    clang-state> out-forms>>
    sort-keys values [ print ] each ;

: parse-include ( path -- libclang-state )
    <libclang-state> clang-state [
        normalize-path
        ! reset-c-defs
        {
            ! [ parse-c-defines ]
            [ parse-c-exports ]
        } cleave
        write-c-defs
    ] with-output-global-variable ; inline



! "/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/php/ext/sqlite3/libsqlite/sqlite3.h" parse-include

! "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/include"

! "resource:elf.h" parse-include

![[
"resource:elf.h" parse-include
c-defs-by-order get-global write-c-defs

"resource:elf2.h" parse-include

]]