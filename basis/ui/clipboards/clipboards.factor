! Copyright (C) 2006, 2007 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: kernel accessors ui.gadgets ui.gestures namespaces ;

IN: ui.clipboards

! Two text transfer buffers

TUPLE: clipboard contents ;

GENERIC: clipboard-contents ( clipboard -- string )

GENERIC: set-clipboard-contents ( string clipboard -- )

M: clipboard clipboard-contents contents>> ;

M: clipboard set-clipboard-contents contents<< ;

: <clipboard> ( -- clipboard ) "" clipboard boa ;

GENERIC: paste-clipboard ( gadget clipboard -- )

M: object paste-clipboard
    clipboard-contents [ swap user-input ] [ drop ] if* ;

GENERIC: copy-clipboard ( string gadget clipboard -- )

M: object copy-clipboard nip set-clipboard-contents ;

SYMBOL: clipboard
SYMBOL: selection

: gadget-copy ( gadget clipboard -- )
    over gadget-selection?
        [ [ [ gadget-selection ] keep ] dip copy-clipboard ]
        [ 2drop ]
    if ;

: com-copy ( gadget -- ) clipboard get gadget-copy ;

: com-copy-selection ( gadget -- ) selection get gadget-copy ;

: >clipboard ( string -- )
    clipboard get set-clipboard-contents ;

: clipboard> ( -- string )
    clipboard get clipboard-contents ;
