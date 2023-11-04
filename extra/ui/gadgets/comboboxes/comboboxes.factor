USING: accessors arrays fonts kernel math.rectangles
models.arrow models.combinators namespaces sequences ui.gadgets
ui.gadgets.controls ui.gadgets.glass ui.gadgets.labels
ui.gestures ui.pens.solid ui.tools.common ui.gadgets.borders ;
QUALIFIED-WITH: ui.gadgets.tables tbl
IN: ui.gadgets.comboboxes

TUPLE: combo-table < table spawner ;

: disp-string ( str -- str' ) " ▾ " append " " swap append ;

M: combo-table handle-gesture
    [ call-next-method drop ] 2keep swap T{ button-down } = [
        [ spawner>> ]
        [ tbl:selected-row [ disp-string swap set-control-value ] [ 2drop ] if ]
        [ hide-glass ] tri
    ] [ drop ] if t ;

TUPLE: combobox < label-control table ;

combobox H{
   { T{ button-up } [ dup table>> over >>spawner <zero-rect> show-glass ] }
} set-gestures

: <combobox> ( options -- combobox )
    [ first [ combobox new-label ] [ disp-string <basic> ] bi >>model ] keep
    <basic> combo-table new-table white-interior [ 1array ] >>quot >>table 
    default-font-foreground-color get <solid> >>boundary ;
