! File: cnc.material
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien.enums alien.syntax cnc.jobs db.tuples
db.types kernel uuid ;

IN: cnc.material

TUPLE: material id name source cost ;

material "MATERIAL" {
    { "id" "ID" +db-assigned-id+ }
    { "name" "NAME" TEXT }
    { "source" "SOURCE" TEXT }
    { "cost" "COST" DOUBLE }
} define-persistent 
    
: <material> ( name source cost -- material )
    material new
    swap >>cost
    swap >>source
    swap >>name ;

:: find-material ( named -- material )
    [ T{ material { name named } } select-tuple ] with-jobs-db ;

:: new-material ( named source cost -- material )
    [ material ensure-table 
      material new
      named >>name  source >>source  cost >>cost
      dup insert-tuple
    ] with-jobs-db ;
    
: list-materials ( -- seq )
    1 ;

