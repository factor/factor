! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Run with a UI image and Raylib installed: -run=raylib.live-coding.smoke-test
USING: accessors alien calendar continuations debugger io
io.directories io.encodings.utf8 io.files io.files.temp
io.files.unique io.pathnames kernel locals math namespaces
opengl.gl parser prettyprint raylib raylib.live-coding
raylib.live-coding.contexts sequences system threads tools.test
ui ui.commands ui.gadgets ui.gadgets.worlds ui.tools.debugger
ui.tools.listener vocabs vocabs.loader vocabs.refresh words ;
QUALIFIED: ui
IN: raylib.live-coding.smoke-test

SYMBOLS: test-world fixture-root frame-count resumed? reloaded?
    closed? game-context ;

CONSTANT: fixture-name "raylib-live-coding-fixture"

: fixture-path ( -- path )
    fixture-root get-global
    "raylib-live-coding-fixture/raylib-live-coding-fixture.factor" append-path ;

:: write-fixture ( color -- )
    "USING: raylib ; IN: raylib-live-coding-fixture\n: color ( -- color ) "
    color " ;\n: paint ( -- ) color clear-background ;\n" 3append
    fixture-path utf8 set-file-contents ;

: paint ( -- )
    "paint" fixture-name lookup-word execute( -- ) ;

: fail ( error -- * )
    print-error :c
    "Last frame: " write frame-count get-global . flush 1 exit ;

:: wait-until ( quot: ( -- ? ) -- )
    nano-count 15000000000 + :> deadline
    [ quot call not ] [
        nano-count deadline > [ "Live-coding smoke test timed out" throw ] when
        10 milliseconds sleep
    ] while ; inline

: find-debugger ( gadget -- debugger/f )
    dup debugger? [
        children>> [ find-debugger ] map sift ?first
    ] unless ; recursive

:: choose-restart ( name -- )
    [ test-world get-global find-debugger >boolean ] wait-until
    test-world get-global find-debugger :> popup
    popup error>> print-error flush
    popup restarts>> [ name>> name = ] find nip
    dup [ ] [ "Expected live-coding restart is missing" throw ] if
    \ continue-restart invoke-command
    popup restart-list>> dup hook>> call( table -- ) ;

: reload-from-listener ( -- )
    "BLUE" write-fixture
    fixture-name refresh
    "color" fixture-name lookup-word execute( -- color ) BLUE assert=
    t reloaded? set-global ;

: frame ( -- )
    game-context get-global current-context assert=
    frame-count [ 1 + ] change-global
    frame-count get-global 30 = [ "Continue smoke test" throw ] when
    frame-count get-global 90 = [ "Close smoke test" throw ] when
    begin-drawing paint end-drawing
    glGetError GL_NO_ERROR assert= ;

: game ( -- )
    320 240 "Raylib live-coding smoke test" init-window
    [
        current-context game-context set-global
        60 set-target-fps
        [ frame ] until-window-should-close-with-live-coding
        t closed? set-global
    ] [ raylib:close-window ] finally ;

: supervise ( -- )
    "Waiting for Continue restart" print flush
    "Continue" choose-restart
    "Continue selected" print flush
    [ frame-count get-global 40 >= ] wait-until
    t resumed? set-global
    [ reload-from-listener ] \ run call-listener
    [ reloaded? get-global ] wait-until
    "Reload completed; waiting for Close restart" print flush
    "Close window" choose-restart
    [ closed? get-global ] wait-until
    resumed? get-global t assert=
    frame-count get-global 90 assert=
    "Raylib live coding: context switching, reload, Continue, and Close passed." print flush
    fixture-root get-global delete-tree
    ui:close-all-windows
    0 exit ;

: smoke-test ( -- )
    [ unique-directory ] with-temp-directory fixture-root set-global
    fixture-root get-global add-vocab-root
    fixture-path parent-directory make-directories
    "RED" write-fixture
    fixture-name require
    "color" fixture-name lookup-word execute( -- color ) RED assert=
    0 frame-count set-global
    f resumed? set-global f reloaded? set-global f closed? set-global
    [ fail ] ui-error-hook set-global
    [
        listener-window* find-world test-world set-global
        [ [ game ] with-live-coding ] \ run call-listener
        [ [ supervise ] [ fail ] recover ] "Live-coding smoke test" spawn drop
    ] with-ui ;

MAIN: smoke-test
