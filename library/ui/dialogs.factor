IN: gadgets
USING: generic kernel namespaces threads ;

TUPLE: dialog continuation ;

: dialog-action ( dialog ? -- )
    over close-tile swap dialog-continuation call ;

: dialog-ok ( dialog -- ) t dialog-action ;

: dialog-cancel ( dialog -- ) f dialog-action ;

: <dialog-buttons> ( -- gadget )
    <default-shelf>
    "OK" [ dialog-ok ] <button> over add-gadget
    "Cancel" [ dialog-cancel ] <button> over add-gadget ;

: dialog-actions ( dialog -- )
    dup [ dialog-ok ] dup set-action
    [ dialog-cancel ] dup set-action ;

C: dialog ( content continuation -- gadget )
    [ set-dialog-continuation ] keep
    [ <empty-gadget> swap set-delegate ] keep
    [
        >r <default-pile>
        [ add-gadget ] keep
        [ <dialog-buttons> swap add-gadget ] keep
        r> add-gadget
    ] keep
    [ dialog-actions ] keep ;

: dialog ( content title -- ? )
    #! Show a modal dialog and wait until OK or Cancel is
    #! clicked. Outputs a true value if OK was clicked.
    [ swap >r <dialog> r> tile stop ] callcc1 2nip ;

TUPLE: prompt editor ;

C: prompt ( prompt -- gadget )
    0 default-gap 0 <pile> over set-delegate
    [ >r <label> r> add-gadget ] keep
    "" <editor> over set-prompt-editor
    dup prompt-editor line-border over add-gadget ;

: input-dialog ( prompt -- input )
    #! Show an input dialog and resume the current continuation
    #! when the user clicks OK or Cancel. If they click Cancel,
    #! push f.
    <prompt> dup "Input" dialog [
        prompt-editor editor-text
    ] [
        drop f
    ] ifte ;
