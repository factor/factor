USING: ui.gadgets.buttons ui.gadgets.packs ui.gadgets ui
nehe.2 nehe.3 nehe.4 nehe.5 kernel accessors ;
IN: nehe

MAIN-WINDOW: nehe-window { { title "Nehe Examples" } }
    <filled-pile>
        "Nehe 2" [ drop run2 ] <border-button> add-gadget
        "Nehe 3" [ drop run3 ] <border-button> add-gadget
        "Nehe 4" [ drop run4 ] <border-button> add-gadget
        "Nehe 5" [ drop run5 ] <border-button> add-gadget
        >>gadgets ;

MAIN: nehe-window
