USING: parser ;
<<
"resource:basis/windows/dwmapi/dwmapi.factor" run-file
"resource:basis/opengl/textures/textures.factor" run-file
"resource:basis/ui/render/render.factor" run-file
"resource:basis/ui/gadgets/worlds/worlds.factor" run-file
"resource:basis/ui/gadgets/line-support/line-support.factor" run-file
"resource:basis/ui/gadgets/editors/editors.factor" run-file
"resource:basis/ui/ui.factor" run-file
"resource:basis/ui/backend/windows/windows.factor" run-file
>>
USING: accessors alien.c-types alien.data arrays byte-arrays colors
command-line continuations destructors images io kernel locals math math.bitwise math.vectors
namespaces opengl opengl.capabilities opengl.gl opengl.textures prettyprint
sequences system tools.test ui ui.backend ui.backend.windows
ui.gadgets ui.gadgets.private ui.gadgets.worlds ui.private ui.render ui.theme
windows.dwmapi windows.types windows.user32 ;
IN: ui.backend.windows.startup-fixture

SYMBOL: frame-count
TUPLE: startup-gadget < gadget ;
M: startup-gadget pref-dim* drop { 160 100 } ;
M: startup-gadget draw-gadget*
    drop frame-count [ 1 + ] change-global
    COLOR: green gl-color { 10 10 } { 30 30 } gl-fill-rect
    ! Opaque native text bitmaps use BGRX; zero padding must not become alpha.
    <image> { 30 30 } >>dim
        900 [ B{ 20 40 200 0 } ] replicate concat >>bitmap
        BGRX >>component-order ubyte-components >>component-type
    { 60 10 } <texture> [ draw-texture ] with-disposal ;

:: window-attribute ( hwnd attribute -- value supported? )
    0 DWORD <ref> :> value
    hwnd attribute value DWORD heap-size DwmGetWindowAttribute
    value DWORD deref swap zero? ;

:: front-pixel ( x y -- rgb )
    GL_FRONT glReadBuffer
    4 <byte-array> :> pixel
    x y 1 1 GL_RGBA GL_UNSIGNED_BYTE pixel glReadPixels
    gl-error pixel 3 head ;

:: check-startup ( window -- )
    window handle>> :> handle
    handle hWnd>> :> hwnd
    handle initial-cloak?>> :> cloaked?
    hwnd DWMWA_CLOAKED window-attribute [
        1 bitand zero? not cloaked? assert=
    ] [ drop ] if
    frame-count get-global 0 assert=
    window background-color>> content-background color= t assert=
    hwnd DWMWA_USE_IMMERSIVE_DARK_MODE window-attribute
    [ zero? not t assert= ] [ drop ] if
    window set-gl-context window layout
    window t >>active? draw-world
    frame-count get-global 1 assert=
    handle initial-cloak?>> f assert=
    hwnd DWMWA_CLOAKED window-attribute
    [ 1 bitand 0 assert= ] [ drop ] if
    ! The first frame already has both the theme background and gadget pixels.
    80 50 front-pixel B{ 32 33 36 } assert=
    window children>> first loc>> { 20 20 } v+ first2
    window dim>> second swap -
    [ gl-scale >fixnum ] bi@ front-pixel B{ 0 128 0 } assert=
    window children>> first loc>> { 70 20 } v+ first2
    window dim>> second swap -
    [ gl-scale >fixnum ] bi@ front-pixel B{ 200 40 20 } assert=
    "STARTUP-PASS " write cloaked? . ;

:: startup-test ( -- )
    command-line get first "gl3" = [
        [
            "3.0" has-gl-version? [ setup-gl3-hooks gl3-init ] [ gl-init-legacy ] if
        ] gl-init-hook set-global
    ] when
    dark-theme theme set-global
    init-win32-ui 0 frame-count set-global
    <world-attributes> "First frame regression" >>title
        startup-gadget new 1array >>gadgets <world>
        { -32000 -32000 } >>window-loc :> window
    [
        window open-world-window notify-queued
        window handle>> hWnd>> SW_SHOWNOACTIVATE ShowWindow drop
        window check-startup
    ] [
        [ window ungraft notify-queued ] [ cleanup-win32-ui ] finally
    ] finally ;

startup-test
0 exit
