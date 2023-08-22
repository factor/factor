! Copyright (C) 2019 KUSUMOTO Norio
! See https://factorcode.org/license.txt for BSD license.
USING: kernel ui.gadgets ;
IN: ui.backend.cocoa.input-methods

GENERIC: support-input-methods? ( gadget -- ? )

M: gadget support-input-methods? drop f ;
