! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cnc cnc.bit cnc.bit.cutting-data cnc.bit.geometry db.tuples
db.types kernel  ;
IN: cnc.bit.entity

TUPLE: bit-entity id tool_geometry_id tool_cutting_data_id material_id machine_id ;
bit-entity "bit_entity" {
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
    { "tool_geometry_id" "tool_geometry_id" TEXT +not-null+ }
    { "tool_cutting_data_id" "tool_cutting_data_id" TEXT +not-null+ }
    { "material_id" "material_id" TEXT }
    { "machine_id" "machine_id" TEXT }
} define-persistent

: bit-entity-id= ( id -- bit )
    bit-entity new  swap >>id
    [ select-tuple ] with-cncdb ; 

: find-bit-id ( id -- bit bit )
    bit-entity-id=
    [ tool_geometry_id>> bit-geometry-id= ] [ tool_cutting_data_id>> bit-cutting-data-id= ] bi      
    ;

