USING: accessors kernel ui ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.packs ;
FROM: opengl.demos.gl4 => gl4demo ;
FROM: opengl.demos.compute => gl4compute ;
IN: opengl.demos

MAIN-WINDOW: nehe-window { { title "Nehe Examples" } }
    <filled-pile>
        "OpenGL 4" [ drop gl4demo ] <border-button> add-gadget
        "OpenGL 4 Compute" [ drop gl4compute ] <border-button> add-gadget
    { 2 2 } <border> >>gadgets ;

MAIN: nehe-window
