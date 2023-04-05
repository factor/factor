! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii classes classes.tuple cnc cnc.bit
 cnc.bit.cutting-data cnc.bit.entity cnc.bit.geometry cnc.machine cnc.material combinators.smart
 db db.queries db.tuples db.types kernel math
 namespaces sequences slots.syntax splitting  ;
IN: cnc.bit.vcarve

SYMBOL: vcarve-db-path vcarve-db-path [ "/Users/davec/Dropbox/3CL/Data/tools.vtdb" ]  initialize

CONSTANT: toolgeometry "tool_geometry."
: geometry-clause  ( string -- clause )
    toolgeometry prepend ;

CONSTANT: tooldata "tool_cutting_data."
: data-clause ( string -- clause )
    tooldata prepend ;

TUPLE: vcarve-db < cnc-db ;
: <vcarve> ( -- <vcarve> )
    vcarve-db new
    vcarve-db-path get >>path ;

: with-vcarvedb ( quot -- )
    '[  <vcarve> _  with-db ] call ; inline 


: vcarve-preamble ( -- sql )
    "SELECT 
     tg.name_format,
     tg.tool_type,
     tg.units,
     tg.diameter,
     tcd.stepdown,
     tcd.stepover,
     tcd.spindle_speed,
     tcd.spindle_dir,
     tcd.rate_units,
     tcd.feed_rate,
     tcd.plunge_rate,
     te.id
     FROM tool_entity te 
	 INNER JOIN tool_geometry tg ON ( tg.id = te.tool_geometry_id  )  
	 INNER JOIN tool_cutting_data tcd ON ( tcd.id = te.tool_cutting_data_id  ) "
    clean-whitespace ;

: vcarve-bits ( -- results )
    vcarve-preamble sql-statement set
    [ sql-statement get sql-query ] with-vcarvedb ;

: do-vcarvedb ( statement -- result ? )
    sql-statement set
    [ sql-statement get sql-query ] with-vcarvedb
    dup empty? ; 


TUPLE: vcarve-bit-geometry name tool_type units diameter num_flutes flute_length neck_length notes included_angle
    flat_diameter tip_radius thread_pitch tooth_size tooth_offset tooth_height threaded_length laser_watt
    outline custom_attributes drill_bank_data_id id ;

vcarve-bit-geometry "tool_geometry" {
    { "name" "name_format" TEXT }
    { "tool_type" "tool_type" INTEGER }
    { "units" "units" INTEGER }
    { "diameter" "diameter" DOUBLE }
    { "num_flutes" "num_flutes" INTEGER }
    { "flute_length" "flute_length" DOUBLE }
    { "neck_length" "neck_length" DOUBLE }
    { "notes" "notes" TEXT }
    { "included_angle" "included_angle" DOUBLE }
    { "flat_diameter" "flat_diameter" DOUBLE }
    { "tip_radius" "tip_radius" DOUBLE }
    { "thread_pitch" "thread_pitch" DOUBLE }
    { "tooth_size" "tooth_size" DOUBLE }
    { "tooth_offset" "tooth_offset" DOUBLE }
    { "tooth_height" "tooth_height" DOUBLE }
    { "threaded_length" "threaded_length" DOUBLE }
    { "laser_watt" "laser_watt" INTEGER }
    { "outline" "outline" BLOB }
    { "custom_attributes" "custom_attributes" TEXT }
    { "drill_bank_data_id" "drill_bank_data_id" TEXT }
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
} define-persistent

: vcarve-bit-geometries ( -- vcarve-bit-geometries )
    [ vcarve-bit-geometry ensure-table ] with-vcarvedb
    [ T{ vcarve-bit-geometry { id LIKE" %" } }
      select-tuples ] with-vcarvedb
    ;

: has-shank? ( string -- value ? )
    " " split  reverse
    [ >lower "shank" = ] split-when
    dup length 1 >
    [ unclip-last nip  unclip nip t ]
    [ drop f f ] if ;

: vcarve>cnc-bit-geometry ( vcarve-bit-geometry -- )
    bit-geometry new
    [ copy-slots{ name tool_type units diameter notes id } ] 2keep
    over name>> has-shank? [ >>shank ] [ drop ] if 
    replace-tuple 2drop ;
    

: update-cnc-bit-geometry ( -- )
    [ bit-geometry ensure-table
      vcarve-bit-geometries [ vcarve>cnc-bit-geometry ] each 
    ] with-cncdb ;


TUPLE: vcarve-tool-cutting-data rate_units feed_rate plunge_rate spindle_speed spindle_dir
    stepdown stepover clear_stepover notes thread_depth thread_step_in laser_power laser_passes
    laser_burn_rate length_units line_width laser_kerf id ;

vcarve-tool-cutting-data "tool_cutting_data" {
    { "rate_units" "rate_units" INTEGER }
    { "feed_rate" "feed_rate" DOUBLE }
    { "plunge_rate" "plunge_rate" DOUBLE }
    { "spindle_speed" "spindle_speed" INTEGER }
    { "spindle_dir" "spindle_dir" INTEGER }
    { "stepdown" "stepdown" DOUBLE }
    { "stepover" "stepover" DOUBLE }
    { "clear_stepover" "clear_stepover" DOUBLE }
    { "notes" "notes" TEXT }
    { "thread_depth" "thread_depth" DOUBLE }
    { "thread_step_in" "thread_step_in" DOUBLE }
    { "laser_power" "laser_power" DOUBLE }
    { "laser_passes" "laser_passes" INTEGER }
    { "laser_burn_rate" "laser_burn_rate" DOUBLE }
    { "length_units" "length_units" INTEGER }
    { "line_width" "line_width" DOUBLE }
    { "laser_kerf" "laser_kerf" INTEGER }    
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
} define-persistent

: vcarve-tool-cutting-datas ( -- vcarve-data )
    [ vcarve-tool-cutting-data ensure-table ] with-vcarvedb
    [ T{ vcarve-tool-cutting-data { id LIKE" %" } }
      select-tuples ] with-vcarvedb ;

: vcarve>cnc-bit-cutting-data ( vcarve-data -- )
    bit-cutting-data new
    copy-slots{ stepdown stepover spindle_speed spindle_dir rate_units feed_rate plunge_rate notes id } 
    replace-tuple ;
    
: update-cnc-bit-cutting-data ( -- )
    [ bit-cutting-data ensure-table
      vcarve-tool-cutting-datas [ vcarve>cnc-bit-cutting-data ] each 
    ] with-cncdb ;
    
TUPLE: vcarve-tool-entity id material_id machine_id tool_geometry_id tool_cutting_data_id ;

vcarve-tool-entity "tool_entity" {
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
    { "tool_geometry_id" "tool_geometry_id" TEXT }
    { "tool_cutting_data_id" "tool_cutting_data_id" TEXT }
    { "material_id" "material_id" TEXT }
    { "machine_id" "machine_id" TEXT }
} define-persistent

: vcarve-tool-entities ( -- vcarve-tool-enities )
    [ vcarve-tool-entity ensure-table ] with-vcarvedb
    [ T{ vcarve-tool-entity { id LIKE" %" } }
      select-tuples ] with-vcarvedb
    ;

: vcarve>cnc-bit-entity ( vcarve>cnc-bit-entity -- )
    bit-entity new
    copy-slots{ id tool_geometry_id tool_cutting_data_id material_id machine_id }
    dup tuple-slots [ f over = [ drop NULL ] when ] map  swap class-of slots>tuple 
    replace-tuple ;

: update-cnc-bit-entity ( -- )
    [ bit-entity ensure-table
      vcarve-tool-entities [ vcarve>cnc-bit-entity ] each 
    ] with-cncdb ;

: amana-vcarve-preamble ( -- sql )
    vcarve-preamble  " WHERE tg.name_format LIKE '#%' " append ;

TUPLE: vcarve-material id name ;

vcarve-material "material" {
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
    { "name" "name" TEXT }
} define-persistent

: vcarve-materials ( -- materials )
    [ vcarve-material ensure-table
      T{ vcarve-material { id "NOT NULL" } } select-tuples
    ] with-vcarvedb ;

: vcarve>cnc-material ( vcarve-material -- )
    material new copy-slots{ id name } ensure-table ;

: update-cnc-material ( -- )
    [ material ensure-table
      vcarve-materials [ vcarve>cnc-material ] each 
    ] with-cncdb ;

TUPLE: vcarve-machine name make model controller_type dimensions_units max_width max_height support_rotary support_tool_change
    has_laser_head id ;

vcarve-machine "machine" {
    { "name" "name" TEXT }
    { "make" "make" TEXT }
    { "model" "model" TEXT }
    { "controller_type" "controller_type" TEXT }
    { "dimensions_units" "dimensions_units" INTEGER }
    { "max_width" "max_width" INTEGER }
    { "max_height" "max_height" INTEGER }
    { "support_rotary" "support_rotary" INTEGER }
    { "support_tool_change" "support_tool_change" INTEGER }
    { "has_laser_head" "has_laser_head" INTEGER }
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
} define-persistent

: vcarve-machines ( -- machines )
    [ vcarve-machine ensure-table
      T{ vcarve-machine { id "NOT NULL" } } select-tuples
    ] with-vcarvedb ;

: vcarve>cnc-machine ( vcarve-material -- )
    machine new
    [ copy-slots{ name make model support_rotary support_tool_change id } ] 2keep
    over controller_type>> >>type
    over dimensions_units>> >>units
    over max_width>> >>xmax
    over max_height>> >>ymax
    replace-tuple  2drop ;

: update-cnc-machine ( -- )
    [ machine ensure-table
      vcarve-machines [ vcarve>cnc-machine ] each 
    ] with-cncdb ;

: update-cncdb ( -- )
    update-cnc-bit-entity
    update-cnc-bit-cutting-data
    update-cnc-bit-geometry
    update-cnc-material
    update-cnc-machine
    ;
