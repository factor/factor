! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel math namespaces
       sequences words math.vectors ui.gadgets ui.gadgets.packs
       math.geometry.rect fry ;

IN: ui.gadgets.tracks

TUPLE: track < pack sizes ;

: normalized-sizes ( track -- seq )
  sizes>> dup sift sum '[ dup [ , / ] when ] map ;

: init-track ( track -- track )
  init-gadget
  V{ } clone >>sizes
  1          >>fill ;

: new-track ( orientation class -- track )
  new
    init-track
    swap >>orientation ;

: <track> ( orientation -- track ) track new-track ;

: alloted-dim ( track -- dim )
  [ children>> ] [ sizes>> ] bi { 0 0 }
  [ [ drop { 0 0 } ] [ pref-dim ] if v+ ] 2reduce ;

: available-dim ( track -- dim ) [ dim>> ] [ alloted-dim ] bi v- ;

: track-layout ( track -- sizes )
    [ available-dim ] [ children>> ] [ normalized-sizes ] tri
    [ [ over n*v ] [ pref-dim ] ?if ] 2map nip ;

M: track layout* ( track -- ) dup track-layout pack-layout ;

: track-pref-dims-1 ( track -- dim ) children>> pref-dims max-dim ;

: track-pref-dims-2 ( track -- dim )
  [ children>> pref-dims ] [ normalized-sizes ] bi
  [ [ v/n ] when* ] 2map
  max-dim
  [ >fixnum ] map ;

M: track pref-dim* ( gadget -- dim )
   [ track-pref-dims-1                           ]
   [ [ alloted-dim ] [ track-pref-dims-2 ] bi v+ ]
   [ orientation>>                               ]
   tri
   set-axis ;

: track-add* ( track gadget constraint -- track )
  pick sizes>> push add-gadget ;

: track-remove ( track gadget -- track )
  dupd dup
    [
      [ swap children>> index ]
      [ unparent sizes>>      ] 2bi
      delete-nth 
    ]
    [ 2drop ]
  if ;

: clear-track ( track -- ) V{ } clone >>sizes clear-gadget ;
