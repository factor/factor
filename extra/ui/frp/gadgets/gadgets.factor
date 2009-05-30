USING: accessors arrays kernel models monads ui.frp.signals ui.gadgets
ui.gadgets.buttons ui.gadgets.buttons.private ui.gadgets.editors
ui.gadgets.tables sequences splitting
ui.gadgets.scrollers ui.gadgets.borders ;
IN: ui.frp.gadgets

TUPLE: frp-button < button hook ;
: <frp-button> ( gadget -- button ) [
      [ dup hook>> [ call( button -- ) ] [ drop ] if* ] keep
      dup set-control-value
   ] frp-button new-button f <basic> >>model ;
: <frp-border-button> ( text -- button ) <frp-button> border-button-theme ;

TUPLE: frp-table < table { quot initial: [ ] } { val-quot initial: [ ] } color-quot column-titles column-alignment ;
M: frp-table column-titles column-titles>> ;
M: frp-table column-alignment column-alignment>> ;
M: frp-table row-columns quot>> [ call( a -- b ) ] [ drop f ] if* ;
M: frp-table row-value val-quot>> [ call( a -- b ) ]  [ drop f ] if* ;
M: frp-table row-color color-quot>> [ call( a -- b ) ]  [ drop f ] if* ;

: <frp-table> ( model -- table ) f frp-table new-table dup >>renderer
   V{ } clone <basic> >>selected-values V{ } clone <basic> >>selected-indices* ;
: <frp-table*> ( -- table ) V{ } clone <model> <frp-table> ;
: <frp-list> ( column-model -- table ) <frp-table> [ 1array ] >>quot ;
: <frp-list*> ( -- table ) V{ } clone <model> <frp-list> ;
: indexed ( table -- table ) f >>val-quot ;

GENERIC: output-model ( gadget -- model )
M: gadget output-model model>> ;
M: table output-model dup multiple-selection?>>
   [ dup val-quot>> [ selected-values>> ] [ selected-indices*>> ] if ]
   [ dup val-quot>> [ selected-value>> ] [ selected-index*>> ] if ] if ;
M: model-field output-model field-model>> ;
M: scroller output-model viewport>> children>> first output-model ;

: <frp-field> ( -- field ) "" <model> <model-field> ;
: <frp-field*> ( model -- field ) "" <model> swap <switch> <model-field> ;
: <frp-editor> ( model -- gadget )
    model-field [ <multiline-editor> ] dip new-border dup gadget-child >>editor
    field-theme swap >>field-model { 1 0 } >>align ;
: <frp-editor*> ( model -- editor ) "" <model> swap <switch> <frp-editor> ;

IN: accessors
M: frp-button text>> children>> first text>> ;