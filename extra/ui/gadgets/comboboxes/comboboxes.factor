USING: accessors arrays kernel math.rectangles models sequences
ui.frp ui.gadgets ui.gadgets.glass ui.gadgets.labels
ui.gadgets.tables ui.gestures ;
IN: ui.gadgets.comboboxes

TUPLE: combo-table < table spawner ;

M: combo-table handle-gesture [ call-next-method ] 2keep swap
   T{ button-up } = [
      [ spawner>> ]
      [ selected-value>> value>> [ swap set-control-value ] [ drop ] if* ]
      [ hide-glass ] tri drop t
   ] [ drop ] if ;

TUPLE: combobox < label-control table ;
combobox H{
   { T{ button-down } [ dup table>> over >>spawner <zero-rect> show-glass ] }
} set-gestures

: <combobox> ( options -- combobox ) [ first [ combobox new-label ] keep <model> >>model ] keep
   [ 1array ] map <model> trivial-renderer combo-table new-table
   >>table ;