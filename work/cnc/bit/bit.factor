! File: cnc.bit
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC bit data
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax assocs classes.tuple cnc
 cnc.jobs db db.sqlite db.tuples db.types file.xattr
 hashtables kernel math math.parser models namespaces
 proquint quotations sequences strings ui
 ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.editors ui.gadgets.labels ui.gadgets.packs
 ui.gadgets.toolbar ui.gadgets.worlds ui.gestures ui.tools.browser ui.tools.common ui.tools.deploy
 uuid uuid.private variables  ;
IN: cnc.bit

! TUPLE: bit id name size unit type flutes shank edge length manf url cost note ;

! bit "BITS" {
!     { "id" "ID" +db-assigned-id+ }
!     { "name" "NAME" TEXT }
!     { "size" "SIZE" DOUBLE }
!     { "unit" "UNIT" INTEGER }
!     { "type" "TYPE" INTEGER }
!     { "flutes" "FLUTES" INTEGER }
!     { "shank" "SHANK" DOUBLE }
!     { "edge" "EDGE" DOUBLE }
!     { "length" "LENGTH" DOUBLE }
!     { "manf" "MANF" TEXT }
!     { "url" "URL" URL }
!     { "cost" "COST" DOUBLE }
!     { "note" "NOTE" TEXT }
! } define-persistent


ENUM: bitType +straight+ +up+ +down+ +compression+ ;

! : <bit> ( name size unit type flutes shank edge length manf url -- bit )
!     bit new
!     swap >>url
!     swap >>manf
!     swap >>length
!     swap >>edge
!     swap >>shank
!     swap >>flutes
!     swap enum>number >>type
!     swap enum>number >>unit
!     swap >>size
!     swap >>name ;

TUPLE: bit
    name
    tool_type 
    diameter 
    units 
    feed_rate 
    rate_units 
    plunge_rate 
    spindle_speed 
    spindle_dir 
    stepdown 
    stepover
    clear_stepover
    length_units
    id
;

! TUPLE: amana-bit1
!     name_format
!     { tool_type integer }
!     { diameter real }
!     { units integer }
!     { feed_rate integer }
!     { rate_units integer }
!     { plunge_rate integer }
!     { spindle_speed integer }
!     { spindle_dir integer }
!     { stepdown real }
!     { stepover real }
!     { clear_stepover real }
!     { length_units integer } ;

bit "amana" {
    { "name" "name" TEXT }
    { "tool_type" "tool_type" INTEGER }
    { "diameter" "diameter" DOUBLE }
    { "units" "units" INTEGER }
    { "feed_rate" "feed_rate" INTEGER }
    { "rate_units" "rate_units" INTEGER }
    { "plunge_rate" "plunge_rate" INTEGER }
    { "spindle_speed" "spindle_speed" INTEGER }
    { "spindle_dir" "spindle_dir" INTEGER }
    { "stepdown" "stepdown" DOUBLE }
    { "stepover" "stepdown" DOUBLE }
    { "clear_stepover" "stepdown" DOUBLE }
    { "length_units" "length_units" INTEGER }
    { "id" "id" INTEGER }
} define-persistent

INITIALIZED-SYMBOL: amana-db-path [ "/Users/davec/Dropbox/3CL/Data/amanavt.db" ]
INITIALIZED-SYMBOL: amana-db [ "/Users/davec/Dropbox/3CL/Data/Amana.db" ]

: (>mm) ( bit slot-value -- mm-value bit )
    >number 25.4 * swap ;

: >mm ( bit -- bit )
    [ dup diameter>> (>mm) diameter<< ] keep
    [ dup feed_rate>> (>mm) feed_rate<< ] keep
    [ dup plunge_rate>> (>mm) plunge_rate<< ] keep
    [ dup stepdown>> (>mm) stepdown<< ] keep
    [ dup stepover>> (>mm) stepover<< ] keep
    ;

TUPLE: amana < sqlite-db ;
: <amana> ( -- <amana> )
    amana new
    amana-db get >>path ;

: with-amana-db ( quot -- )
    '[ <amana> _ with-db ] call ; inline

CONSTANT: toolgeometry "tool_geometry."
CONSTANT: tooldata "tool_cutting_data."

! : tool-preamble ( -- sql )
!     "SELECT
! 	tool_geometry.name,
! 	tool_geometry.tool_type,
! 	tool_geometry.diameter,
! 	tool_geometry.units,
! 	tool_cutting_data.feed_rate,
! 	tool_cutting_data.rate_units,
! 	tool_cutting_data.plunge_rate,
! 	tool_cutting_data.spindle_speed,
! 	tool_cutting_data.spindle_dir,
! 	tool_cutting_data.stepdown,
! 	tool_cutting_data.stepover,
! 	tool_cutting_data.clear_stepover,
! 	tool_cutting_data.length_units,
! 	tool_cutting_data.id,
! 	tool_geometry.id
!     FROM
! 	tool_cutting_data
! 	JOIN tool_entity ON tool_cutting_data.id = tool_entity.tool_cutting_data_id
! 	JOIN tool_geometry ON tool_geometry.id = tool_entity.tool_geometry_id
!     WHERE
!     "
!     [  CHAR: \x09 dupd =  over  CHAR: \x0a = or   [ drop CHAR: \x20 ] when  ] map 
!     ;

: tool-preamble ( -- sql )
    "SELECT
	name,
	tool_type,
	diameter,
	units,
	feed_rate,
	rate_units,
	plunge_rate,
	spindle_speed,
	spindle_dir,
	stepdown,
	stepover,
    clear_stepover,
	length_units,
    id
    FROM
	amana
    WHERE
    "
    [  CHAR: \x09 dupd =  over  CHAR: \x0a = or   [ drop CHAR: \x20 ] when  ] map 
    ;


: geometry-clause  ( string -- clause )
    toolgeometry prepend ;

: data-clause ( string -- clause )
    tooldata prepend ;

SYMBOL: sql-statement 
: bit-clause1 ( clauses -- )
    [ geometry-clause " and " append ] map
    "" swap [ append ] each
    "tool_cutting_data.feed_rate not null" append
    tool-preamble prepend
    sql-statement set ;

: bit-clause ( clauses -- )
    [  " and " append ] map
    "" swap [ append ] each
    "feed_rate not null" append
    tool-preamble prepend
    sql-statement set ;

: bit-add ( bit -- )
    tuple>array  unclip drop 
    "INSERT INTO amana VALUES (" swap ! )
    [ dup string? [ hard-quote ] when                             
      dup number? [ number>string ] when
      ", " append  append
    ] each
    unclip-last drop  unclip-last drop 
    ");" append  sql-statement set
      [ sql-statement get sql-query drop ] with-amana-db ;
                                
: (bit-find) ( clauses -- bits )
    bit-clause [ sql-statement get sql-query ] with-amana-db ;

: find-bit ( clauses -- seq )
    (bit-find)  [ bit slots>tuple ] map
    ;

: find-bit-names ( named --  bit )
    "name LIKE " prepend { } 1sequence  (bit-find) ; 

: find-bit-id ( string -- bit )
    "'" prepend  "'" append
    "id = "  prepend
    tool-preamble prepend
    sql-statement set
    [ sql-statement get sql-query ] with-amana-db
    [ bit slots>tuple ] map  first
    ;

: 1/4-bits ( -- bits )
    { "diameter = 0.25" "units = 1" }
    find-bit ;

: resurface-bit ( -- bit )
    "lopud-divok" find-bit-id  >mm
    0.5 >>stepdown
    0 >>units ; 

TUPLE: bit-gadget < pack bit values ;
SYMBOLS: bitName bitToolType bitDiameter bitUnits bitFeedRate bitRateUnits bitPlungeRate
    bitSpindleSpeed bitSpindleDir bitStepDown bitStepOver bitClearStepOver bitLengthUnits ;

: bit-help ( -- )  "cnc.bit" com-browse ;
: bit-add-new ( -- )  B ;

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
    uuid1 string>uuid  32 >quint
    >>id bit  associate  H{
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
