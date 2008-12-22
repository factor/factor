! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays fry kernel models.compose models.filter
sequences sorting ;
IN: models.sort

: <sort> ( values sort -- model )
    2array <compose> [ first2 sort ] <filter> ;