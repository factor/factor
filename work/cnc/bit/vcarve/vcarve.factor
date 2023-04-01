! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple cnc.bit combinators.smart db db.queries
 db.tuples db.types kernel namespaces sequences  slots.syntax splitting ascii math ;
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
    { "id" "id" TEXT }
} define-persistent

: cncdb>bit-geometery ( cncdbvt -- bit )
    vcarve-bit-geometry slots>tuple convert-bit-geometry ;

: vcarve>bit-geometery ( seq -- bits ? )
    [ empty? ] [ f  ] [ [ cncdb>bit-geometery ] map t ] smart-if ;

: vcarve-bit-geometery ( -- bits )
    "SELECT * FROM bit_geometery" sql-statement set
    vcarve-db new  vcarve-db-path get >>path  
    [ sql-statement get sql-query  ] with-db ;

: amanavt-bits ( -- bits )
    vcarve-preamble sql-statement set
    vcarve-db new  amanavt-db-path get >>path  
    [ sql-statement get sql-query  ] with-db ;

: convert-vcarve-bit-geometery ( -- vcarve-bit-geometries )
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
    insert-tuple 2drop ;
    

: create-cnc-bit-geometry ( -- )
    [ bit-geometry recreate-table
      convert-vcarve-bit-geometery
      [ vcarve>cnc-bit-geometry ] each 
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
    { "id" "id" TEXT }
} define-persistent

: convert-vcarve-tool-cutting-data ( -- vcarve-data )
    [ vcarve-tool-cutting-data ensure-table ] with-vcarvedb
    [ T{ vcarve-tool-cutting-data { id LIKE" %" } }
      select-tuples ] with-vcarvedb ;

: vcarve>cnc-bit-cutting-data ( vcarve-tool-data -- )
    bit-cutting-data new
    [ copy-slots{ stepdown stepover spindle_speed spindle_dir rate_units feed_rate plunge_rate notes id } ] 2keep
    insert-tuple 2drop ;
    
: create-cnc-bit-cutting-data ( -- )
    [ bit-cutting-data recreate-table
      convert-vcarve-tool-cutting-data
      [ vcarve>cnc-bit-cutting-data ] each 
    ] with-cncdb ;
    
TUPLE: vcarve-tool-entity id material_id machine_id tool_geometry_id tool_cutting_data_id ;

vcarve-tool-entity "tool_entity" {
    { "id" "id" TEXT }
    { "tool_geometry_id" "tool_geometry_id" TEXT }
    { "tool_cutting_data_id" "tool_cutting_data_id" TEXT }
    { "material_id" "material_id" TEXT }
    { "machine_id" "machine_id" TEXT }
} define-persistent

: convert-vcarve-tool-entity ( -- vcarve-bit-enities )
    [ vcarve-tool-entity ensure-table ] with-vcarvedb
    [ T{ vcarve-tool-entity { id LIKE" %" } }
      select-tuples ] with-vcarvedb
    ;

: vcarve>cnc-bit-entity ( vcarve-bit-geometry -- )
    bit-entity new
    [ copy-slots{ id tool_geometry_id tool_cutting_data_id material_id machine_id } ] 2keep
    insert-tuple 2drop ;

: create-cnc-bit-entity ( -- )
    [ bit-entity recreate-table
      convert-vcarve-tool-entity
      [ vcarve>cnc-bit-entity ] each 
    ] with-cncdb ;

: amana-vcarve-preamble ( -- sql )
    vcarve-preamble  " WHERE tg.name_format LIKE '#%' " append ;


