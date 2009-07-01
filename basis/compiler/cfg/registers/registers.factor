! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces kernel arrays parser ;
IN: compiler.cfg.registers

! Virtual registers, used by CFG and machine IRs
TUPLE: vreg { reg-class read-only } { n read-only } ;
SYMBOL: vreg-counter
: next-vreg ( reg-class -- vreg ) \ vreg-counter counter vreg boa ;

! Stack locations -- 'n' is an index starting from the top of the stack
! going down. So 0 is the top of the stack, 1 is what would be the top
! of the stack after a 'drop', and so on.

! ##inc-d and ##inc-r affect locations as follows. Location D 0 before
! an ##inc-d 1 becomes D 1 after ##inc-d 1.
TUPLE: loc { n read-only } ;

TUPLE: ds-loc < loc ;
C: <ds-loc> ds-loc

TUPLE: rs-loc < loc ;
C: <rs-loc> rs-loc

SYNTAX: V scan-word scan-word vreg boa parsed ;
SYNTAX: D scan-word <ds-loc> parsed ;
SYNTAX: R scan-word <rs-loc> parsed ;
