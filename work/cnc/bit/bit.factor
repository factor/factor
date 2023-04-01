! File: cnc.bit
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC bit data
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING:   accessors alien.enums alien.syntax assocs classes.tuple
  cnc combinators combinators.smart db
  db.sqlite db.tuples db.types hashtables kernel
  math math.parser models namespaces proquint
  sequences splitting strings syntax.terse ui
  ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.editors ui.gadgets.labels
  ui.gadgets.packs ui.gadgets.toolbar ui.gadgets.worlds ui.gestures ui.tools.browser
  ui.tools.common ui.tools.deploy uuid uuid.private ;
IN: cnc.bit

SYMBOL: cnc-db-path cnc-db-path [ "/Users/davec/Dropbox/3CL/Data/cnc.db" ]  initialize
SYMBOL: amanavt-db-path amanavt-db-path [ "/Users/davec/Dropbox/3CL/Data/amanavt.db" ] initialize
SYMBOL: imperial-db-path imperial-db-path [ "/Users/davec/Desktop/Imperial.db" ]  initialize
SYMBOL: sql-statement 

ENUM: BitType +straight+ +up+ +down+ +compression+ ;
ENUM: ToolType { ballnose 0 } { endmill 1 } { radius-endmill 2 } { v-bit 3 } { engraving 4 } { taper-ballmill 5 }
    { drill 6 } { diamond 7 } { threadmill 14 } { multit-thread 15 } { laser 12 } ; 
ENUM: RateUnits { mm/sec 0 } { mm/min 1 } { m/min 2 } { in/sec 3 } { in/min 4 } { ft/min 5 } ;

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
    id amana_id ;

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

TUPLE: bit-geometry name  tool_type units diameter shank notes amanaid id ;
bit-geometry "bit_geometry" {
    { "name" "name_format" TEXT }
    { "tool_type" "tool_type" INTEGER }
    { "units" "units" INTEGER }
    { "diameter" "diameter" DOUBLE }
    { "shank" "shank" TEXT }
    { "notes" "notes" TEXT }
    { "amanaid" "amanaid" TEXT }
    { "id" "id" TEXT }
} define-persistent

: convert-bit-geometry ( bit -- bit )
    [ name>> ] retain  " " split  unclip  dup unclip
    CHAR: # =
    [ drop  [ " " join  trim-whitespace  >>name ] dip  >>amana_id ]
    [ 3drop ]
    if
    [ tool_type>> ] retain  >number >>tool_type
    [ diameter>> ] retain  >number  >>diameter 
    [ units>> ] retain  >number  >>units 
    ;

: bit-geometery-table-drop ( -- )
    "DROP TABLE IF EXISTS bit_geometery"
    clean-whitespace  do-cncdb 2drop ;

: bit-geometery-table-create ( -- )
  "CREATE TABLE IF NOT EXISTS bit_geometery (
  'name' text NOT NULL,
  'tool_type' integer NOT NULL,
  'units' integer NOT NULL DEFAULT(0),
  'diameter' real,
  'notes' text,
  'id' text PRIMARY KEY UNIQUE NOT NULL,
  'amana_id' text )"        
   clean-whitespace  do-cncdb 2drop ;

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
    { "id" "id" TEXT }
} define-persistent

: convert-bit-cutting-data ( bit -- bit )
    ;

TUPLE: bit-entity id tool_geometry_id tool_cutting_data_id material_id machine_id ;
bit-entity "bit_entity" {
    { "id" "id" TEXT }
    { "tool_geometry_id" "tool_geometry_id" TEXT }
    { "tool_cutting_data_id" "tool_cutting_data_id" TEXT }
    { "material_id" "material_id" TEXT }
    { "machine_id" "machine_id" TEXT }
} define-persistent

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

TUPLE: bit-gadget < pack bit values ;
SYMBOLS: bitName bitToolType bitDiameter bitUnits bitFeedRate bitRateUnits bitPlungeRate
    bitSpindleSpeed bitSpindleDir bitStepDown bitStepOver bitClearStepOver bitLengthUnits ;

: bit-help ( -- )  "cnc.bit" com-browse ;
: bit-add-new ( -- )  ;

bit-gadget "misc" "Miscellaneous commands" {
    { T{ key-down f f "ESC" } close-window }
} define-command-map

bit-gadget "toolbar" f {
    { T{ key-down f f "F1" } bit-help }
    { f com-revert }
    { f com-save }
    { T{ key-down f f "RET" } bit-add-new }
} define-command-map

: default-bit ( bit -- assoc )
    quintid >>id bit
    associate  H{
        { bitName "New Bit" }
        { bitToolType 0 }
        { bitDiameter 0.25 }
        { bitUnits 1 }
        { bitFeedRate 1000 }
        { bitRateUnits 0 }
        { bitPlungeRate 500 }
        { bitSpindleSpeed 18000 }
        { bitSpindleDir 0 }
        { bitStepDown 1 }
        { bitStepOver 2 }
        { bitClearStepOver 2 }
        { bitLengthUnits 1 }
    } assoc-union ;

: bit-guts ( parent -- parent )
    bitName get <model-field>  "Bit Name:"
    label-on-left add-gadget
    bitToolType get <model-field> "Tool Type:"
    label-on-left add-gadget
    ;

: <bit-values> ( bit -- control )    
    default-bit [ <model> ] assoc-map [
        <pile> bit-guts
    ] with-variables ;
    
: <bit-gadget> ( bit -- gadget )
    bit-gadget new  over >>bit  
    vertical >>orientation
    dup -rot swap <bit-values> >>values
    dup values>> add-gadget
    <toolbar> { 10 10 } >>gap  add-gadget
    { 10 10 } >>gap  1 >>fill ;


: bit-tool ( bit -- x )
    [ <bit-gadget> { 10 10 } <border> white-interior ]
    [ <world-attributes> "Bit" "(" ")" surround >>title 
      [ { dialog-window } append ] change-window-controls ]
      bi  swapd open-window ; 

: define-bits ( -- )
    {
      "Surface End Mill" 1.0 +in+ +straight+ 2 1/4 f f
      "BINSTAK" "https://www.amazon.com/gp/product/B08SKYYN7P/ref=ppx_yo_dt_b_search_asin_title"
      <bit> insert-tuple
      "Carving bit flat nose" 3.175 +mm+ +compression+ 2 3.175 17 38 
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Carving bit ball nose" 3.175 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 0.8 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 1.0 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 1.2 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 1.4 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 1.6 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 1.8 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 2.0 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 2.2 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 2.5 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Flat end mill" 3.0 +mm+ +compression+ 2 3.175 17 38
      "Genmitsu" "https://www.amazon.com/gp/product/B08CD99PWL"
      <bit> insert-tuple
      "Downcut End Mill Sprial" 3.175 +mm+ +down+ 2 3.175 17 38
      "HOZLY" "https://www.amazon.com/gp/product/B073TXSLQK"
      <bit> insert-tuple
      "Downcut End Mill Sprial" 1/4 +in+ +compression+ 2 1/4 1.0 2.5
      "EANOSIC" "https://www.amazon.com/gp/product/B09H33X98L"
      <bit> insert-tuple
    } drop ;

