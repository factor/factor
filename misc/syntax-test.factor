#!/usr/bin/env foo

! Comments

    ! Normal comments
    ! More comments

    /* C
    style 
    comments */

    /* comment */
    /* multline ( x -- y )
      2  comment */
     6 /* something else */ 2 +

! Imports

    USING: vocabularies ... ;
    USE: vocabulary
    UNUSE: vocabulary
    IN: vocabulary
    FROM: vocab => words ... ;
    EXCLUDE: vocab => words ... ;
    QUALIFIED: vocab
    QUALIFIED-WITH: vocab word-prefix
    RENAME: word vocab => new-name
    ALIAS: new-word existing-word
    DEFER: word
    FORGET: word
    POSTPONE: word

! Classes

    MIXIN: class
    TUPLE: class slots ... ;
    TUPLE: class < superclass slots ... ;
    BUILTIN: class slots ... ;
    INSTANCE: instance mixin
    SINGLETON: class
    SINGLETONS: words ... ;
    PREDICATE: class < superclass predicate... ;

! Examples

    TUPLE: interval-map { array array read-only } ;
    BUILTIN: string { length array-capacity read-only initial: 0 } aux ;

! Definitions

    : word ( x -- ) drop ;
    :: word ( x -- ) x drop ;
    TYPED: word ( a b: class ... -- x: class y ... ) body ;
    TYPED:: word ( a b: class ... -- x: class y ... ) body ;
    MACRO: word ( inputs... -- ) definition... ) ;
    MACRO:: word ( vars... -- outputs... ) definition... ) ;
    M: class generic (definition) ... ;
    M:: class generic ( vars... -- outputs... ) body... ;
    GENERIC: word ( stack -- effect )
    HOOK: word variable ( stack -- effect )
    GENERIC#: word 1 ( stack -- effect )
    MATH: + ( x y -- z ) foldable flushable
    SLOT: name
    C: <foo> foo

! Private definitions

<PRIVATE

    : word ( x -- ) drop ;
    :: word ( x -- ) x drop ;
    TYPED: word ( a b: class ... -- x: class y ... ) body ;
    TYPED:: word ( a b: class ... -- x: class y ... ) body ;
    MACRO: word ( inputs... -- ) definition... ) ;
    MACRO:: word ( vars... -- outputs... ) definition... ) ;
    M: class generic (definition) ... ;
    M:: class generic ( vars... -- outputs... ) body... ;
    GENERIC: word ( stack -- effect )
    HOOK: word variable ( stack -- effect )
    GENERIC#: word 1 ( stack -- effect )
    MATH: + ( x y -- z ) foldable flushable
    SLOT: name
    C: <foo> foo

PRIVATE>

! Alien

    LIBRARY: name
    TYPEDEF: old new
    ENUM: type words... ;
    ENUM: type < base-type words...
    FUNCTION: return name ( parameters ) ;
    FUNCTION-ALIAS: factor-name return name ( parameters ) ;

! Symbols and literals

    \ foo
    $ foo
    M\ foo bar

    MAIN: word
    CONSTANT: word value
    SYMBOL: word
    SYMBOLS: words ... ;

    C: <foo> foo

! Math

    1 2 +
    3 4 -
    5 6 *
    7 8 /
    32 2^
    10 10^

! Examples

    [ 1 ] unless*
    >boolean
    <wrapper>
    +@
    H{ } assoc-empty?
    5 >bignum
    1 2 pick set-nth
    5 f <array>
    (clone)

! Strings

    ""
    "test"
    SBUF" foo"
    SBUF" hello world "
    "\s"
    "\\foo"
    "\"hello\""
    "\a\b\e\f\n\r\t\s\v\s\0\\\""
    "\x01\xaF\uffffff"

    URL" http://google.com"
    R" asdf"

    """">json""""

! Triple quote strings (old Factor)

    """hello, world"""
    """ hello, world """
    """this is a
    multiline string"""

! Multiline strings

    [=[this is a weird new string]=]

! Containers

    H{ { 1 2 } }
    HS{ 1 2 3 }
    { 4 5 6 }
    V{ "asdf" 5 }
    ${ 1 foo 3 }

! Quotations

    [ 2^ * ]
    '[ _ sqrt ]
    $[ 1 2 + ]

! Tuples

    T{ foo f 1 2 3 }
    T{ foo { a 5 } }

! Symbols are colored wrong:

    : rock ( -- ) \ rock computer play. ;

! SBUF is colored wrong:

    SBUF" " clone swap [ " " append ] [ number>string append ] interleave

! Update to new library words:

    key? and assoc-empty? are not colored
    tail* is not highlighted

! IN poker, unicode characters:

    t

    f

    CHAR: -
    CHAR: a
    CHAR: symbol-for-end-of-transmission
    CHAR: snowman

    { CHAR: a CHAR: S }
    { CHAR: b CHAR: D }
    { CHAR: c CHAR: H }
    { CHAR: d CHAR: C }

! New number literals:

    0xCAFEBABE
    0o432
    0b10101
    1,000
    10,000
    1e10
    -1.5e-5

! Weird numbers

    1,234+56/78
    +1/3
    1+1/3
    -1/3
    -1-1/3
    -1,234-1/34
    1.
    +1.5
    -1.5e30
    1.5e-30
    1,000.1,2
    0xCAFEBABE
    0x1AB4p30
    0b10101
    0o1234567
    NAN: CAFE1234
    NAN: 0

! Not numbers

    1foo
    1.5bar
    +foo
    -bar
    *baz
    qux*
    /i
    (1string)
    ?1+

! Comments in STRUCT: definitions
! STRUCT: features like bitfields, etc.

    STRUCT: foo
    { a int initial: 0 } ! a comment
    { b c-string }
    { c char[4] }
    { d void* }
    { e int bits: 8 }
    ;

! Stack effects

    ( -- )
    ( x -- )
    ( x -- x )
    ( x x -- x )
    ( x x -- x x )

    ( quot: ( a -- b ) -- )
    ( x quot: ( a -- b ) -- y )
    ( ..a quot: ( ..a x -- ..b ) -- ..b )

    ( x n -- (x)n )

    ( m: integer -- n: float )
    ( :integer -- :float )

    ( x -- y )

! Weird stuff:

    key?
    key?thing
    flushablething
    flushable
    <PRIVATEfoo

    "asdf"foo

<< 5 1 + . >> 1

: foo ( x -- y ) foo>> + ; inline

+@
+byte+

pair?
tail?

0.1
,0.1 ! wrong
10,0.1
1.23
.1
-.1
-0.1
-0,1.1
1.
.  ! wrong
-. ! wrong

! Regexp is colored wrong (on Github):

: using-line ( source -- vocabs )
    R/ USING: [^;]* ;/s all-matching-subseqs ?first
    [ { } ] [ " \n" split rest but-last ] if-empty ;
