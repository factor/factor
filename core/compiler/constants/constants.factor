! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel layouts system ;
IN: compiler.constants

! These constants must match vm/memory.h
: card-bits 6 ;
: card-mark HEX: 40 HEX: 80 bitor ;

! These constants must match vm/layouts.h
: header-offset object tag-number neg ;
: float-offset 8 float tag-number - ;
: string-offset 4 bootstrap-cells object tag-number - ;
: profile-count-offset 7 bootstrap-cells object tag-number - ;
: byte-array-offset 2 bootstrap-cells object tag-number - ;
: alien-offset 3 bootstrap-cells object tag-number - ;
: underlying-alien-offset bootstrap-cell object tag-number - ;
: tuple-class-offset bootstrap-cell tuple tag-number - ;
: class-hash-offset bootstrap-cell object tag-number - ;
: word-xt-offset 8 bootstrap-cells object tag-number - ;
: word-code-offset 9 bootstrap-cells object tag-number - ;
: compiled-header-size 4 bootstrap-cells ;
