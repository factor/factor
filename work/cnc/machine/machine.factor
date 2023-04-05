! Version: 0.1
! DRI: Dave Carlton
! Description: CNC Machine
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax cnc cnc.jobs db.tuples
db.types kernel math uuid  ;

IN: cnc.machine

TUPLE: spindle id name collet rpm hp ;
spindle "SPINDLE" {
    { "id" "ID" +db-assigned-id+ }
    { "name" "NAME" TEXT }
    { "collet" "COLLET" TEXT }
    { "rpm" "RPM" INTEGER }
    { "hp" "HP" INTEGER }
} define-persistent

: <spindle> ( name collet rpm hp -- spindle )
    spindle new
    swap >>hp
    swap >>rpm
    swap >>collet
    swap >>name ;

:: find-spindle ( named -- spindle )
    [ T{ spindle { name named } } select-tuple ] with-cncdb
    dup [ drop  spindle new ] unless ; 

TUPLE: mtype id name ;

: <mtype> ( type -- machineType )  mtype new  swap >>name ;

mtype "TYPES" {
    { "id" "ID" +db-assigned-id+ }
    { "name" "NAME" TEXT }
} define-persistent

ENUM: machineIs +3d+ +cnc+ +laser+ ;

TUPLE: machine name make model type units xmax ymax zmax  support_rotary support_tool_change id ;

machine "machine" {
    { "name" "name" TEXT }
    { "make" "make" TEXT }
    { "model" "model" TEXT }
    { "type" "type" INTEGER }
    { "units" "units" INTEGER }
    { "xmax" "xmax" INTEGER }
    { "ymax" "ymax" INTEGER }
    { "zmax" "zmax" INTEGER }
    { "support_rotary" "support_rotary" INTEGER }
    { "support_tool_change" "support_tool_change" INTEGER }
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
} define-persistent

: <machine> ( name make model type units xmax ymax zmax -- machine )
    f f quintid machine boa
    dup  units>> enum>number >>units
    dup  type>> enum>number >>type
    ;

:: find-machine ( named -- machine )
    [ T{ machine { name named } } select-tuple ] with-cncdb ; 


: define-spindles ( --  )
    [ spindle recreate-table
      "SM2" "ER11" 12000 0.07 <spindle> replace-tuple
      "HY"  "ER11" 24000 2.0  <spindle> replace-tuple
      "BOSCH" "ER20" 32000 1.25 <spindle> replace-tuple
    ] with-cncdb
    ;

: define-types ( -- )
    [ mtype recreate-table
      "3d" <mtype> replace-tuple
      "laser" <mtype> replace-tuple
      "cnc" <mtype> replace-tuple
    ] with-cncdb ;

: define-machines ( -- )
    [ machine ensure-table
    "SM1 3D" "Snapmaker" "2" +3d+ +mm+ 350 360 320 <machine> replace-tuple
    "SM1 Laser" "Snapmaker" "2" +laser+ +mm+ 350 360 320 <machine> replace-tuple
    "SM1 CNC" "Snapmaker" "2" +cnc+ +mm+ 350 360 320 <machine> replace-tuple
    "SM2 3D" "Snapmaker" "2" +3d+  +mm+ 350 360 320 <machine> replace-tuple
    "SM2 Laser" "Snapmaker" "2" +laser+  +mm+ 350 360 320 <machine> replace-tuple
    "SM2 CNC" "Snapmaker" "2" +cnc+  +mm+ 350 360 320 <machine> replace-tuple
    "P1" "Prusa" "MK2.5S" +3d+ +mm+ 250 210 210 <machine> replace-tuple
    "P2" "Prusa" "MK3S" +3d+ +mm+ 250 210 210 <machine> replace-tuple
    "1F" "Onefinity" "J50" +cnc+ +mm+ 
    48.25 25.4 * >integer  32.25 25.4 * >integer  5.25 25.4 * >integer
    <machine> replace-tuple
    "1F Laser" "Onefinity" "J50" +laser+ +mm+ 
    48.25 25.4 * >integer  32.25 25.4 * >integer  5.25 25.4 * >integer
    <machine> replace-tuple
    ] with-cncdb
    ;

