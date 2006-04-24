! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic inference io kernel math
namespaces prettyprint sequences vectors words ;

: immediate? ( obj -- ? ) dup fixnum? swap not or ;

: load-literal ( obj dest -- )
    over immediate? [ %immediate ] [ %indirect ] if , ;

: phantom-shuffle-input ( n phantom -- seq )
    2dup length <= [
        cut-phantom
    ] [
        [ phantom-locs ] keep [ length swap head-slice* ] keep
        [ append 0 ] keep set-length
    ] if ;

: phantom-shuffle-inputs ( shuffle -- locs locs )
    dup shuffle-in-d length phantom-d get phantom-shuffle-input
    swap shuffle-in-r length phantom-r get phantom-shuffle-input ;

: adjust-shuffle ( shuffle -- )
    dup shuffle-in-d length neg phantom-d get adjust-phantom
    shuffle-in-r length neg phantom-r get adjust-phantom ;

: shuffle-vregs# ( shuffle -- n )
    dup shuffle-in-d swap shuffle-in-r additional-vregs# ;

: phantom-shuffle ( shuffle -- )
    dup shuffle-vregs# ensure-vregs
    [ phantom-shuffle-inputs ] keep
    [ shuffle* ] keep adjust-shuffle
    (template-outputs) ;

M: #shuffle linearize* ( #shuffle -- )
    node-shuffle phantom-shuffle iterate-next ;

: linearize-push ( node -- )
    >#push< dup length dup ensure-vregs
    alloc-reg# [ <vreg> ] map
    [ [ load-literal ] 2each ] keep
    phantom-d get phantom-append ;

M: #push linearize* ( #push -- )
    linearize-push iterate-next ;
