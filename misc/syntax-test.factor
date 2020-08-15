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
    SLOT: name

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
    : word error drop ;
    :: word ( x -- ) x drop ;
    TYPED: word ( a b: class ... -- x: class y ... ) body ;
    TYPED:: word ( a b: class ... -- x: class y ... ) body ;
    MACRO: word ( inputs... -- ) definition... ) ;
    MACRO:: word ( vars... -- outputs... ) definition... ) ;
    M: object explain drop "an object" print ;
    M: class generic definition... ;
    M:: class generic ( vars... -- outputs... ) body... ;
    M:: class generic error body... ;
    GENERIC: word ( stack -- effect )
    GENERIC: word
        ( stack -- effect )
    GENERIC: word
( stack -- effect )
    GENERIC: word ! comment
        ( stack -- effect )
    GENERIC: word drop ! 3rd token wrong
    GENERIC: word ! next line wrong
        drop
    GENERIC: word
drop ! wrong
    HOOK: word variable ( stack -- effect )
    GENERIC#: word 1 ( stack -- effect )
    GENERIC#: ! comment
        word 1 ( stack -- effect )
    GENERIC#: word 1 ( stack -- effect ) drop ! last token other
    GENERIC#: word ! 2 should GENERIC# stack effect error
        1 2 ( stack -- effect )
    GENERIC#: word ! 2nd eff. should be independent of GENERIC#,
        1 ! and 2 & 3 shouldn't GENERIC# highlight
        ( stack -- effect ) ( independent -- effect ) 2 3
    GENERIC#: word 1 ! comment
        drop ! wrong
    MATH: + ( x y -- z ) foldable flushable
    C: <foo> foo
    CONSTRUCTOR: <circle> circle ( radius -- obj ) ;
    CONSTRUCTOR: <circle> circle ( radius -- obj ) definition...  ;

! Private definitions

<PRIVATE

    : word ( x -- ) drop ;
    :: word ( x -- ) x drop ;
    TYPED: word ( a b: class ... -- x: class y ... ) body ;
    TYPED:: word ( a b: class ... -- x: class y ... ) body ;
    MACRO: word ( inputs... -- ) definition... ) ;
    MACRO:: word ( vars... -- outputs... ) definition... ) ;
    M: class generic definition... ;
    M:: class generic ( vars... -- outputs... ) body... ;
    GENERIC: word ( stack -- effect )
    HOOK: word variable ( stack -- effect )
    GENERIC#: word 1 ( stack -- effect )
    MATH: + ( x y -- z ) foldable flushable
    C: <foo> foo
    CONSTRUCTOR: <circle> circle ( radius -- obj ) ;
    CONSTRUCTOR: <circle> circle ( radius -- obj ) definition...  ;

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
    sbuf"foo"
    sbuf"hello world "
    "\s"
    "\\foo"
    "\"hello\""
    "\a\b\e\f\n\r\t\s\v\s\0\\\""
    "\x01\xaF\uffffff"

    url"http://google.com"
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

    sbuf"" clone swap [ " " append ] [ number>string append ] interleave

! Update to new library words:

    key? and assoc-empty? are not colored
    tail* is not highlighted

! IN poker, unicode characters:

    t

    f

    char: -
    char: a
    char: symbol-for-end-of-transmission
    char: snowman

    { char: a char: S }
    { char: b char: D }
    { char: c char: H }
    { char: d char: C }

! Bin

    0b10101
    0B10101

! Oct

    0o432
    0O1234567
    0o1234567
    0o7

! Hex

    0xCAFEBABE
    0XCAFEBABE
    0x1AB4p30

! Dec

    1,000
    10,000

! Float

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
    nan: CAFE1234 0,. ! third token wrong
    0,. ! wrong, next line also wrong
    0,.
    nan: ! ff 0xff comment
        xCAFE1234 ! wrong
        ff ! shouldn't match as a hex number
    nan: 0
    drop
    nan: !
        ! a 1 comment 1
        f

    nan:
f,
    nan: ALKSJDflKJ ! XXX: should error

! Not numbers

    ,0.1
    .
    -.
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

    ( p:
boolean -- q: boolean )
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
10,0.1
1.23
.1
-.1
-0.1
-0,1.1
1.

! Numeral comma separator parsing (!: wrong, ~: other):
  ! int
  0 00 0,0 +0,0 -0,,0
  /* ! */ ,0 ,00 0,, 00,, +,0 -,,0 +0, -0,, /* ~ */ , +, -,,

  ! float
  0,0e0 0e0,0 0,0e0,0 +0,0e+0,0 -0,0e-0,0
  /* ~ */ e e, ,e ,e, +e -e +e, -e,
  /* ~ */ +e -e +,e -,e +e+, -e-, +,e-,, -,,e+,
  /* ~ */ +e -e +,e -,e +e+, -e-, +,e-,, -,,e+,
  /* ! */ e0, -e,0 ,0e, 0,e, +,e0 -,e-0 0,e0 +0,0e+ -0,0e-,, 0e+ -0e-
  /* ! */ +0e+0, -0e-,,0

  ! float
  0,0. .0,0 /* ! */ 0,. .,0 ,.0 0., ,0. .0,
  +0,0.0 -0,0.0,0
  0,0.0,0e0 0,0.0,0e0,0
  0,0.0,0e+0,0 0,0.0,0e-0,0

  ! ratio
  /* ~ */ / /. +/ -/ ,/ /, 0/ /0
  0/1 1/1 1/1. 1/0. 0/0. /* ! */ 0/0 1/0 1./1
  1/2 +1/2 -1/2 +2/2 /* ! */ 1/+2 1/-2 1/+0 +2/+2
  +1+1/2 -0-1/2 /* ! */ +1+2/2 +1+1/2. +0-1/2 -0+1/2

! Regexp is colored wrong (on Github):

: using-line ( source -- vocabs )
    R/ USING: [^;]* ;/s all-matching-subseqs ?first
    [ { } ] [ " \n" split rest but-last ] if-empty ;
