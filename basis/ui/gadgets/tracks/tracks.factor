! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel namespaces fry math math.vectors
math.rectangles math.order sequences words ui.gadgets ui.gadgets.packs
ui.gadgets.packs.private combinators ;
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

M: track layout* ( track -- ) dup track-layout pack-layout ;

: track-pref-dims-1 ( track -- dim )
    children>> pref-dims max-dim ;

: track-pref-dims-2 ( track -- dim )
    [
        [ children>> pref-dims ] [ normalized-sizes ] bi
        [ dup { 0 f } member? [ 2drop { 0 0 } ] [ v/n ] if ] 2map
        max-dim [ >fixnum ] map
    ] [ gap-dim ] bi v+ ;

M: track pref-dim* ( gadget -- dim )
    [ track-pref-dims-1 ]
    [ [ alloted-dim ] [ track-pref-dims-2 ] bi v+ ]
    [ orientation>> ]
    tri
    set-axis ;

PRIVATE>

: track-add ( track gadget constraint -- track )
    pick sizes>> push add-gadget ;

M: track remove-gadget
    [ [ children>> index ] [  sizes>> ] bi delete-nth ]
    [ call-next-method ] 2bi ;

: clear-track ( track -- ) [ sizes>> delete-all ] [ clear-gadget ] bi ;
