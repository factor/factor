! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs cnc cnc.bit db.tuples hashtables
 kernel models namespaces sequences ui ui.commands
 ui.gadgets ui.gadgets.borders ui.gadgets.editors ui.gadgets.labels ui.gadgets.packs ui.gadgets.toolbar
 ui.gadgets.worlds ui.gestures ui.tools.browser ui.tools.common ui.tools.deploy  ;
IN: cnc.bit.gadget

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

