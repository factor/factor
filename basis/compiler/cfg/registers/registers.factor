! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel math namespaces parser sequences ;
IN: compiler.cfg.registers

SYMBOL: vreg-counter

: next-vreg ( -- vreg )
    vreg-counter counter ;

: reset-vreg-counter ( -- )
    0 vreg-counter set-global ;

SYMBOL: representations

ERROR: bad-vreg vreg ;

: rep-of ( vreg -- rep )
    representations get ?at [ bad-vreg ] unless ;

: set-rep-of ( rep vreg -- )
    representations get set-at ;

: next-vreg-rep ( rep -- vreg )
    next-vreg [ set-rep-of ] keep ;

TUPLE: loc { n integer } ;

TUPLE: ds-loc < loc ;
C: <ds-loc> ds-loc

TUPLE: rs-loc < loc ;
C: <rs-loc> rs-loc

SYNTAX: D: scan-number <ds-loc> suffix! ;
SYNTAX: R: scan-number <rs-loc> suffix! ;
