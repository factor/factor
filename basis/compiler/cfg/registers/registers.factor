! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces kernel arrays
parser prettyprint.backend prettyprint.sections ;
IN: compiler.cfg.registers

! Virtual registers, used by CFG and machine IRs
TUPLE: vreg reg-class n ;
SYMBOL: vreg-counter
: next-vreg ( reg-class -- vreg ) \ vreg-counter counter vreg boa ;

! Stack locations
TUPLE: loc n ;

TUPLE: ds-loc < loc ;
C: <ds-loc> ds-loc

TUPLE: rs-loc < loc ;
C: <rs-loc> ds-loc

! Prettyprinting
: V scan-word scan-word vreg boa parsed ; parsing

M: vreg pprint*
    <block
    \ V pprint-word [ reg-class>> pprint* ] [ n>> pprint* ] bi
    block> ;

: pprint-loc ( loc word -- ) <block pprint-word n>> pprint* block> ;

: D scan-word <ds-loc> parsed ; parsing

M: ds-loc pprint* \ D pprint-loc ;

: R scan-word <rs-loc> parsed ; parsing

M: rs-loc pprint* \ R pprint-loc ;
