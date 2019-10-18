! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

! We define these words in !syntax with ! prefixes to avoid
! clashing with the host parsing words when we are building the
! target image. The end of boot-stage1.factor renames the
! !syntax vocab to syntax, and removes the ! prefix from each
! word name.
IN: !syntax
USING: alien arrays bit-arrays byte-arrays definitions errors
generic hashtables kernel math modules namespaces parser
sequences strings sbufs vectors words quotations io assocs ;

: !delimiter word t "delimiter" set-word-prop ; parsing
: !! lexer get next-line ; parsing
: !#! POSTPONE: ! ; parsing
: !IN: scan set-in ; parsing
: !USE: scan use+ ; parsing
: !USING: ";" parse-tokens add-use ; parsing
: !HEX: 16 parse-base ; parsing
: !OCT: 8 parse-base ; parsing
: !BIN: 2 parse-base ; parsing
SYMBOL: !t
: !f f parsed ; parsing
: !CHAR: 0 scan next-char nip parsed ; parsing
: !" parse-string parsed ; parsing
: !SBUF" lexer get skip-blank parse-string >sbuf parsed ; parsing
: !P" lexer get skip-blank parse-string <pathname> parsed ; parsing
DEFER: !] delimiter
DEFER: !} delimiter
DEFER: !; delimiter
: ![ \ !] [ >quotation ] parse-literal ; parsing
: !{ \ !} [ >array ] parse-literal ; parsing
: !V{ \ !} [ >vector ] parse-literal ; parsing
: !B{ \ !} [ >byte-array ] parse-literal ; parsing
: !?{ \ !} [ >bit-array ] parse-literal ; parsing
: !H{ \ !} [ >hashtable ] parse-literal ; parsing
: !C{ \ !} [ first2 rect> ] parse-literal ; parsing
: !T{ \ !} [ >tuple ] parse-literal ; parsing
: !W{ \ !} [ first <wrapper> ] parse-literal ; parsing
: !POSTPONE: scan-word parsed ; parsing
: !\ scan-word literalize parsed ; parsing
: !parsing word t "parsing" set-word-prop ; parsing
: !inline word  t "inline" set-word-prop ; parsing
: !foldable word t "foldable" set-word-prop ; parsing
: !SYMBOL: CREATE dup reset-generic define-symbol ; parsing
DEFER: !PRIMITIVE: parsing
: !DEFER: CREATE drop ; parsing

: !:
    CREATE dup reset-generic parse-definition define-compound ;
    parsing

: !GENERIC:
    CREATE dup reset-word
    define-simple-generic ; parsing

: !HOOK:
    CREATE dup reset-word scan-word
    [ hook-combination ] curry
    define-generic ; parsing

: !G:
    CREATE dup reset-word parse-definition define-generic ;
    parsing

: !M:
    f set-word
    scan-word scan-word location
    parse-definition <method> -rot define-method ; parsing

: !UNION: CREATE parse-definition define-union-class ; parsing

: !PREDICATE:
    scan-word CREATE parse-definition define-predicate-class ;
    parsing

: !TUPLE:
    CREATE ";" parse-tokens define-tuple-class ; parsing

: !C:
    scan-word dup check-tuple
    [ create-constructor dup save-location dup set-word ] keep
    parse-definition define-constructor ; parsing

: !FORGET: scan use get assoc-stack forget ; parsing

: !PROVIDE: scan location \ ; parse-until provide ; parsing

: !REQUIRES:
    ";" parse-tokens [ [ require ] each ] no-parse-hook ;
    parsing

: !MAIN:
    scan module parse-definition swap set-module-main ; parsing

: !(
    parse-effect word [
        swap "declared-effect" set-word-prop
    ] [
        drop
    ] if* ; parsing

SYMBOL: !+files+
SYMBOL: !+tests+
SYMBOL: !+help+
SYMBOL: !+directory+
