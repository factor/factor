USING: ui.gadgets.buttons ui.gadgets.packs ui.gadgets ui
nehe.2 nehe.3 nehe.4 nehe.5 kernel ;
IN: nehe

: nehe-window
    [
        [
            "Nehe 2" [ drop run2 ] <bevel-button> gadget,
            "Nehe 3" [ drop run3 ] <bevel-button> gadget,
            "Nehe 4" [ drop run4 ] <bevel-button> gadget,
            "Nehe 5" [ drop run5 ] <bevel-button> gadget,
        ] make-filled-pile "Nehe examples" open-window
    ] with-ui ;

MAIN: nehe-window
