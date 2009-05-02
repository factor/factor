! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays byte-arrays definitions generic
hashtables kernel math namespaces parser lexer sequences strings
strings.parser sbufs vectors words words.symbol words.constant
words.alias quotations io assocs splitting classes.tuple
generic.standard generic.hook generic.math generic.parser classes
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

: define-core-syntax ( name quot -- )
    [ dup "syntax" lookup [ ] [ no-word-error ] ?if ] dip
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

    "IN:" [ scan set-in ] define-core-syntax

    "PRIVATE>" [ in get ".private" ?tail drop set-in ] define-core-syntax

    "<PRIVATE" [
        POSTPONE: PRIVATE> in get ".private" append set-in
    ] define-core-syntax

    "USE:" [ scan use+ ] define-core-syntax

    "USING:" [ ";" parse-tokens add-use ] define-core-syntax

    "QUALIFIED:" [ scan dup add-qualified ] define-core-syntax

    "QUALIFIED-WITH:" [ scan scan add-qualified ] define-core-syntax

    "FROM:" [
        scan "=>" expect ";" parse-tokens swap add-words-from
    ] define-core-syntax

    "EXCLUDE:" [
        scan "=>" expect ";" parse-tokens swap add-words-excluding
    ] define-core-syntax

    "RENAME:" [
        scan scan "=>" expect scan add-renamed-word
    ] define-core-syntax

    "HEX:" [ 16 parse-base ] define-core-syntax
    "OCT:" [ 8 parse-base ] define-core-syntax
    "BIN:" [ 2 parse-base ] define-core-syntax

    "f" [ f parsed ] define-core-syntax
    "t" "syntax" lookup define-singleton-class

    "CHAR:" [
        scan {
            { [ dup length 1 = ] [ first ] }
            { [ "\\" ?head ] [ next-escape >string "" assert= ] }
            [ name>char-hook get call( name -- char ) ]
        } cond parsed
    ] define-core-syntax

    "\"" [ parse-string parsed ] define-core-syntax

    "SBUF\"" [
        lexer get skip-blank parse-string >sbuf parsed
    ] define-core-syntax

    "P\"" [
        lexer get skip-blank parse-string <pathname> parsed
    ] define-core-syntax

    "[" [ parse-quotation parsed ] define-core-syntax
    "{" [ \ } [ >array ] parse-literal ] define-core-syntax
    "V{" [ \ } [ >vector ] parse-literal ] define-core-syntax
    "B{" [ \ } [ >byte-array ] parse-literal ] define-core-syntax
    "H{" [ \ } [ >hashtable ] parse-literal ] define-core-syntax
    "T{" [ parse-tuple-literal parsed ] define-core-syntax
    "W{" [ \ } [ first <wrapper> ] parse-literal ] define-core-syntax

    "POSTPONE:" [ scan-word parsed ] define-core-syntax
    "\\" [ scan-word <wrapper> parsed ] define-core-syntax
    "M\\" [ scan-word scan-word method <wrapper> parsed ] define-core-syntax
    "inline" [ word make-inline ] define-core-syntax
    "recursive" [ word make-recursive ] define-core-syntax
    "foldable" [ word make-foldable ] define-core-syntax
    "flushable" [ word make-flushable ] define-core-syntax
    "delimiter" [ word t "delimiter" set-word-prop ] define-core-syntax

    "SYNTAX:" [
        CREATE-WORD parse-definition define-syntax
    ] define-core-syntax

    "SYMBOL:" [
        CREATE-WORD define-symbol
    ] define-core-syntax

    "SYMBOLS:" [
        ";" parse-tokens
        [ create-in dup reset-generic define-symbol ] each
    ] define-core-syntax

    "SINGLETONS:" [
        ";" parse-tokens
        [ create-class-in define-singleton-class ] each
    ] define-core-syntax

    "DEFER:" [
        scan current-vocab create
        [ fake-definition ] [ set-word ] [ [ undefined ] define ] tri
    ] define-core-syntax
    
    "ALIAS:" [
        CREATE-WORD scan-word define-alias
    ] define-core-syntax

    "CONSTANT:" [
        CREATE-WORD scan-object define-constant
    ] define-core-syntax

    ":" [
        (:) define-declared
    ] define-core-syntax

    "GENERIC:" [
        [ simple-combination ] (GENERIC:)
    ] define-core-syntax

    "GENERIC#" [
        [ scan-word <standard-combination> ] (GENERIC:)
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
        CREATE-CLASS parse-definition define-union-class
    ] define-core-syntax

    "INTERSECTION:" [
        CREATE-CLASS parse-definition define-intersection-class
    ] define-core-syntax

    "MIXIN:" [
        CREATE-CLASS define-mixin-class
    ] define-core-syntax

    "INSTANCE:" [
        location [
            scan-word scan-word 2dup add-mixin-instance
            <mixin-instance>
        ] dip remember-definition
    ] define-core-syntax

    "PREDICATE:" [
        CREATE-CLASS
        scan "<" assert=
        scan-word
        parse-definition define-predicate-class
    ] define-core-syntax

    "SINGLETON:" [
        CREATE-CLASS define-singleton-class
    ] define-core-syntax

    "TUPLE:" [
        parse-tuple-definition define-tuple-class
    ] define-core-syntax

    "SLOT:" [
        scan define-protocol-slot
    ] define-core-syntax

    "C:" [
        CREATE-WORD scan-word define-boa-word
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
        ")" parse-effect drop
    ] define-core-syntax

    "((" [
        "))" parse-effect parsed
    ] define-core-syntax

    "MAIN:" [ scan-word in get vocab (>>main) ] define-core-syntax

    "<<" [
        [
            \ >> parse-until >quotation
        ] with-nested-compilation-unit call( -- )
    ] define-core-syntax

    "call-next-method" [
        current-method get [
            literalize parsed
            \ (call-next-method) parsed
        ] [
            not-in-a-method-error
        ] if*
    ] define-core-syntax
    
    "initial:" "syntax" lookup define-symbol
    
    "read-only" "syntax" lookup define-symbol

    "call(" [ \ call-effect parse-call( ] define-core-syntax

    "execute(" [ \ execute-effect parse-call( ] define-core-syntax
] with-compilation-unit
