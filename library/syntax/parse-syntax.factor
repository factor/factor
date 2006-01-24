! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Bootstrapping trick; see doc/bootstrap.txt.
IN: !syntax
USING: alien arrays errors generic hashtables kernel lists math
namespaces parser sequences strings syntax vectors
words ;

: ( CHAR: ) ch-search until ; parsing
: ! until-eol ; parsing
: #! until-eol ; parsing
: IN: scan set-in ; parsing
: USE: scan use+ ; parsing
: USING: string-mode on [ string-mode off add-use ] f ; parsing
: (BASE) scan swap base> swons ;
: HEX: 16 (BASE) ; parsing
: OCT: 8 (BASE) ; parsing
: BIN: 2 (BASE) ; parsing
SYMBOL: t
: f f swons ; parsing
: CHAR: 0 scan next-char nip swons ; parsing
: " parse-string swons ; parsing
: SBUF" skip-blank parse-string >sbuf swons ; parsing
: [ f ; parsing
: ] reverse swons ; parsing
: [[ f ; parsing
: ]] first2 swons swons ; parsing
: ; reverse swap call ; parsing
: } POSTPONE: ; swons ; parsing
: { [ >array ] [ ] ; parsing
: V{ [ >vector ] [ ] ; parsing
: H{ [ alist>hash ] [ ] ; parsing
: C{ [ first2 rect> ] [ ] ; parsing
: T{ [ >tuple ] [ ] ; parsing
: W{ [ first <wrapper> ] [ ] ; parsing
: POSTPONE: scan-word swons ; parsing
: \ scan-word literalize swons ; parsing
: parsing word t "parsing" set-word-prop ; parsing
: inline word  t "inline" set-word-prop ; parsing
: flushable ( not implemented ) ; parsing
: foldable word t "foldable" set-word-prop ; parsing
: SYMBOL: CREATE dup reset-generic define-symbol ; parsing
DEFER: PRIMITIVE: parsing
: DEFER: CREATE dup reset-generic drop ; parsing
: : CREATE dup reset-generic [ define-compound ] [ ] ; parsing
: GENERIC: CREATE dup reset-word define-generic ; parsing
: G: CREATE dup reset-word [ define-generic* ] [ ] ; parsing
: M: scan-word scan-word [ -rot define-method ] [ ] ; parsing

: UNION: ( -- class predicate definition )
    CREATE dup intern-symbol dup predicate-word
    [ dupd unit "predicate" set-word-prop ] keep
    [ define-union ] [ ] ; parsing

: PREDICATE: ( -- class predicate definition )
    scan-word CREATE dup intern-symbol
    dup rot "superclass" set-word-prop dup predicate-word
    [ define-predicate-class ] [ ] ; parsing

: TUPLE:
    scan string-mode on [ string-mode off define-tuple ] f ;
    parsing

: C:
    scan-word [ create-constructor ] keep
    [ define-constructor ] [ ] ; parsing

: FORGET: scan use get hash [ forget ] when* ; parsing
