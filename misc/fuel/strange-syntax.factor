USING: accessors ;
IN: strange

TUPLE: oh\no { and/again initial: "meh" } ;

! FUEL Syntax Demo
!
! The purpose of this file is to test that corner cases are
! highlighted correctly by FUEL. So if you change something in the
! syntax highlighting and it breaks, things will be badly hightlighted
! here.
USING: alien.syntax kernel math ;
IN: strange-syntax

TUPLE: a-tuple slot1 slot2 { slot3 integer } ;
  TUPLE: second-one ;

    USING: tools.test ;


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
    CHAR: \n ;

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

! ! Containers
V{ 1 2 3 } drop
HS{ 9 8 3 } drop
