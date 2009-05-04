! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel layouts system strings words quotations byte-arrays
alien arrays ;
IN: compiler.constants

! These constants must match vm/memory.h
CONSTANT: card-bits 8
CONSTANT: deck-bits 18
: card-mark ( -- n ) HEX: 40 HEX: 80 bitor ; inline

! These constants must match vm/layouts.h
: header-offset ( -- n ) object tag-number neg ; inline
: float-offset ( -- n ) 8 float tag-number - ; inline
: string-offset ( -- n ) 4 bootstrap-cells string tag-number - ; inline
: string-aux-offset ( -- n ) 2 bootstrap-cells string tag-number - ; inline
: profile-count-offset ( -- n ) 7 bootstrap-cells \ word tag-number - ; inline
: byte-array-offset ( -- n ) 2 bootstrap-cells byte-array tag-number - ; inline
: alien-offset ( -- n ) 3 bootstrap-cells alien tag-number - ; inline
: underlying-alien-offset ( -- n ) bootstrap-cell alien tag-number - ; inline
: tuple-class-offset ( -- n ) bootstrap-cell tuple tag-number - ; inline
: word-xt-offset ( -- n ) 9 bootstrap-cells \ word tag-number - ; inline
: quot-xt-offset ( -- n ) 5 bootstrap-cells quotation tag-number - ; inline
: word-code-offset ( -- n ) 10 bootstrap-cells \ word tag-number - ; inline
: array-start-offset ( -- n ) 2 bootstrap-cells array tag-number - ; inline
: compiled-header-size ( -- n ) 5 bootstrap-cells ; inline

! Relocation classes
CONSTANT: rc-absolute-cell    0
CONSTANT: rc-absolute         1
CONSTANT: rc-relative         2
CONSTANT: rc-absolute-ppc-2/2 3
CONSTANT: rc-relative-ppc-2   4
CONSTANT: rc-relative-ppc-3   5
CONSTANT: rc-relative-arm-3   6
CONSTANT: rc-indirect-arm     7
CONSTANT: rc-indirect-arm-pc  8

! Relocation types
CONSTANT: rt-primitive   0
CONSTANT: rt-dlsym       1
CONSTANT: rt-dispatch    2
CONSTANT: rt-xt          3
CONSTANT: rt-xt-direct   4
CONSTANT: rt-here        5
CONSTANT: rt-this        6
CONSTANT: rt-immediate   7
CONSTANT: rt-stack-chain 8
CONSTANT: rt-untagged    9

: rc-absolute? ( n -- ? )
    [ rc-absolute-ppc-2/2 = ]
    [ rc-absolute-cell = ]
    [ rc-absolute = ]
    tri or or ;
