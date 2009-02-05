! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel namespaces fry
math math.vectors math.rectangles math.order
sequences words ui.gadgets ui.gadgets.packs ;
IN: ui.gadgets.tracks

TUPLE: track < pack sizes ;

: normalized-sizes ( track -- seq )
    sizes>> dup sift sum '[ dup [ _ / ] when ] map ;

: init-track ( track -- track )
    V{ } clone >>sizes
    1 >>fill ; inline

: new-track ( orientation class -- track )
    new-gadget
        init-track
        swap >>orientation ; inline

: <track> ( orientation -- track ) track new-track ;

: alloted-dim ( track -- dim )
    [ children>> ] [ sizes>> ] bi { 0 0 }
    [ [ drop { 0 0 } ] [ pref-dim ] if v+ ] 2reduce ;

: gap-dim ( track -- dim )
    [ gap>> ] [ children>> length 1 [-] ] bi v*n ;

: available-dim ( track -- dim )
    [ dim>> ] [ alloted-dim ] bi v- ;

: track-layout ( track -- sizes )
    [ [ available-dim ] [ gap-dim ] bi v- ]
    [ children>> ] [ normalized-sizes ] tri
    [ [ over n*v ] [ pref-dim ] ?if ] 2map nip ;

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

: track-add ( track gadget constraint -- track )
    pick sizes>> push add-gadget ;

: track-remove ( track gadget -- track )
    dupd dup [
        [ swap children>> index ]
        [ unparent sizes>> ] 2bi
        delete-nth 
    ] [ 2drop ] if ;

: clear-track ( track -- ) [ sizes>> delete-all ] [ clear-gadget ] bi ;
