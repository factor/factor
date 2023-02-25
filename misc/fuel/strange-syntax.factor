USING: accessors alien.c-types alien.syntax classes.struct
colors kernel literals logging math ;
IN: strange

! FUEL Syntax Demo
!
! The purpose of this file is to test that corner cases are
! highlighted correctly by FUEL. So if you change something in the
! syntax highlighting and it breaks, things will be badly hightlighted
! here.
USING: alien.syntax kernel math ;
IN: strange-syntax

TUPLE: a-tuple slot1 slot2 { slot3 integer } { slot4 initial: "hi" } ;
  TUPLE: second-one ;

    USING: tools.test ;

TUPLE: initial-array { slot2 initial: { 123 } } slot3 ;

! ! Strings
"containing \"escapes" drop

! ! Symbol names

TUPLE: tup
    ko
    get\it
    { eh\ integer }
    { oh'ho } ;

! All slashes are symbol constituents.
: hack/slash ( t -- x ) ko>> ;

: um ( x y -- ) get\it<< ;

: slash\hack ( m -- y )
    get\it>> dup >>get\it ;

: very-weird[33] ( -- ) ;

LOG: what NOTICE

TUPLE: oh\no { and/again initial: "meh" } ;

! As are quotes
: don't-do-that ( x -- y ) ;

! Double quotes aren't right yet.
! : do-"that" ( x -- y ) ;

! ! C-TYPE
C-TYPE: cairo_snurface_t

! ! CHAR
: stuff-with-chars ( -- K \n )
    CHAR: K
    CHAR: \n
    CHAR: \"        ! <- \" should be highlighted
    drop ;

! ! MAIN
: majn ( -- ) ;

MAIN: majn

! ! SLOT
SLOT: komba

! ! SYNTAX
<<
SYNTAX: ID-SYNTAX ;
>>

ID-SYNTAX ID-SYNTAX

! ! Numbers
{ -55 -0x10 100,00 1,000,000 0x2000,0000 0b01 } drop
{ -0x100_000 100_00 1_000_000 0x2000_0000 0b0_1 } drop

! ! Containers
V{ 1 2 3 } drop
HS{ 9 8 3 } drop

flags{ 10 20 } drop

! ! Alien functions
STRUCT: timeval
    { sec long }
    { usec long } ;

FUNCTION: int futimes ( int id,
                        timeval[2] times,
                        int x,
                        int y )
FUNCTION: int booyah ( int x )
FUNCTION-ALIAS: test int bah ( int* ah, int[] eh )

COLOR: #ffffff COLOR: green NAN: 1234 CHAR: m ALIEN: 93
2drop 2drop drop

PRIMITIVE: one ( a -- b )
PRIMITIVE: two ( c -- d )

: `word ( -- ) ;
: word ( -- ) ; ! this isn't strange, just for contrast with the above
