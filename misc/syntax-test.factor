#!/usr/bin/env foo

! Comments

    ! Normal comments ( -- x )
    ! More comments

    ! TODO: something
    ! XXX: blah

    /* C
    style 
    comments */

    /* comment */
    /* multline ( x -- y )
      2  comment */
     6 /* something else */ 2 +

    ![[this is a weird new string]]
    ![=[this is a weird new string]=]
    ![==[this is a weird new string]==]
    ![===[this is a weird new string]===]
    ![====[this is a weird new string]====]
    ![=====[this is a weird new string]=====]
    ![======[this is a weird new string]======]

! Imports

    USING: foo ! asdf
    bar baz
    ! something
    qux ;

    USE: ! fasdf
    foo

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
    TUPLE: foo a b c d e f g h i j ;
    TUPLE: foo < object { x initial: 0 } ;
    TUPLE: foo < object { x fixnum initial: 0 } ;
    TUPLE: foo < fixnum { x read-only } ;
    TUPLE: class < superclass slots ... ;
    BUILTIN: class slots ... ;
    ERROR: class a b c { x fixnum initial: 12 } ;
    INSTANCE: instance mixin
    SINGLETON: class
    SINGLETONS: words ... ;
    PREDICATE: class < superclass predicate... ;

! Examples

    TUPLE: interval-map { array array read-only } ;
    TUPLE: foo a b c ;
    TUPLE: foo < bar d e f ;
    BUILTIN: string { length array-capacity read-only initial: 0 } aux ;

! Definitions

    : word ( x -- y ) ! foo ;
    : foo ( x -- y ) 1 + ;
    1 2 + ;

    : word error drop ;
    : word error drop ;
    :: word ( x -- ) x drop ;
    TYPED: word ( a b: class ... -- x: class y ... ) body ;
    TYPED: word ( a b: class ... -- x: class y ... ) body ;
    TYPED:: word ( a b: class ... -- x: class y ... ) body ;
    MACRO: word ( inputs... -- ) definition... ;
    MACRO:: word ( vars... -- outputs... ) definition... ;
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
        drop ;
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
        ( stack -- effect ) ( independent -- effect ) 2 3 ;
    GENERIC#: word 1 ! comment
        drop ! wrong
    MATH: + ( x y -- z ) foldable flushable
    C: <foo> foo
    CONSTRUCTOR: <circle> circle ( radius -- obj ) ;
    CONSTRUCTOR: <circle> circle ( radius -- obj ) definition...  ;
    PRIMITIVE: word-code ( word -- start end )

! Private definitions

<PRIVATE

    : word ( x -- ) drop ;
    :: word ( x -- ) x drop ;
    TYPED: word ( a b: class ... -- x: class y ... ) body ;
    TYPED:: word ( a b: class ... -- x: class y ... ) body ;
    MACRO: word ( inputs... -- ) definition... ;
    MACRO:: word ( vars... -- outputs... ) definition... ;
    M: class generic definition... ;
    M:: class generic ( vars... -- outputs... ) body... ;
    GENERIC: word ( stack -- effect )
    HOOK: word variable ( stack -- effect )
    GENERIC#: word 1 ( stack -- effect )
    MATH: + ( x y -- z ) foldable flushable
    C: <foo> foo
    CONSTRUCTOR: <circle> circle ( radius -- obj ) ;
    CONSTRUCTOR: <circle> circle ( radius -- obj ) definition...  ;
    PRIMITIVE: word-code ( word -- start end )

PRIVATE>

! Syntax

    SYNTAX: URL" parse-string >url suffix! ;

! Alien

    ALIEN: foo
    LIBRARY: name
    TYPEDEF: old new
    ENUM: type words... ;
    ENUM: type < base-type words... ;
    FUNCTION: return name ( parameters ) ;
    FUNCTION-ALIAS: factor-name return name ( parameters ) ;

{ ALIEN: 1234 } [ ALIEN: 1234 [ { alien } declare void* <ref> ] compile-call void* deref ] unit-test
{ ALIEN: 1234 } [ ALIEN: 1234 [ { c-ptr } declare void* <ref> ] compile-call void* deref ] unit-test
{ f } [ f [ { POSTPONE: f } declare void* <ref> ] compile-call void* deref ] unit-test

! Symbols and literals

    \ foo
    $ foo
    M\ foo bar

    MAIN: word
    CONSTANT: word value
    SYMBOL: word
    SYMBOLS: words ... ;

    COLOR: red
    COLOR: #336699

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
    [ [ { } ] ?{ } ]
    H{ ?{ { } } } assoc-empty?
    ?{ t t f } nth
    5 >bignum
    1 2 pick set-nth
    5 f <array>
    (clone)

    [| a b | ]
    [let [let { } ] ]

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
    "\0123\148"

    URL" http://google.com"
    R" asdf"

    """>json"""

    "{ 1 2 3 }"

    [[{ 1 2 3 }]]

! Triple quote strings (old Factor)

    """hello, world"""
    """ hello, world """
    """this is a
    multiline string"""

! Multiline strings

    [[this is a weird new string]]
    [=[this is a weird new string]=]
    [==[this is a weird new string]==]
    [===[this is a weird new string]===]
    [====[this is a weird new string]====]
    [=====[this is a weird new string]=====]
    [======[this is a weird new string]======]

    HEREDOC: END
    foo
END

    HEREDOC: foo bar baz
    foo
foo bar baz

    STRING: foo
asdf\f
;

    drop
! Containers

    H{ { 1 2 } }
    HS{ 1 2 3 }
    { 4 5 6 }
    V{ "asdf" 5 }
    ${ 1 foo 3 }
    ?{ t t f f t }

! Quotations

    [ 2^ * ]
    '[ _ sqrt ]
    '[ _ @ ]
    $[ 1 2 + ]
    [let ]
    [| | ]

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
    CHAR: ☃

    { CHAR: a CHAR: S }
    { CHAR: b CHAR: D }
    { CHAR: c CHAR: H }
    { CHAR: d CHAR: C }

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
    NAN: CAFE1234 0,. ! third token wrong
    0,. ! wrong, next line also wrong
    0,.
    NAN: ! ff 0xff comment
        xCAFE1234 ! wrong
        ff ! shouldn't match as a hex number
    NAN: 0
    drop
    NAN: !
        ! a 1 comment 1
        f

    NAN:
f,
    NAN: ALKSJDflKJ ! XXX: should error

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

    ( p: ! inline comment
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
    [[asdf]]foo
    "asdf"foo
    foo"asdf"foo
    foo"asdf"

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

R/ foo/
R/ foo/s

: using-line ( source -- vocabs )
    R/ USING: [^;]* ;/s all-matching-subseqs ?first
    [ { } ] [ " \n" split rest but-last ] if-empty ;
