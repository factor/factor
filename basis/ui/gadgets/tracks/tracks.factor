! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math math.vectors sequences
ui.gadgets ui.gadgets.packs ui.gadgets.packs.private ;
IN: ui.gadgets.tracks

TUPLE: track < pack sizes ;

: new-track ( orientation class -- track )
    new
        1 >>fill
        V{ } clone >>sizes
        swap >>orientation ; inline

: <track> ( orientation -- track ) track new-track ;

<PRIVATE

: normalized-sizes ( track -- seq )
    sizes>> dup sift sum '[ dup [ _ / ] when ] map ;

: alloted-dim ( track -- dim )
    [ children>> ] [ sizes>> ] bi { 0 0 }
    [ [ drop ] [ pref-dim v+ ] if ] 2reduce ;

: available-dim ( track -- dim )
    [ dim>> ] [ alloted-dim ] bi v- ;

: track-layout ( track -- sizes )
    {
        [ children>> pref-dims ]
        [ normalized-sizes ]
        [ [ available-dim ] [ gap-dim ] bi v- ]
        [ orientation>> ]
    } cleave
    '[ [ _ n*v _ set-axis ] when* ] 2map ;

M: track layout* dup track-layout pack-layout ;

: track-pref-dims-1 ( track -- dim )
    [ children>> pref-dims max-dims ]
    [ pref-dim>> { 0 0 } or ] bi vmax ;

: track-pref-dims-2 ( track -- dim )
    [
        [ children>> pref-dims ] [ normalized-sizes ] bi
        [ dup { 0 f } member? [ 2drop { 0 0 } ] [ v/n ] if ] 2map
        max-dims
    ] [ gap-dim ] bi v+ ;

M: track pref-dim*
    [ track-pref-dims-1 ]
    [ [ alloted-dim ] [ track-pref-dims-2 ] bi v+ ]
    [ orientation>> ]
    tri
    set-axis ;

PRIVATE>

: track-add ( track gadget constraint -- track )
    pick sizes>> push add-gadget ;

M: track remove-gadget
    [ [ children>> index ] [  sizes>> ] bi remove-nth! drop ]
    [ call-next-method ] 2bi ;

: clear-track ( track -- ) [ sizes>> delete-all ] [ clear-gadget ] bi ;
