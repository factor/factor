! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces kernel math parser assocs sequences ;
IN: compiler.cfg.registers

! Virtual registers, used by CFG and machine IRs, are just integers
SYMBOL: vreg-counter

: next-vreg ( -- vreg )
    ! This word cannot be called AFTER representation selection has run;
    ! use next-vreg-rep in that case
    \ vreg-counter counter ;

SYMBOL: representations

ERROR: bad-vreg vreg ;

: rep-of ( vreg -- rep )
    ! This word cannot be called BEFORE representation selection has run;
    ! use any-rep for ##copy instructions and so on
    representations get ?at [ bad-vreg ] unless ;

: set-rep-of ( rep vreg -- )
    representations get set-at ;

: next-vreg-rep ( rep -- vreg )
    ! This word cannot be called BEFORE representation selection has run;
    ! use next-vreg in that case
    next-vreg [ set-rep-of ] keep ;

! Stack locations -- 'n' is an index starting from the top of the stack
! going down. So 0 is the top of the stack, 1 is what would be the top
! of the stack after a 'drop', and so on.

! ##inc-d and ##inc-r affect locations as follows. Location D 0 before
! an ##inc-d 1 becomes D 1 after ##inc-d 1.
TUPLE: loc { n integer read-only } ;

TUPLE: ds-loc < loc ;
C: <ds-loc> ds-loc

TUPLE: rs-loc < loc ;
C: <rs-loc> rs-loc

SYNTAX: D scan-number <ds-loc> suffix! ;
SYNTAX: R scan-number <rs-loc> suffix! ;
