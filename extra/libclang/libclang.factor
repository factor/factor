! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.enums ascii
classes.struct combinators combinators.smart discord io
io.backend kernel libclang.ffi sequences splitting ;
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
    [ cursor-type ] [ cursor-name ] bi " " glue ;

: cursor>args ( cursor -- args/f )
    dup clang_Cursor_getNumArguments dup -1 = [
        2drop f
    ] [
        <iota> [
            clang_Cursor_getArgument
        ] with { } map-as
    ] if ;

: cxreturn-type>factor ( type -- string )
    dup kind>> dup CXType_Pointer = [
        drop
        clang_getPointeeType
        cxreturn-type>factor "*" append
    ] [
        nip
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
            ! { CXType_Pointer [ "*" ] }
            [ drop "" ]
        } case
    ] if ;

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
            ! [ drop " )" ]
        } cleave
    ] "" append-outputs-as ;

: cursor-visitor ( -- callback )
    [
        2drop
        dup clang_getCursorKind
        ! dup g...
        {
            { CXCursor_FunctionDecl [ function-cursor>string gprint ] }
            ! { CXType_Pointer [ function-cursor>string  ] }
            ! { CXType_Invalid [ drop ] }
            [ 2drop ]
        } case
        ! nl nl nl
        gflush
        CXChildVisit_Recurse
    ] CXCursorVisitor ;

! "resource:vm/factor.hpp" parse-include
! "C:\\Program Files\\LLVM\\include\\clang-c\\index.h"

: clang-get-file-max-range ( CXTranslationUnit path -- CXSourceRange )
    dupd clang_getFile
    [ 0 clang_getLocationForOffset ]
    [ 1000 clang_getLocationForOffset ] 2bi
    clang_getRange ;

: parse-c-defines ( path -- )
    dup '[
        _
        f 0
        f 0
        CXTranslationUnit_None enum>number
        clang_parseTranslationUnit
        [ ]
        [ _ clang-get-file-max-range ] bi
        ! CXToken 
        f void* <ref>
        0 uint <ref>
        [ clang_tokenize ] 2keep
        [ g... ] bi@
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




    ! CXToken *tokens;
    ! unsigned numTokens;
    ! clang_tokenize(unit, range, &tokens, &numTokens);

    ! for (unsigned i = 0; i < numTokens; i++) {
    !     CXTokenKind kind = clang_getTokenKind(tokens[i]);
    !     if (kind == CXToken_Comment) {
    !         continue;
    !     }

    !     CXString spelling = clang_getTokenSpelling(unit, tokens[i]);
    !     const char *text = clang_getCString(spelling);
    !     if (kind == CXToken_Punctuation && strcmp(text, "#") == 0 && i + 1 < numTokens) {
    !         CXString nextSpelling = clang_getTokenSpelling(unit, tokens[i + 1]);
    !         const char *nextText = clang_getCString(nextSpelling);
    !         if (strcmp(nextText, "define") == 0) {
    !             printf("#define directive found: %s %s\n", text, nextText);
    !             i++; // Skip the 'define' token
    !         }
    !         clang_disposeString(nextSpelling);
    !     }
    !     clang_disposeString(spelling);
    ! }

    ! clang_disposeTokens(unit, tokens, numTokens);
