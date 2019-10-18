! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Bootstrapping trick; see doc/bootstrap.txt.
IN: !syntax
USING: alien errors generic hashtables kernel lists math
namespaces parser sequences strings syntax vectors
words ;

: parsing ( -- )
    #! Mark the most recently defined word to execute at parse
    #! time, rather than run time. The word can use 'scan' to
    #! read ahead in the input stream.
    word t "parsing" set-word-prop ; parsing

: inline ( -- )
    #! Mark the last word to be inlined.
    word  t "inline" set-word-prop ; parsing

: flushable ( -- )
    #! Declare that a word may be removed if the value it
    #! computes is unused.
    word  t "flushable" set-word-prop ; parsing

: foldable ( -- )
    #! Declare a word as safe for compile-time evaluation.
    #! Foldable implies flushable, since we can first fold to
    #! a constant then flush the constant.
    word
    dup t "foldable" set-word-prop
    t "flushable" set-word-prop ; parsing

! The variable "in-definition" is set inside a : ... ;.
! ( and #! then add "stack-effect" and "documentation"
! properties to the current word if it is set.

! Booleans

: t t swons ; parsing

: f f swons ; parsing

! Lists
: [ f ; parsing
: ] reverse swons ; parsing

! Conses (whose cdr might not be a list)
: [[ f ; parsing
: ]] first2 swons swons ; parsing

! Vectors
: { f ; parsing
: } reverse >vector swons ; parsing

! Hashtables
: {{ f ; parsing
: }} alist>hash swons ; parsing

! Do not execute parsing word
: POSTPONE: ( -- ) scan-word swons ; parsing

! Word definitions
: :
    #! Begin a word definition. Word name follows.
    CREATE dup reset-generic [ define-compound ]
    [ ] "in-definition" on ; parsing

: ;
    #! End a word definition.
    "in-definition" off reverse swap call ; parsing

! Symbols
: SYMBOL:
    #! A symbol is a word that pushes itself when executed.
    CREATE dup reset-generic define-symbol ; parsing

: \
    #! Word literals: \ foo
    scan-word literalize swons ; parsing

! Long wrapper syntax. Only used in the rare case that another
! wrapper is being wrapped.
: W[ [ ] ; parsing
: ]W first <wrapper> swons ; parsing

! Vocabularies
: PRIMITIVE:
    #! This is just for show. All flash no substance.
    "You cannot define primitives in Factor" throw ; parsing

: DEFER:
    #! Create a word with no definition. Used for mutually
    #! recursive words.
    CREATE dup reset-generic drop ; parsing

: FORGET:
    #! Followed by a word name. The word is removed from its
    #! vocabulary. Note that specifying an undefined word is a
    #! no-op.
    scan "use" get search [ forget ] when* ; parsing

: USE:
    #! Add vocabulary to search path.
    scan use+ ; parsing

: USING:
    #! A list of vocabularies terminated with ;
    string-mode on
    [ string-mode off [ use+ ] each ]
    f ; parsing

: IN:
    #! Set vocabulary for new definitions.
    scan dup use+ "in" set ; parsing

! Char literal
: CHAR: ( -- ) 0 scan next-char drop swons ; parsing

! String literal
: " parse-string swons ; parsing

: SBUF" skip-blank parse-string >sbuf swons ; parsing

! Comments
: (
    #! Stack comment.
    CHAR: ) until parsed-stack-effect ; parsing

: !
    #! EOL comment.
    until-eol drop ; parsing

: #!
    #! Documentation comment.
    until-eol parsed-documentation ; parsing

! Complex numbers
: #{ f ; parsing
: }# dup second swap first rect> swons ; parsing

! Reading integers in other bases
: (BASE) ( base -- )
    #! Reads an integer in a specific base.
    scan swap base> swons ;

: HEX: 16 (BASE) ; parsing
: DEC: 10 (BASE) ; parsing
: OCT: 8 (BASE) ; parsing
: BIN: 2 (BASE) ; parsing
