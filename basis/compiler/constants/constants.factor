! Copyright (C) 2008, 2009 Slava Pestov.
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
: word-xt-offset ( -- n ) 10 \ word type-number slot-offset ; inline
: quot-xt-offset ( -- n ) 4 quotation type-number slot-offset ; inline
: word-code-offset ( -- n ) 11 \ word type-number slot-offset ; inline
: array-start-offset ( -- n ) 2 array type-number slot-offset ; inline
: compiled-header-size ( -- n ) 4 bootstrap-cells ; inline

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

! Relocation types
CONSTANT: rt-primitive 0
CONSTANT: rt-dlsym 1
CONSTANT: rt-dispatch 2
CONSTANT: rt-xt 3
CONSTANT: rt-xt-pic 4
CONSTANT: rt-xt-pic-tail 5
CONSTANT: rt-here 6
CONSTANT: rt-this 7
CONSTANT: rt-literal 8
CONSTANT: rt-context 9
CONSTANT: rt-untagged 10
CONSTANT: rt-megamorphic-cache-hits 11
CONSTANT: rt-vm 12
CONSTANT: rt-cards-offset 13
CONSTANT: rt-decks-offset 14

: rc-absolute? ( n -- ? )
    ${ rc-absolute-ppc-2/2 rc-absolute-cell rc-absolute } member? ;
