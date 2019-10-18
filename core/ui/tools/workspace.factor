! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: help arrays compiler gadgets gadgets-books
gadgets-browser gadgets-buttons gadgets-help gadgets-listener
gadgets-presentations gadgets-walker generic kernel math modules
scratchpad sequences syntax words inspector io namespaces
hashtables gadgets-scrolling gadgets-panes gadgets-tracks
gadgets-inspector gadgets-theme errors models quotations
listener shells threads prettyprint assocs ;
IN: gadgets-workspace

TUPLE: stack-display ;

C: stack-display ( -- gadget )
    g workspace-listener swap [
        dup <toolbar> f track,
        listener-gadget-stack [ stack. ]
        "Data stack" <labelled-pane> 1 track,
    ] { 0 1 } build-track ;

M: stack-display tool-scroller
    find-workspace workspace-listener tool-scroller ;

: workspace-tabs
    {
        { "Listener" <stack-display> }
        { "Definitions" <browser> }
        { "Documentation" <help-gadget> }
        { "Inspector" <inspector-gadget> }
        { "Walker" <walker-gadget> }
    } ;

: <workspace-tabs> ( -- tabs )
    g control-model
    "tool-switching" workspace command-map
    [ command-string ] { } assoc>map
    [ length ] keep 2array flip
    <radio-box> ;

: <workspace-book> ( -- gadget )
    workspace-tabs 1 <column> [ execute ] map
    g control-model <book> ;

M: workspace pref-dim* drop { 600 750 } ;

: init-workspace ( workspace -- )
    dup 0 <model> { 0 1 } <track> delegate>control [
        <listener-gadget> g set-workspace-listener
        <workspace-book> g set-workspace-book
    ] with-gadget ;

C: workspace ( -- workspace )
    dup init-workspace dup [
        <workspace-tabs> f track,
        g workspace-book 1/5 track,
        g workspace-listener 4/5 track,
        toolbar,
    ] with-gadget ;

: resize-workspace ( workspace -- )
    dup track-sizes over control-value zero? [
        1/5 1 pick set-nth
        4/5 2 rot set-nth
    ] [
        1/2 1 pick set-nth
        1/2 2 rot set-nth
    ] if relayout ;

M: workspace model-changed
    dup workspace-listener listener-gadget-output scroll>bottom
    dup resize-workspace
    request-focus ;

M: workspace focusable-child*
    dup workspace-popup [ ] [ workspace-listener ] ?if ;

: ui-listener-hook ( listener -- )
    >r datastack r> listener-gadget-stack set-model ;

: ui-error-hook ( error listener -- )
    find-workspace debugger-popup ;

: ui-inspector-hook ( obj listener -- )
    find-workspace inspector-gadget swap show-tool inspect ;

: listener-thread ( listener -- )
    dup listener-stream [
        dup [ ui-listener-hook ] curry listener-hook set
        dup [ ui-error-hook ] curry error-hook set
        dup [ ui-inspector-hook ] curry inspector-hook set
        [ yield ] compiler-hook set
        drop
        welcome.
        tty
    ] with-stream* ;

: restart-listener ( listener -- )
    [ >r clear r> init-namespaces listener-thread ] in-thread
    drop ;

: workspace-window ( -- workspace )
    <workspace> dup "Factor workspace" open-window
    dup workspace-listener restart-listener ;

: workspace-page ( workspace -- gadget )
    workspace-book current-page ;

M: workspace tool-scroller ( workspace -- scroller )
    workspace-page tool-scroller ;

: com-scroll-up ( workspace -- )
    tool-scroller [ scroll-up-page ] when* ;

: com-scroll-down ( workspace -- )
    tool-scroller [ scroll-down-page ] when* ;

[ workspace-window drop ] ui-hook set-global

workspace "scrolling"
"The current tool's scroll pane can be scrolled from the keyboard."
{
    { T{ key-down f { C+ } "PAGE_UP" } com-scroll-up }
    { T{ key-down f { C+ } "PAGE_DOWN" } com-scroll-down }
} define-command-map

: com-listener stack-display select-tool ;

: com-definitions browser select-tool ;

: com-documentation help-gadget select-tool ;

: com-inspector inspector-gadget select-tool ;

: com-walker walker-gadget select-tool ;

workspace "tool-switching" f {
    { T{ key-down f f "F2" } com-listener }
    { T{ key-down f f "F3" } com-definitions }
    { T{ key-down f f "F4" } com-documentation }
    { T{ key-down f f "F5" } com-inspector }
    { T{ key-down f f "F6" } com-walker }
} define-command-map

: new-workspace-window workspace-window drop ;

\ new-workspace-window
H{ { +nullary+ t } } define-command

\ reload-libs
H{ { +nullary+ t } { +listener+ t } } define-command

\ reload-core
H{ { +nullary+ t } { +listener+ t } } define-command

workspace "workflow" f {
    { T{ key-down f { C+ } "n" } new-workspace-window }
    { T{ key-down f f "ESC" } hide-popup }
    { T{ key-down f f "F8" } reload-libs }
    { T{ key-down f { A+ } "F8" } reload-core }
} define-command-map

: listener-help "ui-listener" help-window ;

\ listener-help H{ { +nullary+ t } } define-command

listener-gadget "toolbar" f {
    { f restart-listener }
    { T{ key-down f f "CLEAR" } clear-output }
    { T{ key-down f { C+ } "CLEAR" } clear-stack }
    { T{ key-down f { C+ } "d" } com-EOF }
    { T{ key-down f f "F1" } listener-help }
} define-command-map

M: listener-gadget handle-gesture* ( gadget gesture delegate -- ? )
    3dup drop swap find-workspace workspace-page handle-gesture
    [ default-gesture-handler ] [ 3drop f ] if ;
