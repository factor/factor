! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces math layouts sequences locals
combinators compiler.vops compiler.vops.builder
compiler.cfg.builder ;
IN: compiler.cfg.elaboration

! This pass must run before conversion to machine IR to ensure
! correctness.

GENERIC: elaborate* ( insn -- )

: slot-shift ( -- n )
    tag-bits get cell log2 - ;

:: compute-slot-known-tag ( insn -- addr )
    { $1 $2 $3 $4 $5 } temps
    init-intrinsic
    $1 slot-shift %iconst emit  ! load shift offset
    $2 insn slot>> $1 %shr emit ! shift slot by shift offset
    $3 insn tag>> %iconst emit  ! load tag number
    $4 $2 $3 %isub emit
    $5 insn obj>> $4 %iadd emit ! compute slot offset
    $5
    ;

:: compute-slot-any-tag ( insn -- addr )
    { $1 $2 $3 $4 } temps
    init-intrinsic
    $1 insn obj>> emit-untag    ! untag object
    $2 slot-shift %iconst emit  ! load shift offset
    $3 insn slot>> $2 %shr emit ! shift slot by shift offset
    $4 $1 $3 %iadd emit         ! compute slot offset
    $4
    ;

: compute-slot ( insn -- addr )
    dup tag>> [ compute-slot-known-tag ] [ compute-slot-any-tag ] if ;

M: %%slot elaborate*
    [ out>> ] [ compute-slot ] bi %load emit ;

M: %%set-slot elaborate*
    [ in>> ] [ compute-slot ] bi %store emit ;

M: object elaborate* , ;

: elaboration ( insns -- insns )
    [ [ elaborate* ] each ] { } make ;
