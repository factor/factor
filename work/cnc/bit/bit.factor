! File: cnc.bit
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC bit data
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax assocs classes.tuple cnc
cnc.bit.cutting-data cnc.bit.geometry combinators combinators.smart db
db.sqlite db.tuples db.types hashtables kernel math math.parser models
namespaces  sequences splitting strings syntax.terse ui
ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.editors
ui.gadgets.labels ui.gadgets.packs ui.gadgets.toolbar
ui.gadgets.worlds ui.gestures ui.tools.browser ui.tools.common
ui.tools.deploy uuid uuid.private cnc.bit.entity ;
IN: cnc.bit

SYMBOL: amanavt-db-path amanavt-db-path [ "/Users/davec/Dropbox/3CL/Data/amanavt.db" ] initialize
SYMBOL: imperial-db-path imperial-db-path [ "/Users/davec/Desktop/Imperial.db" ]  initialize

ENUM: BitType straight upcut downcut compression ;
ENUM: ToolType { ballnose 0 } { endmill 1 } { radius-endmill 2 } { v-bit 3 } { engraving 4 } { taper-ballmill 5 }
    { drill 6 } { diamond 7 } { threadmill 14 } { multit-thread 15 } { laser 12 } ; 
ENUM: RateUnits { mm/sec 0 } { mm/min 1 } { m/min 2 } { in/sec 3 } { in/min 4 } { ft/min 5 } ;

! TUPLES
TUPLE: bit name units tool_type bit_type diameter stepdown stepover spindle_speed spindle_dir
    flutes shank flute_length shank_length 
    rate_units feed_rate plunge_rate
    cost make model source id amana_id entity_id ;

bit "bits" {
    { "name" "name" TEXT }
    { "units" "units" INTEGER }
    { "tool_type" "tool_type" INTEGER }
    { "bit_type" "bit_type" INTEGER }
    { "diameter" "diameter" DOUBLE }
    { "stepdown" "stepdown" DOUBLE }
    { "stepover" "stepover" DOUBLE }
    { "spindle_speed" "spindle_speed" INTEGER }
    { "spindle_dir" "spindle_dir" INTEGER }
    { "flutes" "flutes" INTEGER }
    { "shank" "shank" DOUBLE }
    { "flute_length" "flute_length" DOUBLE }
    { "shank_length" "shank_length" DOUBLE }
    { "rate_units" "rate_units" INTEGER }
    { "feed_rate" "feed_rate" DOUBLE }
    { "plunge_rate" "plunge_rate" DOUBLE }
    { "cost" "cost" DOUBLE }
    { "make" "make" TEXT }
    { "model" "model" TEXT }
    { "source" "source" TEXT }
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
    { "amana_id" "amana_id" TEXT }
    { "entity_id" "entity_id" TEXT }
} define-persistent 

    
: <bit> ( -- <bit> )
    bit new  1 >>units  endmill >>tool_type  upcut >>bit_type
    18000 >>spindle_speed  0 >>spindle_dir 
    2 >>flutes  mm/min >>rate_units  quintid >>id  ;

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

: cncdb>bit ( cnc-dbvt -- bit )
    bit slots>tuple convert-bit-slots ;

: do-cncdb ( statement -- result ? )
    sql-statement set
    [ sql-statement get sql-query ] with-cncdb
    dup empty?
    [ f ] [ [ cncdb>bit ] map t ] if ;

: (inch>mm) ( bit inch -- bit mm )
    over units>> 1 = [ 25.4 / ] when ;

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


: define-bits ( -- )
    [
        <bit>
        "Surface End Mill" >>name
        endmill enum>number >>tool_type
        straight enum>number >>bit_type
        1.0 >>diameter
        1 >>stepdown-mm
        .250 >>stepover
        1/4 >>shank  mm/min enum>number >>rate_units  3000 >>feed_rate  1500 >>plunge_rate 
        "BINSTAK" >>make  "B08SKYYN7P" >>model
        "https://www.amazon.com/gp/product/B08SKYYN7P/ref=ppx_yo_dt_b_search_asin_title" >>source 
        replace-tuple

        <bit>
        "Carving bit flat nose" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        3.175 >>diameter
        1 >>stepdown
        3.175 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "/B08CD99PW" >>model "https://www.amazon.com/gp/product/B08CD99PWL" >>source
        replace-tuple

        <bit>
        "Carving bit ball nose" >>name
        +mm+ enum>number >>units
        ballnose enum>number >>tool_type
        compression enum>number >>bit_type
        3.175 >>diameter
        1 >>stepdown
        3.175 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make "B08CD99PWL" >>model   "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        0.8 >>diameter
        1 >>stepdown
        3.175 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.0 >>diameter
        1 >>stepdown
        1 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.2 >>diameter
        1 >>stepdown
        1.2 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.4 >>diameter
        1 >>stepdown
        1.4 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.6 >>diameter
        1 >>stepdown
        1.6 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.8 >>diameter
        1 >>stepdown
        1.8 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        1.8 >>diameter
        1 >>stepdown
        1.8 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        2.0 >>diameter
        1 >>stepdown
        2.0 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        2.5 >>diameter
        1 >>stepdown
        2.5 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
        "Flat end mill" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        compression enum>number >>bit_type
        3.0 >>diameter
        1 >>stepdown
        3.0 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple

        <bit>
         "Downcut End Mill Sprial" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        downcut enum>number >>bit_type
        3.0 >>diameter
        1 >>stepdown
        3.0 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "HOZLY" >>make  "B073TXSLQK" >>model "https://www.amazon.com/gp/product/B073TXSLQK" >>source 
        replace-tuple

        <bit>
         "Downcut End Mill Sprial" >>name
        +mm+ enum>number >>units
        endmill enum>number >>tool_type
        downcut enum>number >>bit_type
        3.0 >>diameter
        1 >>stepdown
        3.0 .4 * >>stepover
        3.175 >>shank  in/min enum>number >>rate_units  17 >>feed_rate  8 >>plunge_rate  
        "Genmitsu" >>make  "B08CD99PWL" >>model  "https://www.amazon.com/gp/product/B08CD99PWL" >>source 
        replace-tuple
] with-cncdb
;
