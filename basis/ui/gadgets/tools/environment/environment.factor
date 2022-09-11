! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code code.execution code.import-export
combinators kernel listener locals memory models namespaces
sequences ui ui.commands ui.gadgets ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.tracks ui.gadgets.worlds
ui.gestures ui.pixel-formats ui.tools.browser ui.tools.common
ui.gadgets.tools.environment.cell ui.gadgets.tools.environment.navigation
ui.tools.environment.theme ;
FROM: models => change-model ;
IN: ui.tools.environment

TUPLE: environment < tool ;

environment { 700 600 } set-tool-dim

:: <environment> ( -- gadget )
    skov-root get-global <model> :> model
    vertical environment new-track model >>model
    model <navigation> <scroller> 1 track-add
    with-background ;

: environment-window ( -- )
    [ <environment>
      <world-attributes> 
      { windowed double-buffered multisampled
        T{ samples f 4 } T{ sample-buffers f 1 } }
      >>pixel-format-attributes
      "Skov" >>title open-status-window ] with-ui ;

: save-image-and-vocabs ( env -- )
    drop save export-vocabs ;

: load-vocabs ( env -- )
    update-skov-root skov-root get-global swap set-control-value ;

environment H{
    { T{ key-down f { C+ } "h" } [ drop show-browser ] }
    { T{ key-down f { C+ } "H" } [ drop show-browser ] }
    { save-action [ save-image-and-vocabs ] }
    { open-action [ load-vocabs ] }
} set-gestures
