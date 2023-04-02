! File: cnc.bit
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC bit data
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax assocs classes.tuple cnc
cnc.bit.cutting-data cnc.bit.geometry combinators combinators.smart db
db.sqlite db.tuples db.types hashtables kernel math math.parser models
namespaces proquint sequences splitting strings syntax.terse ui
ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.editors
ui.gadgets.labels ui.gadgets.packs ui.gadgets.toolbar
ui.gadgets.worlds ui.gestures ui.tools.browser ui.tools.common
ui.tools.deploy uuid uuid.private cnc.bit.geometry cnc.bit.entity ;
IN: cnc.bit

SYMBOL: cnc-db-path cnc-db-path [ "/Users/davec/Dropbox/3CL/Data/cnc.db" ]  initialize
SYMBOL: amanavt-db-path amanavt-db-path [ "/Users/davec/Dropbox/3CL/Data/amanavt.db" ] initialize
SYMBOL: imperial-db-path imperial-db-path [ "/Users/davec/Desktop/Imperial.db" ]  initialize
SYMBOL: sql-statement 

ENUM: BitType +straight+ +up+ +down+ +compression+ ;
ENUM: ToolType { ballnose 0 } { endmill 1 } { radius-endmill 2 } { v-bit 3 } { engraving 4 } { taper-ballmill 5 }
    { drill 6 } { diamond 7 } { threadmill 14 } { multit-thread 15 } { laser 12 } ; 
ENUM: RateUnits { mm/sec 0 } { mm/min 1 } { m/min 2 } { in/sec 3 } { in/min 4 } { ft/min 5 } ;

DEFER: bit
DEFER: convert-bit-slots
TUPLE: cnc-db < sqlite-db ;
: <cnc-db> ( -- <cnc-db> )
    cnc-db new
    cnc-db-path get >>path ;

: with-cncdb ( quot -- )
    '[ <cnc-db> _ with-db ] call ; inline

: cnc-db>bit ( cnc-dbvt -- bit )
    bit slots>tuple convert-bit-slots ;

: do-cncdb ( statement -- result ? )
    sql-statement set
    [ sql-statement get sql-query ] with-cncdb
    dup empty?
    [ f ] [ [ cnc-db>bit ] map t ] if ;


! Utility
: quintid ( -- id )   uuid1 string>uuid  32 >quint ; 

: (inch>mm) ( bit inch -- bit mm )
    over units>> 1 = [ 25.4 / ] when ;

: clean-whitespace ( str -- 'str )
    [  CHAR: \x09 dupd =
       over  CHAR: \x0a = or
       [ drop CHAR: \x20 ] when
    ] map string-squeeze-spaces ;

! TUPLES
TUPLE: bit name tool_type units diameter stepdown stepover spindle_speed spindle_dir rate_units feed_rate plunge_rate
    id amana_id entity_id ;

: <bit> ( -- <bit> )
    bit new  1 >>tool_type  1 >>units  18000 >>spindle_speed  0 >>spindle_dir  1 >>rate_units  quintid >>id ;

: convert-bit-slots ( bit -- bit )
    [ name>> ] retain  " " split  unclip  dup unclip
    CHAR: # =
    [ drop  [ " " join  trim-whitespace  >>name ] dip  >>amana_id ]
    [ 3drop ]
    if
    [ tool_type>> ] retain  >number >>tool_type
    [ diameter>> ] retain  >number  >>diameter 
    [ units>> ] retain  >number  >>units 
    [ feed_rate>> ] retain  >number  >>feed_rate 
    [ rate_units>> ] retain  >number  >>rate_units 
    [ plunge_rate>> ] retain  >number  >>plunge_rate 
    [ spindle_speed>> ] retain  >number  >>spindle_speed 
    [ spindle_dir>> ] retain  >number  >>spindle_dir 
    [ stepdown>> ] retain  >number  >>stepdown 
    [ stepover>> ] retain  >number  >>stepover 
    ;

: >>diameter-mm ( object value -- object )   (inch>mm) >>diameter ;
: >>stepover-mm ( object value -- object )   (inch>mm) >>stepover ;
: >>stepdown-mm ( object value -- object )   (inch>mm)  >>stepdown ;
: >>feed_rate-mm/min ( object value -- object )  25.4 * >>feed_rate  1 >>rate_units ; 
: >>plunge_rate-mm/min ( object value -- object )  25.4 * >>plunge_rate  1 >>rate_units ; 

: (>mm) ( bit slot-value -- mm-value bit )
    over units>> 1 = 
    [ >number 25.4 * ] when
    >number swap
    ;

: (>mm/min) ( bit value -- mm-value bit )
    >number  over rate_units>> >number  <RateUnits> {
        { mm/sec [ 60 * ] }
        { mm/min [ ] }
        { m/min [ 1000 * ] }
        { in/sec [ 25.4 * 60 * ] }
        { in/min [ 25.4 * ] }
        { ft/min [ 304.8 * ] }
    } case  swap ;
    
: >mm ( bit -- bit )
    [ dup diameter>> (>mm) diameter<< ] keep
    [ dup feed_rate>> (>mm/min) feed_rate<< ] keep
    [ dup plunge_rate>> (>mm/min) plunge_rate<< ] keep
    [ dup stepdown>> (>mm) stepdown<< ] keep
    [ dup stepover>> (>mm) stepover<< ] keep
    mm/min enum>number >>rate_units
    0 >>units 
    ;

: amanavt>bitsy ( seq -- bits ? )
    [ empty? ] [ f  ] [ [ cnc-db>bit ] map t ] smart-if ;

: bit-table-drop ( -- )
    "DROP TABLE IF EXISTS bits"
    clean-whitespace  do-cncdb 2drop ;

: bit-table-create ( -- )
  "CREATE TABLE IF NOT EXISTS 'bits' (
  'name' text NOT NULL,
  'tool_type' integer NOT NULL,
  'units' integer NOT NULL DEFAULT(0),
  'diameter' real,
  'stepdown' real,
  'stepover' real,
  'spindle_speed' integer,
  'spindle_dir' integer,
  'rate_units' integer  NOT NULL,
  'feed_rate' real,
  'plunge_rate' real,
  'id' text PRIMARY KEY UNIQUE NOT NULL,
  'amana_id' text )"        
   clean-whitespace  do-cncdb 2drop ;

: cncdb-where ( -- sql )
    "SELECT * FROM bits WHERE " clean-whitespace ;
    
: bit-where-clause ( clauses -- 'claues )
    dup length 1 > 
    [ [ " and " append ] map 
    "" swap [ append ] each
      "id not null" append
    ]
    [ "" swap [ append ] each ]
    if 
    cncdb-where prepend ;

: bit-add ( bit -- )
    tuple>array  unclip drop 
    "INSERT OR REPLACE INTO bits VALUES (" swap ! )
    [ dup string? [ hard-quote ] when
      dup ratio? [ 1.0 * ] when 
      dup number? [ number>string ] when
      dup [ drop "NULL" ] unless
      ", " append  append
    ] each
    unclip-last drop  unclip-last drop 
    ");" append  do-cncdb 2drop ; 

: bit-delete ( bit -- )
    "DELETE FROM bits WHERE id = '"
    over id>> append  "'" append
    sql-statement set
    [ sql-statement get sql-query ] with-cncdb
    2drop ;
                                
: bit-where ( clauses -- seq )
    bit-where-clause do-cncdb drop ;

: bit-name-like ( named --  bit )
    hard-quote
    "name LIKE " prepend { } 1sequence bit-where ;

: bit-id= ( string -- bit )
    hard-quote  "id = "  prepend
    cncdb-where prepend  do-cncdb
    [ first ] [ drop f ] if ; 

: 1/4-bits ( -- bits )
    { "diameter = 0.25" "units = 1" } bit-where ;

: 1/8bits ( -- bits )
    { "diameter = 0.125" "units = 1" } bit-where ;

: metric-bits ( -- bits ) 
    { "units = 0" } bit-where ;

: imperial-bits ( -- bits )
    { "units = 0" } bit-where ;

: all-bits ( -- bits )
    { "id NOT NULL" } bit-where ;

: spoil-bits ( -- bits )
    { "name LIKE '%SPOIL%1/4\"SHANK'" } bit-where ;


: find-bit-id ( id -- bit bit )
    bit-entity-id=
    [ tool_geometry_id>> bit-geometry-id= ] [ tool_cutting_data_id>> bit-cutting-data-id= ] bi
      
    ;
