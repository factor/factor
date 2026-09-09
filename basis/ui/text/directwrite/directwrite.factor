! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays cache kernel math math.vectors namespaces opengl
sequences ui.gadgets.worlds ui.text ui.text.private ui.text.directwrite.tiles windows.directwrite
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

M: directwrite-renderer flush-layout-cache
    cached-directwrite-layouts get-global purge-cache ;

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

M: directwrite-renderer font-metrics
    " " cached-directwrite-layout metrics>> clone scale-metrics f >>width ;

M: directwrite-renderer line-metrics
    cached-directwrite-layout metrics>> clone scale-metrics ;

directwrite-renderer font-renderer set-global
