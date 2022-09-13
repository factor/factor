USING: accessors debugger fry kernel ui.gadgets
ui.gadgets.borders ui.gadgets.buttons.activate ui.gadgets.panes
ui.gadgets.status-bar ui.gadgets.tracks ui.gadgets.worlds
ui.pixel-formats ;
IN: ui.tools.browser

: <help-header> ( browser-gadget -- gadget )
    horizontal <track> swap model>> 
    [ [ '[ _ $title ] try ] <pane-control> 1 track-add ]
    [ <active/inactive> { 5 0 } <border> f track-add ] bi ;

: (browser-window) ( topic -- )
    <browser-gadget>
    <world-attributes>
        "Browser" >>title
        { windowed double-buffered multisampled
          T{ samples f 4 } T{ sample-buffers f 1 } }
        >>pixel-format-attributes
    open-status-window ;
