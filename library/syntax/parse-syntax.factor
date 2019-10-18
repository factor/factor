! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

! We define these words in !syntax with ! prefixes to avoid
! clashing with the host parsing words when we are building the
! target image. The end of boot-stage1.factor renames the
! !syntax vocab to syntax, and removes the ! prefix from each
! word name.
IN: !syntax
USING: alien arrays compiler errors generic hashtables kernel
math modules namespaces parser sequences strings vectors words ;

: !(
    CHAR: ) column [
        line-text get index* dup -1 =
        [ "Unterminated (" throw ] when 1+
    ] change ; parsing

: !! line-text get length column set ; parsing
: !#! POSTPONE: ! ; parsing
: !IN: scan set-in ; parsing
: !USE: scan use+ ; parsing
: !USING: string-mode on [ string-mode off add-use ] f ; parsing
: !(BASE) scan swap base> parsed ;
: !HEX: 16 (BASE) ; parsing
: !OCT: 8 (BASE) ; parsing
: !BIN: 2 (BASE) ; parsing
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
: !DEFER: CREATE reset-generic ; parsing
: !: CREATE dup reset-generic [ define-compound ] f ; parsing
: !GENERIC: CREATE dup reset-word define-generic ; parsing
: !G: CREATE dup reset-word [ define-generic* ] f ; parsing
: !M: scan-word scan-word [ -rot define-method ] f ; parsing

: !UNION: ( -- class predicate definition )
    CREATE dup intern-symbol dup predicate-word
    [ dupd unit "predicate" set-word-prop ] keep
    [ define-union ] f ; parsing

: !PREDICATE: ( -- class predicate definition )
    scan-word CREATE dup intern-symbol
    dup rot "superclass" set-word-prop dup predicate-word
    [ define-predicate-class ] f ; parsing

: !TUPLE:
    scan string-mode on [ string-mode off define-tuple ] f ;
    parsing

: !C:
    scan-word [ create-constructor ] keep
    [ define-constructor ] f ; parsing

: !FORGET: scan use get hash-stack [ forget ] when* ; parsing

: !PROVIDE:
    scan [ { { } { } } append first2 provide ] f ; parsing

: !REQUIRES:
    string-mode on
    [ string-mode off [ (require) ] each ] f ; parsing
