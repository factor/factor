! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays byte-vectors classes
classes.algebra.private classes.builtin classes.error
classes.intersection classes.maybe classes.mixin classes.parser
classes.predicate classes.singleton classes.tuple
classes.tuple.parser classes.union combinators compiler.units
definitions effects effects.parser fry generic generic.hook
generic.math generic.parser generic.standard hash-sets
hashtables hashtables.identity init io.pathnames kernel lexer
locals.errors locals.parser macros math memoize namespaces
parser quotations sbufs sequences slots source-files splitting
strings strings.parser strings.parser.private vectors vocabs
vocabs.loader vocabs.parser words words.alias words.constant
words.symbol classes.enumeration.private ;
IN: bootstrap.syntax

! These words are defined as a top-level form, instead of with
! defining parsing words, because during stage1 bootstrap, the
! "syntax" vocabulary is copied from the host. When stage1
! bootstrap completes, the host's syntax vocabulary is deleted
! from the target, then this top-level form creates the
! target's "syntax" vocabulary as one of the first things done
! in stage2.

: define-delimiter ( name -- )
    "syntax" lookup-word t "delimiter" set-word-prop ;

: define-core-syntax ( name quot -- )
    [ [ "syntax" lookup-word ] [ no-word-error ] ?unless ] dip
    define-syntax ;

[
    { "]" "}" ";" ">>" } [ define-delimiter ] each

    "PRIMITIVE:" [
        current-vocab name>>
        scan-word scan-effect ensure-primitive
    ] define-core-syntax

    "CS{" [
        "Call stack literals are not supported" throw
    ] define-core-syntax

    "IN:" [ scan-token set-current-vocab ] define-core-syntax

    "<PRIVATE" [ begin-private ] define-core-syntax

    "PRIVATE>" [ end-private ] define-core-syntax

    "REUSE:" [ scan-token reload ] define-core-syntax

    "USE:" [ scan-token use-vocab ] define-core-syntax

    "UNUSE:" [ scan-token unuse-vocab ] define-core-syntax

    "USING:" [ ";" [ use-vocab ] each-token ] define-core-syntax

    "QUALIFIED:" [ scan-token dup add-qualified ] define-core-syntax

    "QUALIFIED-WITH:" [ scan-token scan-token add-qualified ] define-core-syntax

    "FROM:" [
        scan-token "=>" expect ";" parse-tokens add-words-from
    ] define-core-syntax

    "EXCLUDE:" [
        scan-token "=>" expect ";" parse-tokens add-words-excluding
    ] define-core-syntax

    "RENAME:" [
        scan-token scan-token "=>" expect scan-token add-renamed-word
    ] define-core-syntax

    "NAN:" [ 16 scan-base <fp-nan> suffix! ] define-core-syntax

    "f" [ f suffix! ] define-core-syntax

    "CHAR:" [
        lexer get parse-raw [ "token" throw-unexpected-eof ] unless* {
            { [ dup length 1 = ] [ first ] }
            { [ "\\" ?head ] [ next-escape >string "" assert= ] }
            [ name>char-hook get call( name -- char ) ]
        } cond suffix!
    ] define-core-syntax

    "\"" [ parse-string suffix! ] define-core-syntax

    "SBUF\"" [
        lexer get skip-blank parse-string >sbuf suffix!
    ] define-core-syntax

    "P\"" [
        lexer get skip-blank parse-string <pathname> suffix!
    ] define-core-syntax

    "[" [ parse-quotation suffix! ] define-core-syntax
    "{" [ \ } [ >array ] parse-literal ] define-core-syntax
    "V{" [ \ } [ >vector ] parse-literal ] define-core-syntax
    "B{" [ \ } [ >byte-array ] parse-literal ] define-core-syntax
    "BV{" [ \ } [ >byte-vector ] parse-literal ] define-core-syntax
    "H{" [ \ } [ parse-hashtable ] parse-literal ] define-core-syntax
    "IH{" [ \ } [ >identity-hashtable ] parse-literal ] define-core-syntax
    "T{" [ parse-tuple-literal suffix! ] define-core-syntax
    "W{" [ \ } [ first <wrapper> ] parse-literal ] define-core-syntax
    "HS{" [ \ } [ >hash-set ] parse-literal ] define-core-syntax

    "POSTPONE:" [ scan-word suffix! ] define-core-syntax
    "\\" [ scan-word <wrapper> suffix! ] define-core-syntax
    "M\\" [ scan-word scan-word lookup-method <wrapper> suffix! ] define-core-syntax
    "auto-use" [ t auto-use? set-global ] define-core-syntax
    "delimiter" [ last-word t "delimiter" set-word-prop ] define-core-syntax
    "deprecated" [ last-word make-deprecated ] define-core-syntax
    "flushable" [ last-word make-flushable ] define-core-syntax
    "foldable" [ last-word make-foldable ] define-core-syntax
    "inline" [ last-word make-inline ] define-core-syntax
    "recursive" [ last-word make-recursive ] define-core-syntax

    "SYNTAX:" [
        scan-new-word parse-definition define-syntax
    ] define-core-syntax

    "BUILTIN:" [
        scan-word-name
        current-vocab lookup-word
        (parse-tuple-definition)
        2drop builtin-class check-instance drop
    ] define-core-syntax

    "SYMBOL:" [
        scan-new-word define-symbol
    ] define-core-syntax

    "SYMBOLS:" [
        ";" [ create-word-in [ reset-generic ] [ define-symbol ] bi ] each-token
    ] define-core-syntax

    "INITIALIZED-SYMBOL:" [
        scan-new-word [ define-symbol ] [ scan-object [ initialize ] 2curry ] bi append!
    ] define-core-syntax

    "SINGLETONS:" [
        ";" [ create-class-in define-singleton-class ] each-token
    ] define-core-syntax

    "DEFER:" [
        scan-token current-vocab create-word
        [ fake-definition ] [ set-last-word ] [ undefined-def define ] tri
    ] define-core-syntax

    "ALIAS:" [
        scan-new-word scan-word define-alias
    ] define-core-syntax

    "CONSTANT:" [
        scan-new-word scan-object define-constant
    ] define-core-syntax

    ":" [
        (:) define-declared
    ] define-core-syntax

    "GENERIC:" [
        [ simple-combination ] (GENERIC:)
    ] define-core-syntax

    "GENERIC#:" [
        [ scan-number <standard-combination> ] (GENERIC:)
    ] define-core-syntax

    "MATH:" [
        [ math-combination ] (GENERIC:)
    ] define-core-syntax

    "HOOK:" [
        [ scan-word <hook-combination> ] (GENERIC:)
    ] define-core-syntax

    "M:" [
        (M:) define
    ] define-core-syntax

    "UNION:" [
        scan-new-class parse-array-def define-union-class
    ] define-core-syntax

    "INTERSECTION:" [
        scan-new-class parse-array-def define-intersection-class
    ] define-core-syntax

    "MIXIN:" [
        scan-new-class define-mixin-class
    ] define-core-syntax

    "INSTANCE:" [
        location [
            scan-word scan-word 2dup add-mixin-instance
            <mixin-instance>
        ] dip remember-definition
    ] define-core-syntax

    "PREDICATE:" [
        scan-new-class
        "<" expect
        scan-class
        parse-definition define-predicate-class
    ] define-core-syntax

    "SINGLETON:" [
        scan-new-class define-singleton-class
    ] define-core-syntax

    "TUPLE:" [
        parse-tuple-definition define-tuple-class
    ] define-core-syntax

    "ENUMERATION:" [
        scan-new-class parse-enum 
    ] define-core-syntax

    "final" [
        last-word make-final
    ] define-core-syntax

    "SLOT:" [
        scan-token define-protocol-slot
    ] define-core-syntax

    "C:" [
        scan-new-word scan-word define-boa-word
    ] define-core-syntax

    "ERROR:" [
        parse-tuple-definition
        pick save-location
        define-error-class
    ] define-core-syntax

    "FORGET:" [
        scan-object forget
    ] define-core-syntax

    "(" [
        ")" parse-effect suffix!
    ] define-core-syntax

    "MAIN:" [
        scan-word dup \ [ = [
            drop "( main )" <uninterned-word> dup
            parse-quotation ( -- ) define-declared
        ] when dup ( -- ) check-stack-effect
        [ current-vocab main<< ]
        [ current-source-file get [ main<< ] [ drop ] if* ] bi
    ] define-core-syntax

    "<<" [
        [
            \ >> parse-until >quotation
        ] with-nested-compilation-unit call( -- )
    ] define-core-syntax

    "call-next-method" [
        current-method get [
            literalize suffix!
            \ (call-next-method) suffix!
        ] [
            not-in-a-method-error
        ] if*
    ] define-core-syntax

    "maybe{" [
        \ } [ <anonymous-union> <maybe> ] parse-literal
    ] define-core-syntax

    "not{" [
        \ } [ <anonymous-union> <anonymous-complement> ] parse-literal
    ] define-core-syntax

    "predicate{" [
        \ } [ first2 <anonymous-predicate> ] parse-literal
    ] define-core-syntax

    "intersection{" [
         \ } [ <anonymous-intersection> ] parse-literal
    ] define-core-syntax

    "union{" [
        \ } [ <anonymous-union> ] parse-literal
    ] define-core-syntax

    "initial:" "syntax" lookup-word define-symbol

    "read-only" "syntax" lookup-word define-symbol

    "call(" [ \ call-effect parse-call-paren ] define-core-syntax

    "execute(" [ \ execute-effect parse-call-paren ] define-core-syntax

    "<<<<<<<" [ version-control-merge-conflict ] define-core-syntax
    "=======" [ version-control-merge-conflict ] define-core-syntax
    ">>>>>>>" [ version-control-merge-conflict ] define-core-syntax

    "<<<<<<" [ version-control-merge-conflict ] define-core-syntax
    "======" [ version-control-merge-conflict ] define-core-syntax
    ">>>>>>" [ version-control-merge-conflict ] define-core-syntax

    "'[" [
        t in-fry? [ parse-quotation ] with-variable fry append!
    ] define-core-syntax

    "'{" [
        t in-fry? [ \ } parse-until >array ] with-variable fry append!
    ] define-core-syntax

    "'HS{" [
        t in-fry? [ \ } parse-until >array ] with-variable fry
        [ >hash-set ] compose append!
    ] define-core-syntax

    "'H{" [
        t in-fry? [ \ } parse-until >array ] with-variable fry
        [ parse-hashtable ] compose append!
    ] define-core-syntax

    "_" [
        in-fry? get [ \ _ suffix! ] [ not-in-a-fry ] if
    ] define-core-syntax

    "@" [
        in-fry? get [ \ @ suffix! ] [ not-in-a-fry ] if
    ] define-core-syntax

    "MACRO:" [ (:) define-macro ] define-core-syntax

    "MEMO:" [ (:) define-memoized ] define-core-syntax
    "IDENTITY-MEMO:" [ (:) define-identity-memoized ] define-core-syntax

    ":>" [
        in-lambda? get [ :>-outside-lambda-error ] unless
        scan-token parse-def suffix!
    ] define-core-syntax
    "[|" [ parse-lambda append! ] define-core-syntax
    "[let" [ parse-let append! ] define-core-syntax

    "::" [ (::) define-declared ] define-core-syntax
    "M::" [ (M::) define ] define-core-syntax
    "MACRO::" [ (::) define-macro ] define-core-syntax
    "MEMO::" [ (::) define-memoized ] define-core-syntax
    "IDENTITY-MEMO::" [ (::) define-identity-memoized ] define-core-syntax

    "STARTUP-HOOK:" [
        scan-word
        dup \ [ = [ drop parse-quotation ] [ 1quotation ] if
        current-vocab name>> [ add-startup-hook ] 2curry append!
    ] define-core-syntax

    "SHUTDOWN-HOOK:" [
        scan-word
        dup \ [ = [ drop parse-quotation ] [ 1quotation ] if
        current-vocab name>> [ add-shutdown-hook ] 2curry append!
    ] define-core-syntax

    "VOCAB:" [ scan-token >vocab-link suffix! ] define-core-syntax
] with-compilation-unit
