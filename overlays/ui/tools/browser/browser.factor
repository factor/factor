USING: accessors arrays assocs classes combinators
combinators.short-circuit compiler.units debugger fonts help
help.apropos help.crossref help.home help.markup help.stylesheet
help.topics io.styles kernel literals make math math.vectors
models namespaces sequences sets system ui ui.commands
ui.gadgets ui.gadgets.borders ui.gadgets.editors
ui.gadgets.glass ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.toolbar ui.gadgets.tracks
ui.gadgets.viewports ui.gadgets.worlds ui.gestures ui.pens.solid
ui.theme ui.tools.browser.history ui.tools.browser.popups
ui.tools.common unicode vocabs math.parser ;
IN: ui.tools.browser

browser-gadget "navigation" "Commands for navigating in the article hierarchy" {
    { T{ key-down f ${ os macosx? M+ A+ ? } "UP" } com-up }
    { T{ key-down f ${ os macosx? M+ A+ ? } "p" } com-prev }
    { T{ key-down f ${ os macosx? M+ A+ ? } "n" } com-next }
    { T{ key-down f ${ os macosx? M+ A+ ? } "k" } com-show-outgoing-links }
    { T{ key-down f ${ os macosx? M+ A+ ? } "K" } com-show-incoming-links }
    { T{ key-down f ${ os macosx? M+ A+ ? } "f" } browser-focus-search }
} os macosx? [ {
    { T{ key-down f { M+ } "[" } com-back }
    { T{ key-down f { M+ } "]" } com-forward }
    { T{ button-down  f { M+ } 3 } com-back }
    { T{ button-down  f { M+ } 4 } com-forward }
} append ] when define-command-map

