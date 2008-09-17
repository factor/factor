! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel layouts system ;
IN: compiler.constants

! These constants must match vm/memory.h
: card-bits 8 ;
: deck-bits 18 ;
: card-mark ( -- n ) HEX: 40 HEX: 80 bitor ;

! These constants must match vm/layouts.h
: header-offset ( -- n ) object tag-number neg ;
: float-offset ( -- n ) 8 float tag-number - ;
: string-offset ( -- n ) 4 bootstrap-cells object tag-number - ;
: profile-count-offset ( -- n ) 7 bootstrap-cells object tag-number - ;
: byte-array-offset ( -- n ) 2 bootstrap-cells object tag-number - ;
: alien-offset ( -- n ) 3 bootstrap-cells object tag-number - ;
: underlying-alien-offset ( -- n ) bootstrap-cell object tag-number - ;
: tuple-class-offset ( -- n ) bootstrap-cell tuple tag-number - ;
: class-hash-offset ( -- n ) bootstrap-cell object tag-number - ;
: word-xt-offset ( -- n ) 9 bootstrap-cells object tag-number - ;
: quot-xt-offset ( -- n ) 3 bootstrap-cells object tag-number - ;
: word-code-offset ( -- n ) 10 bootstrap-cells object tag-number - ;
: array-start-offset ( -- n ) 2 bootstrap-cells object tag-number - ;
: compiled-header-size ( -- n ) 4 bootstrap-cells ;

! Relocation classes
: rc-absolute-cell    0 ;
: rc-absolute         1 ;
: rc-relative         2 ;
: rc-absolute-ppc-2/2 3 ;
: rc-relative-ppc-2   4 ;
: rc-relative-ppc-3   5 ;
: rc-relative-arm-3   6 ;
: rc-indirect-arm     7 ;
: rc-indirect-arm-pc  8 ;

! Relocation types
: rt-primitive 0 ;
: rt-dlsym     1 ;
: rt-literal   2 ;
: rt-dispatch  3 ;
: rt-xt        4 ;
: rt-here      5 ;
: rt-label     6 ;
: rt-immediate 7 ;

: rc-absolute? ( n -- ? )
    [ rc-absolute-ppc-2/2 = ]
    [ rc-absolute-cell = ]
    [ rc-absolute = ]
    tri or or ;
