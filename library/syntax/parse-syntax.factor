! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

! We define these words in !syntax with ! prefixes to avoid
! clashing with the host parsing words when we are building the
! target image. The end of boot-stage1.factor renames the
! !syntax vocab to syntax, and removes the ! prefix from each
! word name.
IN: !syntax
USING: alien arrays definitions errors generic
hashtables kernel math modules namespaces parser sequences
strings vectors words ;

: !! line-text get length column set ; parsing
: !#! POSTPONE: ! ; parsing
: !IN: scan set-in ; parsing
: !USE: scan use+ ; parsing
: !USING: string-mode on [ string-mode off add-use ] f ; parsing
: !HEX: 16 parse-base ; parsing
: !OCT: 8 parse-base ; parsing
: !BIN: 2 parse-base ; parsing
SYMBOL: !t
: !f f parsed ; parsing
: !CHAR: 0 scan next-char nip parsed ; parsing
: !" parse-string parsed ; parsing
: !SBUF" skip-blank parse-string >sbuf parsed ; parsing
: ![ f ; parsing
: !] >quotation parsed ; parsing
: !; >quotation swap call ; parsing
: !} swap call parsed ; parsing
: !{ [ >array ] f ; parsing
: !V{ [ >vector ] f ; parsing
: !H{ [ alist>hash ] f ; parsing
: !C{ [ first2 rect> ] f ; parsing
: !T{ [ >tuple ] f ; parsing
: !W{ [ first <wrapper> ] f ; parsing
: !POSTPONE: scan-word parsed ; parsing
: !\ scan-word literalize parsed ; parsing
: !parsing word t "parsing" set-word-prop ; parsing
: !inline word  t "inline" set-word-prop ; parsing
: !foldable word t "foldable" set-word-prop ; parsing
: !SYMBOL: CREATE dup reset-generic define-symbol ; parsing

DEFER: !PRIMITIVE: parsing
: !DEFER: CREATE drop ; parsing
: !: CREATE dup reset-generic [ define-compound ] f ; parsing
: !GENERIC: CREATE dup reset-word define-generic ; parsing
: !G: CREATE dup reset-word [ define-generic* ] f ; parsing
: !M:
    f set-word
    scan-word scan-word
    [ location <method> -rot define-method ] f ; parsing

: !UNION:
    CREATE dup intern-symbol dup predicate-word
    [ dupd unit "predicate" set-word-prop ] keep
    [ define-union ] f ; parsing

: !PREDICATE:
    scan-word CREATE dup intern-symbol
    dup rot "superclass" set-word-prop dup predicate-word
    [ define-predicate-class ] f ; parsing

: !TUPLE:
    scan string-mode on [ string-mode off define-tuple ] f ;
    parsing

: !C:
    scan-word
    [ create-constructor dup reset-generic dup set-word ] keep
    [ define-constructor ] f ; parsing

: !FORGET: scan use get hash-stack [ forget ] when* ; parsing

: !PROVIDE:
    scan [ alist>hash provide ] f ; parsing

: !REQUIRES:
    string-mode on [
        string-mode off
        [ [ require ] each ] no-parse-hook
    ] f ; parsing

: !MAIN:
    scan [ swap module set-module-main ] f ; parsing

: !(
    parse-effect word [
        swap "declared-effect" set-word-prop
    ] [
        drop
    ] if* ; parsing

SYMBOL: !+files+
SYMBOL: !+tests+
SYMBOL: !+help+
