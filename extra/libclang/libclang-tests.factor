USING: accessors alien.c-types alien.enums assocs continuations
io.backend io.streams.string kernel libclang libclang.ffi locals
math math.parser namespaces sequences sets strings tools.test ;
FROM: namespaces => set ;
IN: libclang.tests

{ t } [
    <libclang-state> clang-state set-global
    {
        { "int8_t *" "char*" }
        { "uint64_t **" "ulonglong**" }
        { "unsigned long long" "ulonglong" }
        { "signed short" "short" }
        { "struct ImportPoint *" "ImportPoint*" }
        { "union ImportValue" "ImportValue" }
        { "_Bool" "bool" }
        { "int (*)(int)" "void*" }
        { "ImportColor" "ImportColor" }
    } [ first2 [ c-type-name>factor ] dip = ] all?
] unit-test

: test-header ( -- path )
    "vocab:libclang/test.h" normalize-path ;

{ t } [ clang_getClangVersion clang-get-cstring empty? not ] unit-test

{ t } [
    { "ImportColor" "ImportPoint" "import_sum" "import_inline" }
    test-header parse-include c-defs-by-name>> keys subset?
] unit-test

{ t } [
    test-header parse-include [ write-c-defs ] with-string-writer
    "{ IMPORT_GREEN 8 }" swap subseq?
] unit-test

{ t } [
    test-header [
        2nip [ nip clang_getTokenKind ] with-cursor-tokens
        [ CXToken_Comment = not ] filter
        dup first CXToken_Keyword = swap
        [ enum>number integer? ] all? and
    ] with-clang-cursor
] unit-test

:: file-token-kinds ( tu path -- kinds )
    tu path tokenize-path :> ( tokens ntokens )
    [ tokens ntokens get-tokens ]
    [ tu tokens ntokens clang_disposeTokens ] finally ;

{ t } [
    test-header [
        2nip [ nip clang_getTokenKind ] with-cursor-tokens
        [ CXToken_Comment = not ] filter
    ] with-clang-cursor
    test-header [ file-token-kinds ] with-clang-default-translation-unit
    ! The full file also has a leading comment, outside the cursor extent.
    [ CXToken_Comment = not ] filter =
] unit-test

[
    "vocab:libclang/does-not-exist.h" normalize-path parse-include
] [ clang-parse-error? ] must-fail-with

[ test-header [ 2drop "parse aborted" throw ] with-clang-default-translation-unit ]
[ "parse aborted" = ] must-fail-with

[ test-header [ 2nip [ 2drop "tokens aborted" throw ] with-cursor-tokens drop ] with-clang-cursor ]
[ "tokens aborted" = ] must-fail-with

SYMBOL: emission-count
TUPLE: counted-definition name order child ;
C: <counted-definition> counted-definition

M: counted-definition def>out-form
    emission-count inc
    dup child>> [ dup def>out-forms def>out-forms ] when*
    name>> ;

{ 12 12 } [
    <libclang-state> clang-state set-global
    0 emission-count set
    12 <iota> f [| child n |
        n number>string n child <counted-definition>
    ] reduce def>out-forms
    emission-count get
    clang-state> out-forms>> assoc-size
] unit-test

{ t t } [
    test-header parse-include
    <libclang-state> clang-state set-global
    [ write-c-defs ] with-string-writer
    "{ IMPORT_GREEN 8 }" swap subseq?
    clang-state> out-forms>> assoc-empty?
] unit-test

{ t } [
    <libclang-state> dup clang-state set-global
    [ f write-c-defs ] [ drop ] recover
    clang-state> eq?
] unit-test
