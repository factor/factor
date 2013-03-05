! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays byte-vectors
classes.algebra.private classes.intersection classes.maybe
classes.mixin classes.parser classes.predicate
classes.singleton classes.tuple classes.tuple.parser
classes.union combinators compiler.units definitions
effects.parser generic generic.hook generic.math generic.parser
generic.standard hash-sets hashtables io.pathnames kernel lexer
math namespaces parser quotations sbufs sequences slots
source-files splitting strings strings.parser vectors
vocabs.parser words words.alias words.constant words.symbol ;
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
    [ dup "syntax" lookup-word [ ] [ no-word-error ] ?if ] dip
    define-syntax ;

[
    { "]" "}" ";" ">>" } [ define-delimiter ] each

    "PRIMITIVE:" [
        "Primitive definition is not supported" throw
    ] define-core-syntax

    "CS{" [
        "Call stack literals are not supported" throw
    ] define-core-syntax

    "!" [ lexer get next-line ] define-core-syntax

    "#!" [ POSTPONE: ! ] define-core-syntax

    "IN:" [ scan-token set-current-vocab ] define-core-syntax

    "<PRIVATE" [ begin-private ] define-core-syntax

    "PRIVATE>" [ end-private ] define-core-syntax

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
        scan-token {
            { [ dup length 1 = ] [ first ] }
            { [ "\\" ?head ] [ next-escape >string "" assert= ] }
            [ name>char-hook get call( name -- char ) ]
        } cond suffix!
    ] define-core-syntax

    "\"" [ parse-multiline-string suffix! ] define-core-syntax

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
    "T{" [ parse-tuple-literal suffix! ] define-core-syntax
    "W{" [ \ } [ first <wrapper> ] parse-literal ] define-core-syntax
    "HS{" [ \ } [ >hash-set ] parse-literal ] define-core-syntax

    "POSTPONE:" [ scan-word suffix! ] define-core-syntax
    "\\" [ scan-word <wrapper> suffix! ] define-core-syntax
    "M\\" [ scan-word scan-word lookup-method <wrapper> suffix! ] define-core-syntax
    "inline" [ word make-inline ] define-core-syntax
    "recursive" [ word make-recursive ] define-core-syntax
    "foldable" [ word make-foldable ] define-core-syntax
    "flushable" [ word make-flushable ] define-core-syntax
    "delimiter" [ word t "delimiter" set-word-prop ] define-core-syntax
    "deprecated" [ word make-deprecated ] define-core-syntax

    "SYNTAX:" [
        scan-new-word parse-definition define-syntax
    ] define-core-syntax

    "SYMBOL:" [
        scan-new-word define-symbol
    ] define-core-syntax

    "SYMBOLS:" [
        ";" [ create-in [ reset-generic ] [ define-symbol ] bi ] each-token
    ] define-core-syntax

    "SINGLETONS:" [
        ";" [ create-class-in define-singleton-class ] each-token
    ] define-core-syntax

    "DEFER:" [
        scan-token current-vocab create
        [ fake-definition ] [ set-word ] [ undefined-def define ] tri
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

    "GENERIC#" [
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
        scan-new-class parse-definition define-union-class
    ] define-core-syntax

    "INTERSECTION:" [
        scan-new-class parse-definition define-intersection-class
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

    "final" [
        word make-final
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
        scan-word
        [ current-vocab main<< ]
        [ file get [ main<< ] [ drop ] if* ] bi
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

    "intersection{" [
         \ } [ <anonymous-intersection> ] parse-literal
    ] define-core-syntax

    "union{" [
        \ } [ <anonymous-union> ] parse-literal
    ] define-core-syntax

    "initial:" "syntax" lookup-word define-symbol

    "read-only" "syntax" lookup-word define-symbol

    "call(" [ \ call-effect parse-call( ] define-core-syntax

    "execute(" [ \ execute-effect parse-call( ] define-core-syntax

    "<<<<<<<" [ version-control-merge-conflict ] define-core-syntax
    "=======" [ version-control-merge-conflict ] define-core-syntax
    ">>>>>>>" [ version-control-merge-conflict ] define-core-syntax

    "<<<<<<" [ version-control-merge-conflict ] define-core-syntax
    "======" [ version-control-merge-conflict ] define-core-syntax
    ">>>>>>" [ version-control-merge-conflict ] define-core-syntax
] with-compilation-unit
