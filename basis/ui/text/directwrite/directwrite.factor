! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays cache destructors fonts fonts.shaping kernel locals math math.order math.vectors namespaces opengl
sequences ui.gadgets.worlds ui.text ui.text.private ui.text.directwrite.tiles
ui.text.directwrite.transforms windows.directwrite
windows.directwrite.render ;
IN: ui.text.directwrite

SINGLETON: directwrite-renderer

M: directwrite-renderer draws-selection-background? t ;

M: directwrite-renderer draw-string*
    2dup cached-directwrite-layout size>> [ 512 > ] any? world get and [
        cached-directwrite-layout draw-directwrite-tiles
    ] [ draw-string-default ] if ;

M: directwrite-renderer string-dim
    cached-directwrite-layout metrics>>
    [ width>> ] [ height>> ] bi 2array scale-dim ;

M: directwrite-renderer measure-string-dim
    [
        dup selection? [ string>> ] when
        <directwrite-layout> &dispose metrics>>
        [ width>> ] [ height>> ] bi 2array scale-dim
    ] with-destructors ;

M: directwrite-renderer flush-layout-cache
    disposables get-global disposables [
        cached-directwrite-layouts get-global purge-cache
        directwrite-layout-aliases get-global purge-cache
    ] with-variable ;

M: directwrite-renderer string>image
    cached-directwrite-layout
    [ directwrite-layout>image ] [ origin>> vneg scale-dim ] bi ;

M: directwrite-renderer x>offset
    [ 2drop 0 ] [
        [ gl-scale ] 2dip cached-directwrite-layout directwrite-x>offset
    ] if-empty ;

M: directwrite-renderer offset>x
    [ 2drop 0 ] [
        cached-directwrite-layout directwrite-offset>x gl-unscale
    ] if-empty ;

M:: directwrite-renderer caret>x ( n trailing? font string -- x )
    string empty? [ 0 ] [
        n trailing? font string cached-directwrite-layout directwrite-caret>x gl-unscale
    ] if ;

M:: directwrite-renderer x>caret ( x font string -- n trailing? )
    string empty? [ 0 f ] [
        x gl-scale font string cached-directwrite-layout directwrite-x>caret
    ] if ;

M:: directwrite-renderer visual-caret-step ( n trailing? direction font string -- next affinity moved? )
    string aux>> font font-text-direction right-to-left = or [
        font string cached-directwrite-layout :> layout
        layout bidi?>> [
            n trailing? direction layout directwrite-visual-step
        ] [ n trailing? direction string logical-caret-step ] if
    ] [ n trailing? direction string logical-caret-step ] if ;

M:: directwrite-renderer visual-caret-edge ( right? font string -- n trailing? )
    string empty? [ 0 f ] [
        font string cached-directwrite-layout :> layout
        right? [ layout metrics>> width>> 1 + ] [ -1 ] if
        layout directwrite-x>caret
    ] if ;

M:: directwrite-renderer selection-spans ( start end font string -- spans )
    font string start end f <selection> cached-directwrite-layout
    directwrite-selection-rects [
        [ left>> ] [ [ left>> ] [ width>> ] bi + ] bi
        [ gl-unscale ] bi@ 2array
    ] map ;

M:: directwrite-renderer selection-caret ( start end right? font string -- n trailing? )
    start end font string selection-spans :> spans
    spans empty? [ start f ] [
        right? [ spans [ second ] map supremum 0.001 - ]
        [ spans [ first ] map infimum 0.001 + ] if
        font string x>caret
    ] if ;

M: directwrite-renderer font-metrics
    " " cached-directwrite-layout metrics>> clone scale-metrics f >>width ;

M: directwrite-renderer line-metrics
    cached-directwrite-layout metrics>> clone scale-metrics ;

directwrite-renderer font-renderer set-global
install-directwrite-transforms
