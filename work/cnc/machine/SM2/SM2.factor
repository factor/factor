! Version: 0.1
! DRI: Dave Carlton
! Description: Snapmaker 2 Machine
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: cnc.machine kernel multiline ;
IN: cnc.machine.SM2

TUPLE: SM2 < machine ; 

: <SM2> ( -- SM2 )
    SM2 new
    (( name model type x-max y-max z-max -- machine ))
    "SM2 CNC" "Snapmaker 2" cnc 350 360 320 <init>
    ;


: resurface ( -- )
;    
