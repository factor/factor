USING: parser ;
<<
"resource:basis/windows/dwmapi/dwmapi.factor" run-file
"resource:basis/opengl/textures/textures.factor" run-file
"resource:basis/ui/render/render.factor" run-file
"resource:basis/ui/gadgets/worlds/worlds.factor" run-file
"resource:basis/ui/gadgets/line-support/line-support.factor" run-file
"resource:basis/ui/text/text.factor" run-file
"resource:basis/windows/directwrite/directwrite.factor" run-file
"resource:basis/ui/text/directwrite/directwrite.factor" run-file
"resource:basis/ui/gadgets/editors/editors.factor" run-file
"resource:basis/ui/ui.factor" run-file
"resource:basis/ui/backend/windows/windows.factor" run-file
"resource:basis/windows/directwrite/render/render.factor" run-file
>>
USING: accessors alien.c-types alien.data arrays byte-arrays classes
colors command-line continuations destructors io kernel locals math
namespaces opengl opengl.capabilities opengl.gl prettyprint sequences system tools.test
ui ui.backend ui.backend.windows ui.gadgets ui.gadgets.borders
ui.gadgets.editors ui.gadgets.editors.private ui.gadgets.private
ui.gadgets.worlds ui.private ui.render windows.user32 ;
IN: ui.gadgets.editors.caret-fixture

SYMBOL: scene-draw-count
TUPLE: counted-gadget < gadget ;
M: counted-gadget pref-dim* drop { 150 40 } ;
M: counted-gadget draw-gadget*
    scene-draw-count [ 1 + ] change-global
    COLOR: blue gl-color { 0 0 } swap dim>> gl-fill-rect ;

:: window-pixels ( window -- pixels )
    window set-gl-context
    GL_READ_FRAMEBUFFER 0 glBindFramebuffer
    GL_FRONT glReadBuffer
    window caret-scene-dim :> dim
    dim product 4 * <byte-array> :> pixels
    0 0 dim first2 GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error pixels ;

:: check-caret ( window editor -- )
    window set-gl-context
    editor focus-editor editor stop-blinking
    window layout
    ! A harmless layer disables retention, giving an ordinary render reference.
    window t >>active? <gadget> 1array >>layers draw-world
    window caret-scene>> f assert=
    window window-pixels :> ordinary
    window f >>layers draw-world
    window caret-scene>> :> scene
    scene >boolean t assert=
    window window-pixels :> visible
    visible ordinary assert=
    scene-draw-count get-global :> initial-count
    editor blink-caret { } redraw-caret-worlds
    window window-pixels visible = f assert=
    editor blink-caret { } redraw-caret-worlds
    window window-pixels visible assert=
    8 [ editor blink-caret { } redraw-caret-worlds ] times
    scene-draw-count get-global initial-count assert=
    ! A normal redraw refreshes retained content and an existing texture.
    editor "Changed text" swap set-editor-string
    editor stop-blinking
    window layout window draw-world
    scene-draw-count get-global initial-count > t assert=
    window window-pixels :> edited
    editor blink-caret { } redraw-caret-worlds
    editor blink-caret { } redraw-caret-worlds
    window window-pixels edited assert=
    ! Resizing must refresh both the snapshot dimensions and the clip.
    window { 420 260 } resize-window
    window layout window draw-world
    scene dim>> window caret-scene-dim assert=
    window window-pixels :> resized
    editor blink-caret { } redraw-caret-worlds
    editor blink-caret { } redraw-caret-worlds
    window window-pixels resized assert=
    "CARET-PASS " write initial-count . scene-draw-count get-global .
    ! Each caret shape must match ordinary rendering, including its background.
    { +line+ +box+ +filled+ } [| shape |
        editor shape >>caret-shape drop
        window <gadget> 1array >>layers draw-world
        window window-pixels :> reference
        window f >>layers draw-world
        window window-pixels reference assert=
        scene-draw-count get-global :> before-blink
        editor blink-caret { } redraw-caret-worlds
        editor blink-caret { } redraw-caret-worlds
        window window-pixels reference assert=
        scene-draw-count get-global before-blink assert=
    ] each
    ! Losing focus releases the texture; regaining focus creates another.
    window caret-scene>> :> focused-scene
    editor unfocus-editor window draw-world
    window caret-scene>> f assert=
    focused-scene disposed>> t assert=
    editor focus-editor editor stop-blinking window draw-world
    window caret-scene>> >boolean t assert= ;

:: caret-test ( -- )
    command-line get first "gl3" = [
        [
            "3.0" has-gl-version? [ setup-gl3-hooks gl3-init ] [ gl-init-legacy ] if
        ] gl-init-hook set-global
    ] when
    init-win32-ui
    0 scene-draw-count set-global
    <editor> :> editor
    "Unicode: Ω 日本 😀" editor set-editor-string
    editor { 12 12 } <filled-border> t >>clipped? :> border
    <world-attributes> "Caret redraw regression" >>title
        { 340 220 } >>pref-dim
        border counted-gadget new 2array >>gadgets <world>
        { -32000 -32000 } >>window-loc :> window
    [
        window open-world-window notify-queued
        ! Override STARTF_USESHOWWINDOW inherited from a hidden test process.
        window handle>> hWnd>> SW_SHOWNOACTIVATE ShowWindow drop
        window set-gl-context
        "3.0" has-gl-version? [ window editor check-caret ] [
            editor focus-editor editor stop-blinking
            window layout window t >>active? draw-world
            window caret-scene>> f assert=
            "CARET-PASS fallback" print
        ] if
    ] [
        window caret-scene>> :> closing-scene
        [
            window ungraft notify-queued
            closing-scene [ disposed>> t assert= ] when*
            window caret-scene>> f assert=
        ] [ cleanup-win32-ui ] finally
    ] finally ;

caret-test
0 exit
