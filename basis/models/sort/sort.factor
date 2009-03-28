! Copyright (C) 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: sorting models.arrow.smart fry ;
IN: models.sort

: <sort> ( values sort -- model )
    [ '[ _ call( obj1 obj2 -- <=> ) ] sort ] <smart-arrow> ; inline