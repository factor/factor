USING: accessors arrays kernel models ui.frp.signals ui.gadgets
ui.gadgets.buttons ui.gadgets.buttons.private
ui.gadgets.editors ui.gadgets.tables ;
IN: ui.frp.gadgets

TUPLE: frp-button < button hook ;
: <frp-button> ( gadget -- button ) [
      [ dup hook>> [ call( button -- ) ] [ drop ] if* ] keep
      t swap set-control-value
   ] frp-button new-button f <basic> >>model ;

: <frp-bevel-button> ( text -- button ) <frp-button> border-button-theme ;

TUPLE: frp-table < table { quot initial: [ ] } { val-quot initial: [ ] } color-quot column-titles column-alignment ;
M: frp-table column-titles column-titles>> ;
M: frp-table column-alignment column-alignment>> ;
M: frp-table row-columns quot>> [ call( a -- b ) ] [ drop f ] if* ;
M: frp-table row-value val-quot>> [ call( a -- b ) ]  [ drop f ] if* ;
M: frp-table row-color color-quot>> [ call( a -- b ) ]  [ drop f ] if* ;

: <frp-table> ( model -- table ) f frp-table new-table dup >>renderer
   V{ } clone <basic> >>selected-values V{ } clone <basic> >>selected-indices* ;
: <frp-table*> ( -- table ) V{ } clone <model> <frp-table> ;
: <frp-list> ( model -- table ) <frp-table> [ 1array ] >>quot ;
: <frp-list*> ( -- table ) V{ } clone <model> <frp-list> ;
: indexed ( table -- table ) f >>val-quot ;

: <frp-field> ( -- field ) "" <model> <model-field> ;