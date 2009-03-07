! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays byte-arrays definitions generic
hashtables kernel math namespaces parser lexer sequences strings
strings.parser sbufs vectors words words.symbol words.constant
words.alias quotations io assocs splitting classes.tuple
generic.standard generic.math generic.parser classes
io.pathnames vocabs vocabs.parser classes.parser classes.union
classes.intersection classes.mixin classes.predicate
classes.singleton classes.tuple.parser compiler.units
combinators effects.parser slots ;
IN: bootstrap.syntax

! These words are defined as a top-level form, instead of with
! defining parsing words, because during stage1 bootstrap, the
! "syntax" vocabulary is copied from the host. When stage1
! bootstrap completes, the host's syntax vocabulary is deleted
! from the target, then this top-level form creates the
! target's "syntax" vocabulary as one of the first things done
! in stage2.

: define-delimiter ( name -- )
    "syntax" lookup t "delimiter" set-word-prop ;

: define-syntax ( name quot -- )
    [ dup "syntax" lookup [ dup ] [ no-word-error ] ?if ] dip
    define make-parsing ;

[
    { "]" "}" ";" ">>" } [ define-delimiter ] each

    "PRIMITIVE:" [
        "Primitive definition is not supported" throw
    ] define-syntax

    "CS{" [
        "Call stack literals are not supported" throw
    ] define-syntax

    "!" [ lexer get next-line ] define-syntax

    "#!" [ POSTPONE: ! ] define-syntax

    "IN:" [ scan set-in ] define-syntax

    "PRIVATE>" [ in get ".private" ?tail drop set-in ] define-syntax

    "<PRIVATE" [
        POSTPONE: PRIVATE> in get ".private" append set-in
    ] define-syntax

    "USE:" [ scan use+ ] define-syntax

    "USING:" [ ";" parse-tokens add-use ] define-syntax

    "QUALIFIED:" [ scan dup add-qualified ] define-syntax

    "QUALIFIED-WITH:" [ scan scan add-qualified ] define-syntax

    "FROM:" [
        scan "=>" expect ";" parse-tokens swap add-words-from
    ] define-syntax

    "EXCLUDE:" [
        scan "=>" expect ";" parse-tokens swap add-words-excluding
    ] define-syntax

    "RENAME:" [
        scan scan "=>" expect scan add-renamed-word
    ] define-syntax

    "HEX:" [ 16 parse-base ] define-syntax
    "OCT:" [ 8 parse-base ] define-syntax
    "BIN:" [ 2 parse-base ] define-syntax

    "f" [ f parsed ] define-syntax
    "t" "syntax" lookup define-singleton-class

    "CHAR:" [
        scan {
            { [ dup length 1 = ] [ first ] }
            { [ "\\" ?head ] [ next-escape >string "" assert= ] }
            [ name>char-hook get call ]
        } cond parsed
    ] define-syntax

    "\"" [ parse-string parsed ] define-syntax

    "SBUF\"" [
        lexer get skip-blank parse-string >sbuf parsed
    ] define-syntax

    "P\"" [
        lexer get skip-blank parse-string <pathname> parsed
    ] define-syntax

    "[" [ parse-quotation parsed ] define-syntax
    "{" [ \ } [ >array ] parse-literal ] define-syntax
    "V{" [ \ } [ >vector ] parse-literal ] define-syntax
    "B{" [ \ } [ >byte-array ] parse-literal ] define-syntax
    "H{" [ \ } [ >hashtable ] parse-literal ] define-syntax
    "T{" [ parse-tuple-literal parsed ] define-syntax
    "W{" [ \ } [ first <wrapper> ] parse-literal ] define-syntax

    "POSTPONE:" [ scan-word parsed ] define-syntax
    "\\" [ scan-word <wrapper> parsed ] define-syntax
    "inline" [ word make-inline ] define-syntax
    "recursive" [ word make-recursive ] define-syntax
    "foldable" [ word make-foldable ] define-syntax
    "flushable" [ word make-flushable ] define-syntax
    "delimiter" [ word t "delimiter" set-word-prop ] define-syntax
    "parsing" [ word make-parsing ] define-syntax

    "SYMBOL:" [
        CREATE-WORD define-symbol
    ] define-syntax

    "SYMBOLS:" [
        ";" parse-tokens
        [ create-in dup reset-generic define-symbol ] each
    ] define-syntax

    "SINGLETONS:" [
        ";" parse-tokens
        [ create-class-in define-singleton-class ] each
    ] define-syntax
    
    "ALIAS:" [
        CREATE-WORD scan-word define-alias
    ] define-syntax

    "CONSTANT:" [
        CREATE scan-object define-constant
    ] define-syntax

    "DEFER:" [
        scan current-vocab create
        dup old-definitions get [ delete-at ] with each
        set-word
    ] define-syntax

    ":" [
        (:) define
    ] define-syntax

    "GENERIC:" [
        CREATE-GENERIC define-simple-generic
    ] define-syntax

    "GENERIC#" [
        CREATE-GENERIC
        scan-word <standard-combination> define-generic
    ] define-syntax

    "MATH:" [
        CREATE-GENERIC
        T{ math-combination } define-generic
    ] define-syntax

    "HOOK:" [
        CREATE-GENERIC scan-word
        <hook-combination> define-generic
    ] define-syntax

    "M:" [
        (M:) define
    ] define-syntax

    "UNION:" [
        CREATE-CLASS parse-definition define-union-class
    ] define-syntax

    "INTERSECTION:" [
        CREATE-CLASS parse-definition define-intersection-class
    ] define-syntax

    "MIXIN:" [
        CREATE-CLASS define-mixin-class
    ] define-syntax

    "INSTANCE:" [
        location [
            scan-word scan-word 2dup add-mixin-instance
            <mixin-instance>
        ] dip remember-definition
    ] define-syntax

    "PREDICATE:" [
        CREATE-CLASS
        scan "<" assert=
        scan-word
        parse-definition define-predicate-class
    ] define-syntax

    "SINGLETON:" [
        CREATE-CLASS define-singleton-class
    ] define-syntax

    "TUPLE:" [
        parse-tuple-definition define-tuple-class
    ] define-syntax

    "SLOT:" [
        scan define-protocol-slot
    ] define-syntax

    "C:" [
        CREATE-WORD scan-word define-boa-word
    ] define-syntax

    "ERROR:" [
        parse-tuple-definition
        pick save-location
        define-error-class
    ] define-syntax

    "FORGET:" [
        scan-object forget
    ] define-syntax

    "(" [
        ")" parse-effect
        word dup [ set-stack-effect ] [ 2drop ] if
    ] define-syntax

    "((" [
        "))" parse-effect parsed
    ] define-syntax

    "MAIN:" [ scan-word in get vocab (>>main) ] define-syntax

    "<<" [
        [
            \ >> parse-until >quotation
        ] with-nested-compilation-unit call
    ] define-syntax

    "call-next-method" [
        current-method get [
            literalize parsed
            \ (call-next-method) parsed
        ] [
            not-in-a-method-error
        ] if*
    ] define-syntax
    
    "initial:" "syntax" lookup define-symbol
    
    "read-only" "syntax" lookup define-symbol
] with-compilation-unit
