! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays fry kernel models.product models.arrow
sequences sorting ;
IN: models.sort

: <sort> ( values sort -- model )
    2array <product> [ first2 sort ] <arrow> ;