! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple cnc.bit combinators.smart db db.queries
 db.tuples db.types kernel namespaces sequences  slots.syntax splitting ascii math ;
IN: cnc.bit.vcarve

SYMBOL: vcarve-db-path vcarve-db-path [ "/Users/davec/Dropbox/3CL/Data/tools.vtdb" ]  initialize
CONSTANT: toolgeometry "tool_geometry."
CONSTANT: tooldata "tool_cutting_data."

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

: geometry-clause  ( string -- clause )
    toolgeometry prepend ;

: data-clause ( string -- clause )
    tooldata prepend ;

: vcarve-bits ( -- results )
    vcarve-preamble sql-statement set
    [ sql-statement get sql-query ] with-vcarvedb ;


TUPLE: vcarve-bit-geometry name tool_type units diameter notes id ;

vcarve-bit-geometry "tool_geometry" {
    { "name" "name_format" TEXT }
    { "tool_type" "tool_type" INTEGER }
    { "units" "units" INTEGER }
    { "diameter" "diameter" DOUBLE }
    { "notes" "notes" TEXT }
    { "id" "id" TEXT }
} define-persistent

: do-vcarvedb ( statement -- result ? )
    sql-statement set
    [ sql-statement get sql-query ] with-vcarvedb
    dup empty? ; 

: amana-vcarve-preamble ( -- sql )
    vcarve-preamble  " WHERE tg.name_format LIKE '#%' " append ;

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
    ! bit-geometery-table-drop  bit-geometery-table-create
    [ vcarve-bit-geometry ensure-table ] with-cncdb
    [ T{ vcarve-bit-geometry { id LIKE" %SPOIL%" } }
      select-tuples ] with-vcarvedb
    ;

: replace-shk ( string -- string ) ;
    
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

: bit-clause1 ( clauses -- )
    [ geometry-clause " and " append ] map
    "" swap [ append ] each
    "tool_cutting_data.feed_rate not null" append
    cncdb-where prepend
    sql-statement set ;

