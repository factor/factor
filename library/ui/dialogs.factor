IN: gadgets
USING: kernel namespaces threads ;

TUPLE: dialog continuation delegate ;

: dialog-ok ( dialog -- )
    dup unparent t swap dialog-continuation call ;

: dialog-cancel ( dialog -- )
    dup unparent f swap dialog-continuation call ;

: <dialog-buttons> ( -- gadget )
    <default-shelf>
    "OK" [ [ dialog-ok ] swap handle-gesture drop ]
    <button> over add-gadget
    "Cancel" [ [ dialog-cancel ] swap handle-gesture drop ]
    <button> over add-gadget ;

C: dialog ( content continuation -- gadget )
    [ set-dialog-continuation ] keep
    <default-pile> over set-dialog-delegate
    [ add-gadget ] keep
    [ >r <dialog-buttons> r> add-gadget ] keep
    ( bevel-border )
    dup moving-actions
    dup [ dialog-ok ] dup set-action
    dup [ dialog-cancel ] dup set-action ;

: <prompt> ( prompt -- gadget )
    0 default-gap <pile>
    [ >r <label> r> add-gadget ] keep
    [ >r "" <field> r> add-gadget ] keep ;

: <input-dialog> ( prompt continuation -- gadget )
    >r <prompt> r> <dialog> ;

: input-dialog ( prompt -- input )
    [ <input-dialog> world get add-gadget (yield) ] callcc1 ;
