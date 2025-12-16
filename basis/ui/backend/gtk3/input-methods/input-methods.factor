! Copyright (C) 2011 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel ui.gadgets ;
IN: ui.backend.gtk3.input-methods

GENERIC: support-input-methods? ( gadget -- ? )
GENERIC: cursor-surrounding ( gadget -- text cursor-pos )
GENERIC: delete-cursor-surrounding ( offset count gadget -- )
GENERIC: cursor-loc&dim ( gadget -- loc dim )

M: gadget support-input-methods? drop f ;
