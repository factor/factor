! File: cnc
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC Machine
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax cnc cnc.bit cnc.jobs
 cnc.machine cnc.material db db.sqlite db.tuples db.types
 kernel math namespaces uuid variables  ;
IN: cnc

SYMBOL: cnc-db-path cnc-db-path [ "/Users/davec/Dropbox/3CL/Data/cnc.db" ]  initialize
ENUM: units +mm+ +in+ ;

: define-spindles ( --  )
    [ spindle recreate-table
      "SM2" "ER11" 12000 0.07 <spindle> insert-tuple
      "HY"  "ER11" 24000 2.0  <spindle> insert-tuple
      "BOSCH" "ER20" 32000 1.25 <spindle> insert-tuple
    ] with-jobs-db
    ;

: define-types ( -- )
    [ mtype recreate-table
      "3d" <mtype> insert-tuple
      "laser" <mtype> insert-tuple
      "cnc" <mtype> insert-tuple
    ] with-jobs-db ;

: define-machines ( -- )
    [ machine recreate-table
    "SM1 3D" "Snapmaker 2" +3d+ 350 360 320 <machine> insert-tuple
    "SM1 Laser" "Snapmaker 2" +laser+ 350 360 320 <machine> insert-tuple
    "SM1 CNC" "Snapmaker 2" +cnc+ 350 360 320 <machine> insert-tuple
    "SM2 3D" "Snapmaker 2" +3d+  350 360 320 <machine> insert-tuple
    "SM2 Laser" "Snapmaker 2" +laser+  350 360 320 <machine> insert-tuple
    "SM2 CNC" "Snapmaker 2" +cnc+  350 360 320 <machine> insert-tuple
    "P1"  "Prusa MK2.5S" +3d+ 250 210 210 <machine> insert-tuple
    "P2"  "Prusa MK3S" +3d+ 250 210 210 <machine> insert-tuple
    "ONE CNC" "Onefinity J50" +cnc+
    48.25 25.4 * >integer  32.25 25.4 * >integer  5.25 25.4 * >integer
    <machine> insert-tuple
    "ONE Laser" "Onefinity J50" +laser+
    48.25 25.4 * >integer  32.25 25.4 * >integer  5.25 25.4 * >integer
    <machine> insert-tuple
    ] with-jobs-db
    ;

: define-materials ( -- )
    [ material recreate-table
      "Plywoord Sanded 3/4" "Lowes" 57.00 <material> insert-tuple
    ] with-jobs-db ;

! : define-all ( -- )
!     define-types define-spindles define-machines  define-bits  define-materials ;

: save-jobs ( -- )
    [  
    ] with-jobs-db
;


