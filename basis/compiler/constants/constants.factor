! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel layouts system strings words quotations byte-arrays
alien arrays literals sequences ;
IN: compiler.constants

! These constants must match vm/memory.h
CONSTANT: card-bits 8
CONSTANT: deck-bits 18
: card-mark ( -- n ) HEX: 40 HEX: 80 bitor ; inline

! These constants must match vm/layouts.h
: slot-offset ( slot tag -- n ) [ bootstrap-cells ] dip - ; inline

: float-offset ( -- n ) 8 float type-number - ; inline
: string-offset ( -- n ) 4 string type-number slot-offset ; inline
: string-aux-offset ( -- n ) 2 string type-number slot-offset ; inline
: profile-count-offset ( -- n ) 8 \ word type-number slot-offset ; inline
: byte-array-offset ( -- n ) 16 byte-array type-number - ; inline
: alien-offset ( -- n ) 4 alien type-number slot-offset ; inline
: underlying-alien-offset ( -- n ) 1 alien type-number slot-offset ; inline
: tuple-class-offset ( -- n ) 1 tuple type-number slot-offset ; inline
: word-entry-point-offset ( -- n ) 10 \ word type-number slot-offset ; inline
: quot-entry-point-offset ( -- n ) 4 quotation type-number slot-offset ; inline
: word-code-offset ( -- n ) 11 \ word type-number slot-offset ; inline
: array-start-offset ( -- n ) 2 array type-number slot-offset ; inline
: compiled-header-size ( -- n ) 4 bootstrap-cells ; inline
: callstack-length-offset ( -- n ) 1 \ callstack type-number slot-offset ; inline
: callstack-top-offset ( -- n ) 2 \ callstack type-number slot-offset ; inline
: vm-context-offset ( -- n ) 0 bootstrap-cells ; inline
: vm-spare-context-offset ( -- n ) 1 bootstrap-cells ; inline
: context-callstack-top-offset ( -- n ) 0 bootstrap-cells ; inline
: context-callstack-bottom-offset ( -- n ) 1 bootstrap-cells ; inline
: context-datastack-offset ( -- n ) 2 bootstrap-cells ; inline
: context-retainstack-offset ( -- n ) 3 bootstrap-cells ; inline
: context-callstack-save-offset ( -- n ) 4 bootstrap-cells ; inline
: context-callstack-seg-offset ( -- n ) 7 bootstrap-cells ; inline
: segment-start-offset ( -- n ) 0 bootstrap-cells ; inline
: segment-size-offset ( -- n ) 1 bootstrap-cells ; inline
: segment-end-offset ( -- n ) 2 bootstrap-cells ; inline

! Relocation classes
CONSTANT: rc-absolute-cell 0
CONSTANT: rc-absolute 1
CONSTANT: rc-relative 2
CONSTANT: rc-absolute-ppc-2/2 3
CONSTANT: rc-absolute-ppc-2 4
CONSTANT: rc-relative-ppc-2 5
CONSTANT: rc-relative-ppc-3 6
CONSTANT: rc-relative-arm-3 7
CONSTANT: rc-indirect-arm 8
CONSTANT: rc-indirect-arm-pc 9
CONSTANT: rc-absolute-2 10
CONSTANT: rc-absolute-1 11

! Relocation types
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
CONSTANT: rt-exception-handler 12
CONSTANT: rt-float 13

: rc-absolute? ( n -- ? )
    ${
        $ rc-absolute-ppc-2/2
        $ rc-absolute-cell
        $ rc-absolute
        $ rc-absolute-2
        $ rc-absolute-1
    } member? ;
