! File: cnc.material
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien.enums alien.syntax cnc cnc.jobs db.tuples
db.types kernel uuid ;

IN: cnc.material

TUPLE: material name source cost id ;

material "material" {
    { "name" "name" TEXT }
    { "source" "source" TEXT }
    { "cost" "cost" DOUBLE }
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
} define-persistent 
    
: <material> ( name source cost -- material )
    quintid material boa ;

:: find-material ( named -- material )
    [ T{ material { name named } } select-tuple ] with-cncdb ;

:: new-material ( named source cost -- material )
    [ material ensure-table 
      material new
      named >>name  source >>source  cost >>cost
      dup replace-tuple
    ] with-cncdb ;
    
: list-materials ( -- seq )
    1 ;

: define-materials ( -- )
    [ material ensure-table
      "Plywoord Sanded 3/4" "Lowes" 57.00 <material> replace-tuple
    ] with-cncdb ;

! : define-all ( -- )
!     define-types define-spindles define-machines  define-bits  define-materials ;

: save-jobs ( -- )
    [  
    ] with-cncdb
;

