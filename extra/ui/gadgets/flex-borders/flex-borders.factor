! Copyright (C) 2019 Alexander Ilin.
USING: accessors arrays kernel locals math sequences
ui.gadgets ui.gadgets.tracks ;
IN: ui.gadgets.flex-borders

<PRIVATE

:: border ( gadget dim orientation -- gadget' )
    orientation <track>
        <gadget> dim >>dim f track-add
        gadget             1 track-add
        <gadget> dim >>dim f track-add ;

PRIVATE>

: <flex-border> ( gadget gaps -- gadget' )
    first2 [| w h |
        w 0 > [ w 0 2array horizontal border ] when
        h 0 > [ 0 h 2array vertical   border ] when
    ] call ;
