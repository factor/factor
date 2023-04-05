! Version: 0.1
! DRI: Dave Carlton
! Description: Snapmaker 2 control
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors cnc cnc.gcode cnc.jobs cnc.machine db.tuples
formatting kernel literals math multiline namespaces prettyprint
variables ;
FROM: cnc.jobs => with-jobs-db ;

IN: cnc.gcode
: bed-leveling ( -- gcode )  1029 G ;

: firmware-info ( -- gcode )  1005 M ;
: tool-header-info ( -- gcode )  1006 M ;
: homed-state ( -- gcode )  1007 M ;
: enclosure-control ( -- gcode )  1010 M ;
: air-purifier-control ( -- gcode )  1011 M ;
: emergency-stop-online ( -- gcode )  1012 M ;
: remap-port ( -- gcode )  1029 M ;
: reboot ( -- gcode )  1999 M ;
: SM2-info ( -- gcode )  2000 M ;
: peripheral-power ( -- gcode )  2001 M ;

IN: cnc.SM2

VAR: SM2 
    
: setup ( -- )
    [ T{ machine { name "SM1 CNC" } } select-tuple ] with-jobs-db
    SM2 set 
    ;

