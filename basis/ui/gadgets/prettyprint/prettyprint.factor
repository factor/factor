! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.gadgets prettyprint.backend prettyprint.custom ;
IN: ui.gadgets.prettyprint

! Don't print gadgets with RECT: syntax
M: gadget pprint* pprint-tuple ;