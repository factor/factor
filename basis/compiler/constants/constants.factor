! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien arrays byte-arrays kernel layouts literals math
quotations sequences strings words ;
IN: compiler.constants

CONSTANT: card-bits 8
CONSTANT: deck-bits 18

: card-mark ( -- n ) 0x40 0x80 bitor ; inline

: slot-offset ( slot tag -- n ) [ bootstrap-cells ] dip - ; inline

: float-offset ( -- n ) 8 float type-number - ; inline
: string-offset ( -- n ) 4 string type-number slot-offset ; inline
: byte-array-offset ( -- n ) 16 byte-array type-number - ; inline
: alien-offset ( -- n ) 4 alien type-number slot-offset ; inline
: tuple-class-offset ( -- n ) 1 tuple type-number slot-offset ; inline
: word-entry-point-offset ( -- n ) 9 \ word type-number slot-offset ; inline
: quot-entry-point-offset ( -- n ) 4 quotation type-number slot-offset ; inline
: array-start-offset ( -- n ) 2 array type-number slot-offset ; inline
: callstack-length-offset ( -- n ) 1 \ callstack type-number slot-offset ; inline
: callstack-top-offset ( -- n ) 2 \ callstack type-number slot-offset ; inline
: context-callstack-top-offset ( -- n ) 0 bootstrap-cells ; inline
: context-callstack-bottom-offset ( -- n ) 1 bootstrap-cells ; inline
: context-datastack-offset ( -- n ) 2 bootstrap-cells ; inline
: context-retainstack-offset ( -- n ) 3 bootstrap-cells ; inline
: context-callstack-save-offset ( -- n ) 4 bootstrap-cells ; inline
: context-callstack-seg-offset ( -- n ) 7 bootstrap-cells ; inline
: segment-start-offset ( -- n ) 0 bootstrap-cells ; inline
: segment-end-offset ( -- n ) 2 bootstrap-cells ; inline

! Offsets in vm struct. Should be kept in sync with:
!   vm/vm.hpp
: vm-context-offset ( -- n )
    0 bootstrap-cells ; inline
: vm-spare-context-offset ( -- n )
    1 bootstrap-cells ; inline
: vm-signal-handler-addr-offset ( -- n )
    8 bootstrap-cells ; inline
: vm-fault-flag-offset ( -- n )
    9 bootstrap-cells ; inline
: vm-special-object-offset ( n -- offset )
    bootstrap-cells 10 bootstrap-cells + ;

CONSTANT: rc-absolute-cell 0
CONSTANT: rc-absolute 1
CONSTANT: rc-relative 2
CONSTANT: rc-absolute-ppc-2/2 3
CONSTANT: rc-absolute-ppc-2 4
CONSTANT: rc-relative-ppc-2-pc 5
CONSTANT: rc-relative-ppc-3-pc 6
CONSTANT: rc-absolute-2 10
CONSTANT: rc-absolute-1 11
CONSTANT: rc-absolute-ppc-2/2/2/2 12
CONSTANT: rc-relative-arm64-branch 13
CONSTANT: rc-relative-arm64-bcond 14
CONSTANT: rc-absolute-arm64-movz 15
CONSTANT: rc-relative-cell 16

CONSTANT: rt-dlsym 0
CONSTANT: rt-entry-point 1
CONSTANT: rt-entry-point-pic 2
CONSTANT: rt-entry-point-pic-tail 3
CONSTANT: rt-here 4
CONSTANT: rt-this 5
CONSTANT: rt-literal 6
CONSTANT: rt-untagged 7
CONSTANT: rt-megamorphic-cache-hits 8
CONSTANT: rt-vm 9
CONSTANT: rt-cards-offset 10
CONSTANT: rt-decks-offset 11
CONSTANT: rt-dlsym-toc 13
CONSTANT: rt-inline-cache-miss 14
CONSTANT: rt-safepoint 15

: rc-absolute? ( n -- ? )
    ${
        $ rc-absolute-ppc-2/2
        $ rc-absolute-cell
        $ rc-absolute
        $ rc-absolute-2
        $ rc-absolute-1
    } member? ;
