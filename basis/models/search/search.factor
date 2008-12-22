! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays fry kernel models.compose models.filter sequences ;
IN: models.search

: <search> ( values search quot -- model )
    [ 2array <compose> ] dip
    '[ first2 _ curry filter ] <filter> ;