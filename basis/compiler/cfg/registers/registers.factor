! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math namespaces parser sequences ;
IN: compiler.cfg.registers

! Virtual registers, used by CFG and machine IRs, are just integers
SYMBOL: vreg-counter

: next-vreg ( -- vreg )
    vreg-counter counter ;

SYMBOL: representations

ERROR: bad-vreg vreg ;

: rep-of ( vreg -- rep )
    representations get ?at [ bad-vreg ] unless ;

: set-rep-of ( rep vreg -- )
    representations get set-at ;

: next-vreg-rep ( rep -- vreg )
    next-vreg [ set-rep-of ] keep ;

! ##inc-d and ##inc-r affect locations as follows. Location D 0 before
! an ##inc-d 1 becomes D 1 after ##inc-d 1.
TUPLE: loc { n integer read-only } ;

TUPLE: ds-loc < loc ;
C: <ds-loc> ds-loc

TUPLE: rs-loc < loc ;
C: <rs-loc> rs-loc

SYNTAX: D scan-number <ds-loc> suffix! ;
SYNTAX: R scan-number <rs-loc> suffix! ;
