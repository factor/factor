! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays bit-arrays bit-vectors byte-arrays
byte-vectors definitions generic hashtables kernel math
namespaces parser sequences strings sbufs vectors words
quotations io assocs splitting tuples generic.standard
generic.math classes io.files vocabs float-arrays float-vectors
classes.union classes.mixin classes.predicate compiler.units
combinators debugger ;
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
    >r "syntax" lookup dup r> define t "parsing" set-word-prop ;

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

    "HEX:" [ 16 parse-base ] define-syntax
    "OCT:" [ 8 parse-base ] define-syntax
    "BIN:" [ 2 parse-base ] define-syntax

    "f" [ f parsed ] define-syntax
    "t" "syntax" lookup define-symbol

    "CHAR:" [
        scan {
            { [ dup length 1 = ] [ first ] }
            { [ "\\" ?head ] [ next-escape drop ] }
            { [ t ] [ name>char-hook get call ] }
        } cond parsed
    ] define-syntax

    "\"" [ parse-string parsed ] define-syntax

    "SBUF\"" [
        lexer get skip-blank parse-string >sbuf parsed
    ] define-syntax

    "P\"" [
        lexer get skip-blank parse-string <pathname> parsed
    ] define-syntax

    "[" [ \ ] [ >quotation ] parse-literal ] define-syntax
    "{" [ \ } [ >array ] parse-literal ] define-syntax
    "V{" [ \ } [ >vector ] parse-literal ] define-syntax
    "B{" [ \ } [ >byte-array ] parse-literal ] define-syntax
    "BV{" [ \ } [ >byte-vector ] parse-literal ] define-syntax
    "?{" [ \ } [ >bit-array ] parse-literal ] define-syntax
    "?V{" [ \ } [ >bit-vector ] parse-literal ] define-syntax
    "F{" [ \ } [ >float-array ] parse-literal ] define-syntax
    "FV{" [ \ } [ >float-vector ] parse-literal ] define-syntax
    "H{" [ \ } [ >hashtable ] parse-literal ] define-syntax
    "T{" [ \ } [ >tuple ] parse-literal ] define-syntax
    "W{" [ \ } [ first <wrapper> ] parse-literal ] define-syntax

    "POSTPONE:" [ scan-word parsed ] define-syntax
    "\\" [ scan-word literalize parsed ] define-syntax
    "inline" [ word make-inline ] define-syntax
    "foldable" [ word make-foldable ] define-syntax
    "flushable" [ word make-flushable ] define-syntax
    "delimiter" [ word t "delimiter" set-word-prop ] define-syntax
    "parsing" [ word t "parsing" set-word-prop ] define-syntax

    "SYMBOL:" [
        CREATE-WORD define-symbol
    ] define-syntax

    "DEFER:" [
        scan in get create
        dup old-definitions get first delete-at
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

    "MIXIN:" [
        CREATE-CLASS define-mixin-class
    ] define-syntax

    "INSTANCE:" [
        location >r
        scan-word scan-word 2dup add-mixin-instance
        <mixin-instance> r> remember-definition
    ] define-syntax

    "PREDICATE:" [
        CREATE-CLASS
        scan "<" assert=
        scan-word
        parse-definition define-predicate-class
    ] define-syntax

    "TUPLE:" [
        parse-tuple-definition define-tuple-class
    ] define-syntax

    "C:" [
        CREATE-WORD
        scan-word dup check-tuple
        [ construct-boa ] curry define-inline
    ] define-syntax

    "ERROR:" [
        parse-tuple-definition
        pick save-location
        define-error-class
    ] define-syntax

    "FORGET:" [
        scan-word
        dup parsing? [ V{ } clone swap execute first ] when
        forget
    ] define-syntax

    "(" [
        parse-effect word
        [ swap "declared-effect" set-word-prop ] [ drop ] if*
    ] define-syntax

    "MAIN:" [ scan-word in get vocab set-vocab-main ] define-syntax

    "<<" [
        [ \ >> parse-until >quotation ] with-compilation-unit
        call
    ] define-syntax
] with-compilation-unit
