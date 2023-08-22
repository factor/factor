! Copyright (C) 2012 Anonymous.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar images images.viewer kernel math
math.parser models random sequences timers ui ui.gadgets
ui.gadgets.status-bar ui.gadgets.worlds ;
IN: rosetta-code.image-noise

: bits>pixels ( bits -- bits' pixels )
    [ -1 shift ] [ 1 bitand ] bi 255 * ; inline

: ?generate-more-bits ( a bits -- a bits' )
    over 32 mod zero? [ drop random-32 ] when ; inline

: <random-images-bytes> ( dim -- bytes )
    [ 0 0 ] dip product  [
        ?generate-more-bits
        [ 1 + ] [ bits>pixels ] bi*
    ] B{ } replicate-as 2nip ;

: <random-bw-image> ( -- image )
    <image>
        { 320 240 } [ >>dim ] [ <random-images-bytes> >>bitmap ] bi
        L >>component-order
        ubyte-components >>component-type ;

TUPLE: bw-noise-gadget < image-control timers cnt old-cnt ;

: animate-image ( control -- )
    [ 1 + ] change-cnt
    model>> <random-bw-image> swap set-model ;

: update-cnt ( gadget -- )
    [ cnt>> ] [ old-cnt<< ] bi ;

: fps ( gadget -- fps )
    [ cnt>> ] [ old-cnt>> ] bi -
    number>string "FPS: " prepend ;

: fps-monitor ( gadget -- )
    [ fps ] [ update-cnt ] [ show-status ] tri ;

: start-animation ( gadget -- )
    [ [ animate-image ] curry 1 nanoseconds every ] [ timers>> push ] bi ;

: start-fps ( gadget -- )
    [ [ fps-monitor ] curry 1 seconds every ] [ timers>> push ] bi ;

: setup-timers ( gadget -- )
    [ start-animation ] [ start-fps ] bi ;

: stop-animation ( gadget -- )
    timers>> [ [ stop-timer ] each ] [ delete-all ] bi ;

M: bw-noise-gadget graft* [ call-next-method ] [ setup-timers ] bi ;

M: bw-noise-gadget ungraft* [ stop-animation ] [ call-next-method ] bi ;

: <bw-noise-gadget> ( -- gadget )
    <random-bw-image> <model> bw-noise-gadget new-image-gadget*
    0 >>cnt 0 >>old-cnt V{ } clone >>timers ;

: open-noise-window ( -- )
    [ <bw-noise-gadget> "Black and White noise" open-status-window ] with-ui ;

MAIN: open-noise-window
