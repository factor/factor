! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cnc cnc.bit db.tuples db.types extensions kernel
strings  ;
IN: cnc.bit.cutting-data

TUPLE: bit-cutting-data stepdown stepover spindle_speed spindle_dir rate_units feed_rate plunge_rate notes id ;
bit-cutting-data "bit_cutting_data" {
    { "stepdown" "stepdown" DOUBLE }
    { "stepover" "stepover" DOUBLE }
    { "spindle_speed" "spindle_speed" INTEGER }
    { "spindle_dir" "spindle_dir" INTEGER }
    { "rate_units" "rate_units" INTEGER }
    { "feed_rate" "feed_rate" DOUBLE }
    { "plunge_rate" "plunge_rate" DOUBLE }
    { "notes" "notes" TEXT }
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
} define-persistent

: convert-bit-cutting-data ( bit -- bit )
    ;

: bit-cutting-data-id= ( id -- bit )
    hard-quote  bit-cutting-data new  swap >>id
    [ select-tuple ] with-cncdb ; 

