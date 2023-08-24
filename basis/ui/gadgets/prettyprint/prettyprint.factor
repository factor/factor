! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: ui.gadgets prettyprint.backend prettyprint.custom ;

! Don't print gadgets with RECT: syntax
M: gadget pprint* pprint-tuple ;
