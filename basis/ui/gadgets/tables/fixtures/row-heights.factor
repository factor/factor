USING: kernel parser sequences vocabs.refresh ;
<<
! Test changed checkout sources without recompiling unchanged image definitions.
{
    "resource:basis/windows/dwmapi/dwmapi.factor"
    "resource:basis/opengl/textures/textures.factor"
    "resource:basis/ui/gestures/gestures.factor"
    "resource:basis/ui/text/text.factor"
    "resource:basis/ui/render/render.factor"
    "resource:basis/ui/gadgets/worlds/worlds.factor"
    "resource:basis/ui/gadgets/line-support/line-support.factor"
    "resource:basis/ui/gadgets/tables/tables.factor"
    "resource:basis/ui/ui.factor"
    "resource:basis/ui/backend/windows/windows.factor"
} [ dup source-modified? [ run-file ] [ drop ] if ] each
>>
USING: accessors arrays byte-arrays colors command-line continuations
io kernel locals math math.vectors models namespaces opengl
opengl.capabilities opengl.gl sequences system tools.test ui ui.backend
ui.backend.windows ui.gadgets ui.gadgets.private ui.gadgets.tables
ui.gadgets.tables.private ui.gadgets.worlds ui.gestures ui.private
ui.render windows.user32 ;
IN: ui.gadgets.tables.row-heights-fixture

TUPLE: colored-cell height color ;
C: <colored-cell> colored-cell
M: colored-cell cell-dim nip [ drop 12 ] [ height>> ] [ drop 0 ] tri ;
M: colored-cell draw-cell
    nip [ color>> gl-color ] [ height>> 12 swap 2array ] bi
    { 0 0 } swap gl-fill-rect ;

:: table-pixel ( table window point -- rgb )
    table screen-loc point v+ first2 :> ( x y )
    window dim>> second y - :> flipped
    4 <byte-array> :> pixel
    GL_FRONT glReadBuffer
    x gl-scale >fixnum flipped gl-scale >fixnum
    1 1 GL_RGBA GL_UNSIGNED_BYTE pixel glReadPixels
    gl-error pixel 3 head ;

:: check-rows ( table window -- )
    window set-gl-context window layout
    window t >>active? draw-world
    table window { 5 5 } table-pixel B{ 255 0 0 } assert=
    table window { 5 20 } table-pixel B{ 0 128 0 } assert=
    table window { 5 50 } table-pixel B{ 0 0 255 } assert=
    ! Native-world pointer coordinates must select the row actually drawn there.
    table screen-loc { 5 20 } v+ hand-loc set-global
    table mouse-row 1 assert=
    table table-button-down
    table selection-index>> value>> 1 assert=
    table screen-loc { 5 50 } v+ hand-loc set-global
    table mouse-row 2 assert=
    table table-button-down
    table selection-index>> value>> 2 assert=
    "ROW-HEIGHTS-PASS" print ;

:: row-heights-test ( -- )
    command-line get first "gl3" = [
        [ "3.0" has-gl-version? [ setup-gl3-hooks gl3-init ] [ gl-init-legacy ] if ]
        gl-init-hook set-global
    ] when
    init-win32-ui
    10 COLOR: red <colored-cell> 1array
    30 COLOR: green <colored-cell> 1array
    20 COLOR: blue <colored-cell> 1array
    3array <model> trivial-renderer <table> 10 >>line-height :> table
    <world-attributes> "Table row height regression" >>title
        table 1array >>gadgets <world>
        { -32000 -32000 } >>window-loc :> window
    [
        window open-world-window notify-queued
        window handle>> hWnd>> SW_SHOWNOACTIVATE ShowWindow drop
        table window check-rows
    ] [
        [ window ungraft notify-queued ] [ cleanup-win32-ui ] finally
    ] finally ;

row-heights-test
0 exit
