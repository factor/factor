IN: gadgets
USING: kernel namespaces threads ;

TUPLE: dialog continuation delegate ;

: dialog-action ( ok dialog -- )
    dup unparent  dialog-continuation call ;

: dialog-ok ( dialog -- )
    t swap dialog-action ;

: dialog-cancel ( dialog -- )
    f swap dialog-action ;

: <dialog-buttons> ( -- gadget )
    <default-shelf>
    "OK" [ [ dialog-ok ] swap handle-gesture drop ]
    <button> over add-gadget
    "Cancel" [ [ dialog-cancel ] swap handle-gesture drop ]
    <button> over add-gadget ;

: dialog-actions ( dialog -- )
    dup [ dialog-ok ] dup set-action
    [ dialog-cancel ] dup set-action ;

C: dialog ( content -- gadget )
    [ f line-border swap set-dialog-delegate ] keep
    [
        >r <default-pile>
        [ add-gadget ] keep
        [ <dialog-buttons> swap add-gadget ] keep
        r> add-gadget
    ] keep
    [ dialog-actions ] keep ;

: <prompt> ( prompt -- gadget )
    0 default-gap 0 <pile>
    [ >r <label> r> add-gadget ] keep
    [ >r "" <field> r> add-gadget ] keep ;

: <input-dialog> ( prompt continuation -- gadget )
    >r <prompt> <dialog> r> over set-dialog-continuation ;

: input-dialog ( prompt -- input )
    #! Show an input dialog and resume the current continuation
    #! when the user clicks OK or Cancel. If they click Cancel,
    #! push f.
    [ <input-dialog> world get add-gadget (yield) ] callcc1 ;
