! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel layouts system strings ;
IN: compiler.constants

! These constants must match vm/memory.h
: card-bits 8 ; inline
: deck-bits 18 ; inline
: card-mark ( -- n ) HEX: 40 HEX: 80 bitor ; inline

! These constants must match vm/layouts.h
: header-offset ( -- n ) object tag-number neg ; inline
: float-offset ( -- n ) 8 float tag-number - ; inline
: string-offset ( -- n ) 4 bootstrap-cells object tag-number - ; inline
: string-aux-offset ( -- n ) 2 bootstrap-cells string tag-number - ; inline
: profile-count-offset ( -- n ) 7 bootstrap-cells object tag-number - ; inline
: byte-array-offset ( -- n ) 2 bootstrap-cells object tag-number - ; inline
: alien-offset ( -- n ) 3 bootstrap-cells object tag-number - ; inline
: underlying-alien-offset ( -- n ) bootstrap-cell object tag-number - ; inline
: tuple-class-offset ( -- n ) bootstrap-cell tuple tag-number - ; inline
: class-hash-offset ( -- n ) bootstrap-cell object tag-number - ; inline
: word-xt-offset ( -- n ) 9 bootstrap-cells object tag-number - ; inline
: quot-xt-offset ( -- n ) 3 bootstrap-cells object tag-number - ; inline
: word-code-offset ( -- n ) 10 bootstrap-cells object tag-number - ; inline
: array-start-offset ( -- n ) 2 bootstrap-cells object tag-number - ; inline
: compiled-header-size ( -- n ) 4 bootstrap-cells ; inline

! Relocation classes
: rc-absolute-cell    0 ; inline
: rc-absolute         1 ; inline
: rc-relative         2 ; inline
: rc-absolute-ppc-2/2 3 ; inline
: rc-relative-ppc-2   4 ; inline
: rc-relative-ppc-3   5 ; inline
: rc-relative-arm-3   6 ; inline
: rc-indirect-arm     7 ; inline
: rc-indirect-arm-pc  8 ; inline

! Relocation types
: rt-primitive 0 ; inline
: rt-dlsym     1 ; inline
: rt-literal   2 ; inline
: rt-dispatch  3 ; inline
: rt-xt        4 ; inline
: rt-here      5 ; inline
: rt-label     6 ; inline
: rt-immediate 7 ; inline

: rc-absolute? ( n -- ? )
    [ rc-absolute-ppc-2/2 = ]
    [ rc-absolute-cell = ]
    [ rc-absolute = ]
    tri or or ;
