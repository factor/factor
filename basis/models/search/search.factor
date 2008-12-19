! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays calendar fry kernel models.compose models.delay
models.filter sequences ;
IN: models.search

: <search-model> ( values search quot -- model )
    [ 500 milliseconds <delay> 2array <compose> ] dip
    '[ first2 @ ] <filter> ;