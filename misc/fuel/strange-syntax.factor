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

! ! Symbol names

! All slashes are symbol constituents.
: hack/slash ( -- x ) 10 ;

: slash\hack ( -- y ) 20 ;

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
