! Version: 0.1
! DRI: Dave Carlton
! Description: CNC Machine
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax cnc.jobs db.tuples
db.types kernel uuid ;

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
    [ T{ spindle { name named } } select-tuple ] with-jobs-db
    dup [ drop  spindle new ] unless ; 

TUPLE: mtype id name ;

: <mtype> ( type -- machineType )  mtype new  swap >>name ;

mtype "TYPES" {
    { "id" "ID" +db-assigned-id+ }
    { "name" "NAME" TEXT }
} define-persistent

TUPLE: machine id name model type x-max y-max z-max ;

ENUM: machineIs 3d cnc laser ;

machine "MACHINE" {
    { "id" "ID" +db-assigned-id+ }
    { "name" "NAME" TEXT }
    { "model" "MODEL" TEXT }
    { "type" "TYPE" INTEGER }
    { "x-max" "XMAX" INTEGER }
    { "y-max" "YMAX" INTEGER }
    { "z-max" "ZMAX" INTEGER }
} define-persistent

:: <init> ( machine name model type x-max y-max z-max -- machine ) 
    z-max machine z-max<<
    y-max machine y-max<<
    x-max machine x-max<<
    type enum>number machine type<<
    model machine model<<
    name machine name<<
    machine
    ;

: <machine> ( name model type x-max y-max z-max -- machine ) 
    machine new <init>
    ;

:: find-machine ( named -- machine )
    [ T{ machine { name named } } select-tuple ] with-jobs-db ; 

