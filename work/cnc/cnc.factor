! File: cnc
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC Machine
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax cnc cnc.jobs
cnc.machine cnc.bit cnc.material db db.sqlite db.tuples db.types kernel
math uuid variables ;
IN: cnc

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

! : define-bits ( -- )
!     [ bit recreate-table
!       "Surface End Mill" 1.0 +in+ +straight+ 2 1/4 f f
!       "BINSTAK" "https://www.amazon.com/gp/product/B08SKYYN7P/ref=ppx_yo_dt_b_search_asin_title"
!       <bit> insert-tuple
!       "Carving bit flat nose" 3.175 +mm+ +compression+ 2 3.175 17 38 
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Carving bit ball nose" 3.175 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 0.8 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 1.0 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 1.2 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 1.4 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 1.6 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 1.8 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 2.0 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 2.2 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 2.5 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Flat end mill" 3.0 +mm+ +compression+ 2 3.175 17 38
!       "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
!       <bit> insert-tuple
!       "Downcut End Mill Sprial" 3.175 +mm+ +down+ 2 3.175 17 38
!       "HOZLY" "https://www.amazon.com/gp/product/B073TXSLQK"
!       <bit> insert-tuple
!       "Downcut End Mill Sprial" 1/4 +in+ +compression+ 2 1/4 1.0 2.5
!       "EANOSIC" "https://www.amazon.com/gp/product/B09H33X98L"
!       <bit> insert-tuple
!     ] with-jobs-db ;

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


