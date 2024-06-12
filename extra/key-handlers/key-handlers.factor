! Copyright (C) 2009 Sam Anklesaria.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel ui.gadgets.borders ui.gestures ;
IN: key-handlers

TUPLE: key-handler < border handlers ;
: <keys> ( gadget -- key-handler ) key-handler new-border { 0 0 } >>size ;

M: key-handler handle-gesture
    [ handlers>> at ] 1guard [ call( gadget -- ) f ] [ drop t ] if* ;
