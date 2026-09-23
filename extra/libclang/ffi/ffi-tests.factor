USING: accessors alien alien.accessors alien.c-types alien.data
alien.enums alien.libraries alien.libraries.finder arrays assocs
classes.struct continuations io.backend io.directories io.pathnames
kernel layouts libclang libclang.ffi locals math math.parser
namespaces sequences splitting system tools.test vocabs words ;
IN: libclang.ffi.tests

SYMBOL: test-cursors

: libclang-major-version ( -- n )
    clang_getClangVersion clang-get-cstring
    "version " split1 nip "." split1 drop string>number ;

libclang-major-version 21 >= [
    { t } [
        "libclang.ffi" vocab-words [ name>> "clang_" head? ] filter
        [ name>> "clang" dlsym? >boolean ] all?
    ] unit-test
] when

{ t t } [
    [
        current-directory get latest-libclang "clang" find-library =
        "llvm-9/lib" make-directories
        "llvm-9/lib/libclang.so" touch-file
        "llvm-18/lib" make-directories
        current-directory get latest-libclang
        "llvm-9/lib/libclang.so" absolute-path =
    ] with-test-directory
] unit-test

SYMBOL: visited-fields

: field-visitor ( -- callback )
    [
        drop cursor-name visited-fields get-global push CXVisit_Continue
    ] CXFieldVisitor ;

: test-visitor ( -- callback )
    [
        2drop dup cursor-name test-cursors get-global set-at
        CXChildVisit_Recurse
    ] CXCursorVisitor ;

:: with-test-cursors ( quot: ( cursors -- ) -- )
    H{ } clone test-cursors set-global
    "vocab:libclang/ffi/test.hpp" normalize-path [
        2nip test-visitor [ f clang_visitChildren drop ] with-callback
        test-cursors get-global quot call
    ] with-clang-cursor ; inline

{ -1 -1 -1 4294967297 4294967297 } [
    [| cursors |
        "scalar" cursors at clang_getCursorType clang_getArraySize
        "incomplete_array" cursors at clang_getCursorType clang_getArraySize
        "ordinary" cursors at clang_Cursor_getNumTemplateArguments
        "specialized" cursors at 0 clang_Cursor_getTemplateArgumentValue
        "specialized" cursors at 0 clang_Cursor_getTemplateArgumentUnsignedValue
    ] with-test-cursors
] unit-test

{ 70 } [
    [ "ordinary" swap at 0 clang_getOverloadedDecl clang_getCursorKind enum>number ]
    with-test-cursors
] unit-test

{ t } [
    [
        "Named" swap at clang_Cursor_getCXXManglings
        [ Count>> 0 > ] [ clang_disposeStringSet ] bi
    ] with-test-cursors
] unit-test

{ 0 } [
    [ "ordinary" swap at clang_Cursor_getObjCDeclQualifiers ] with-test-cursors
] unit-test

{ t 7 } [
    <CXIndexOptions>
        1 >>ExcludeDeclarationsFromPCH
        1 >>DisplayDiagnostics
        1 >>StorePreamblesInMemory
    [ Size>> CXIndexOptions heap-size = ]
    [ >c-ptr os windows? 8 6 ? alien-unsigned-2 ] bi
] unit-test

{ t } [
    <CXIndexOptions> clang_createIndexWithOptions
    [ >boolean ] [ clang_disposeIndex ] bi
] unit-test

{ CXError_Success t } [
    [| index |
        f void* <ref> :> out
        index "vocab:libclang/ffi/test.hpp" normalize-path
        f 0 f 0 0 out clang_parseTranslationUnit2
        out void* deref
        [ >boolean ] [ clang_disposeTranslationUnit ] bi
    ] with-clang-index
] unit-test

{ t } [
    "vocab:libclang/ffi/test.hpp" normalize-path [
        drop clang_getCXTUResourceUsage
        [ numEntries>> 0 > ] [ clang_disposeCXTUResourceUsage ] bi
    ] with-clang-default-translation-unit
] unit-test

{ t } [
    "vocab:libclang/ffi/test.hpp" normalize-path [
        drop clang_getTranslationUnitTargetInfo
        [ clang_TargetInfo_getPointerWidth cell-bits = ]
        [ clang_TargetInfo_dispose ] bi
    ] with-clang-default-translation-unit
] unit-test

{ 4 -2 1 } [
    [| cursors |
        "scalar" cursors at clang_getCursorType clang_Type_getSizeOf
        "incomplete_array" cursors at clang_getCursorType clang_Type_getSizeOf
        "ordinary" cursors at clang_getCursorType clang_getNumArgTypes
    ] with-test-cursors
] unit-test

{ { "first" "second" } } [
    V{ } clone visited-fields set-global
    [
        "Fields" swap at clang_getCursorType
        field-visitor [ f clang_Type_visitFields drop ] with-callback
        visited-fields get-global >array
    ] with-test-cursors
] unit-test
