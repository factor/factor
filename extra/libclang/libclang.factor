! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums
alien.strings ascii assocs byte-arrays classes classes.struct
combinators combinators.extras combinators.short-circuit
combinators.smart discord io io.backend io.directories
io.encodings.utf8 io.files.info kernel layouts libc libclang.ffi
make math math.parser multiline namespaces prettyprint sequences
sequences.private sets sorting splitting strings ;
IN: libclang

SYMBOL: clang-state
: clang-state> ( -- clang-state ) clang-state get-global ;

! todo: typedefs
TUPLE: libclang-state
    defs-counter c-defs-by-name c-defs-by-order
    c-forms child-forms
    unnamed-counter unnamed-table
    typedefs
    out-forms-counter out-forms out-forms-by-name
    out-forms-written out-form-names-written ;

: <libclang-state> ( -- state )
    libclang-state new
        0 >>defs-counter
        H{ } clone >>c-defs-by-name
        H{ } clone >>c-defs-by-order
        V{ } clone >>c-forms
        H{ } clone >>child-forms
        0 >>unnamed-counter
        H{ } clone >>unnamed-table
        H{ } clone >>typedefs
        0 >>out-forms-counter
        H{ } clone >>out-forms
        H{ } clone >>out-forms-by-name
        HS{ } clone >>out-forms-written
        HS{ } clone >>out-form-names-written ;

: next-defs-counter ( libclang-state -- n ) [ dup 1 + ] change-defs-counter drop ;
: next-unnamed-counter ( libclang-state -- n ) [ dup 1 + ] change-unnamed-counter drop ;
: next-out-forms-counter ( libclang-state -- n ) [ dup 1 + ] change-out-forms-counter drop ;

GENERIC: def>out-form ( obj -- string )

: out-form-written? ( string -- ? )
    clang-state> out-forms-written>> in? ; inline

: out-form-name-written? ( string -- ? )
    clang-state> out-form-names-written>> in? ; inline

: save-out-form ( string def -- )
    over empty? [
        2drop
    ] [
        over out-form-written? [
        ! dup name>> out-form-name-written? [
            2drop
        ] [
            clang-state>
            {
                [
                    nip
                    [ next-out-forms-counter ]
                    [ out-forms>> set-at ] bi
                ]
                [ nipd [ name>> ] dip out-form-names-written>> adjoin ]
                [ nip out-forms-written>> adjoin ]
                [ [ name>> ] dip out-forms-by-name>> push-at ]
            } 3cleave
        ] if
    ] if ;

! some forms must be defined out of order, e.g. anonymous unions/structs
: def>out-forms ( obj -- )
    [ def>out-form ] keep save-out-form ;

: peek-current-form ( -- n )
    clang-state> c-forms>> ?last ; inline

SLOT: parent-order
SLOT: order

: push-child-form ( form -- )
    ! dup order>> c-defs-by-order get-global set-at ; inline
    dup parent-order>> clang-state> child-forms>> push-at ; inline

: with-new-form ( quot -- n )
    clang-state> [ next-defs-counter ] [ c-forms>> ] bi push
    call
    clang-state> c-forms>> pop ; inline

ERROR: unknown-form name ;
GENERIC: print-deferred ( obj -- )

! foo*** -> foo, todo: other cases?
: factor-type-name ( type -- type' ) [ CHAR: * = ] trim-tail ;

: ?lookup-type ( type -- obj/f )
    factor-type-name
    clang-state> c-defs-by-name>> ?at [ drop f ] unless ;

: lookup-order ( obj -- order/f ) type>> ?lookup-type [ order>> ] ?call -1 or ;

M: object print-deferred
    type>> ?lookup-type [ def>out-forms ] when* ;

: unnamed? ( string -- ? ) "(unnamed" swap subseq? ; inline
: unnamed-exists? ( string -- value/key ? ) clang-state> unnamed-table>> ?at ; inline
: lookup-unnamed ( type string -- type-name )
    unnamed-exists? [
        nip
    ] [
        [ clang-state> next-unnamed-counter number>string append ] dip
        " " split1-last nip
        ! "RECORDING: " gwrite dup g... gflush
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
        clang-state> next-defs-counter >>order ;

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
    parent-order
    { order integer } ;

: <c-arg> ( name type -- c-arg )
    c-arg new
        swap >>type
        swap >>name
        peek-current-form >>parent-order
        clang-state> next-defs-counter >>order ;

TUPLE: c-field
    { name string }
    { type string }
    parent-order
    { order integer } ;

: <c-field> ( name type -- c-field )
    c-field new
        swap >>type
        swap >>name
        peek-current-form >>parent-order
        clang-state> next-defs-counter >>order ;

TUPLE: c-typedef
    { type string }
    { name string }
    { order integer } ;

: <c-typedef> ( type name -- c-typedef )
    c-typedef new
        swap >>name
        swap >>type
        clang-state> next-defs-counter >>order ;

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

: set-typedef ( typedef -- )
    dup ignore-typedef? [
        drop
    ] [
        [ type>> ] [ name>> ] bi clang-state> typedefs>> set-at
    ] if ;

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

: ptr-array>array ( ptr c-type n -- array )
    [ heap-size ] [ <iota> ] bi*
    [
        * swap <displaced-alien>
    ] with with { } map-as ;

:: with-cursor-tokens ( cursor quot: ( tu token -- obj ) -- seq )
    cursor clang_Cursor_getTranslationUnit :> tu
    tu cursor clang_getCursorExtent clang-tokenize :> ( tokens ntokens )
    tu
    tokens CXToken ntokens ptr-array>array
    [ clang_getTokenSpelling clang-get-cstring ] with map
    tu tokens ntokens clang_disposeTokens ; inline

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
    clang_getCursorSpelling clang-get-cstring "Enum" ?unnamed drop ;

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
            clang_getPointeeType cxreturn-type>factor "*" append
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
    [ cursor-name ] bi <c-typedef> [ set-definition ] [ set-typedef ] bi ;

: cursor>c-field ( CXCursor -- )
    [ cursor-name ] [ cursor-type ] bi <c-field> push-child-form ;

DEFER: cursor-visitor

: cursor>enum ( CXCursor -- )
    [
        [ cursor-name ] [ cursor-visitor ] bi
        f clang_visitChildren drop
    ] with-new-form <c-enum> set-definition ;

: cursor>c-union ( CXCursor -- )
    [
        [ "Union" ?cursor-name ] keep
        cursor-visitor f clang_visitChildren drop
    ] with-new-form
    <c-union> set-definition ;

: cursor>c-struct ( CXCursor -- )
    [
        [ "Struct" ?cursor-name ] keep
        cursor-visitor f clang_visitChildren drop
    ] with-new-form
    <c-struct> set-definition ;

: cursor-visitor ( -- callback )
    [
        2drop
        dup clang_getCursorKind
        ! dup "cursor-visitor got: " gwrite g... gflush
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
                    [
                        clang_getTokenSpelling clang-get-cstring
                    ] with-cursor-tokens
                    first
                ] [
                    clang_getEnumConstantDeclUnsignedValue number>string
                ] bi
                <c-field> push-child-form
                CXChildVisit_Continue
            ] }
            { CXCursor_UnexposedDecl [ drop CXChildVisit_Continue ] }
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

: parse-c-exports ( path -- )
    [
        2nip cursor-visitor f clang_visitChildren drop
    ] with-clang-cursor ;

: write-c-defs ( clang-state -- )
    [
        c-defs-by-order>>
        sort-keys values
        [ def>out-forms ] each
    ] [
        [
            [ members [ length ] inv-sort-by ] assoc-map
        ] change-out-forms-by-name
        out-forms>>
        sort-keys values [ print ] each
    ] bi ;

: parse-include ( path -- libclang-state )
    <libclang-state> clang-state [
        normalize-path
        parse-c-exports
    ] with-output-global-variable
    ! dup write-c-defs
    ;

: parse-hpp-files ( path -- assoc )
    ?qualified-directory-files
    [ ".hpp" tail? ] filter
    [ parse-include ] zip-with ;

: parse-h-files ( path -- assoc )
    ?qualified-directory-files
    [ ".h" tail? ] filter
    [ parse-include ] zip-with ;

: parse-cpp-files ( path -- assoc )
    ?qualified-directory-files
    [ ".cpp" tail? ] filter
    [ parse-include ] zip-with ;
