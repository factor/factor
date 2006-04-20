! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic inference io kernel math
namespaces prettyprint sequences vectors words ;

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

: sufficient-shuffle-vregs? ( shuffle -- ? )
    dup shuffle-in-d length phantom-d get length - 0 max
    over shuffle-in-r length phantom-r get length - 0 max +
    free-vregs get length <= ;

: phantom-shuffle ( shuffle -- )
    compute-free-vregs sufficient-shuffle-vregs? [
        end-basic-block compute-free-vregs
    ] unless
    [ phantom-shuffle-inputs ] keep
    [ shuffle* ] keep adjust-shuffle
    (template-outputs) ;

M: #shuffle linearize* ( #shuffle -- )
    node-shuffle phantom-shuffle iterate-next ;
