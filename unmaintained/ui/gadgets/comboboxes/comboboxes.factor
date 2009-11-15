USING: accessors arrays kernel math.rectangles sequences
ui.gadgets.controls models.combinators ui.gadgets ui.gadgets.glass
ui.gadgets.labels ui.gestures ;
QUALIFIED-WITH: ui.gadgets.tables tbl
IN: ui.gadgets.comboboxes

TUPLE: combo-table < table spawner ;

M: combo-table handle-gesture [ call-next-method drop ] 2keep swap
   T{ button-up } = [
      [ spawner>> ]
      [ tbl:selected-row [ swap set-control-value ] [ 2drop ] if ]
      [ hide-glass ] tri
   ] [ drop ] if t ;

TUPLE: combobox < label-control table ;
combobox H{
   { T{ button-down } [ dup table>> over >>spawner <zero-rect> show-glass ] }
} set-gestures

: <combobox> ( options -- combobox ) [ first [ combobox new-label ] keep <basic> >>model ] keep
    <basic> combo-table new-table [ 1array ] >>quot >>table ;