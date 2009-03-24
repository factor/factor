! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces kernel arrays parser ;
IN: compiler.cfg.registers

! Virtual registers, used by CFG and machine IRs
TUPLE: vreg { reg-class read-only } { n read-only } ;
SYMBOL: vreg-counter
: next-vreg ( reg-class -- vreg ) \ vreg-counter counter vreg boa ;

! Stack locations
TUPLE: loc { n read-only } ;

TUPLE: ds-loc < loc ;
C: <ds-loc> ds-loc

TUPLE: rs-loc < loc ;
C: <rs-loc> rs-loc

SYNTAX: V scan-word scan-word vreg boa parsed ;
SYNTAX: D scan-word <ds-loc> parsed ;
SYNTAX: R scan-word <rs-loc> parsed ;
