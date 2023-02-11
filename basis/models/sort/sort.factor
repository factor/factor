! Copyright (C) 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: models.arrow.smart sorting ;
IN: models.sort

: <sort> ( values sort -- model )
    [ '[ _ call( obj1 obj2 -- <=> ) ] sort-with ] <smart-arrow> ; inline
