! Copyright (C) 2008, 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays fry kernel models.compose models.filter
sequences unicode.case ;
IN: models.search

: <search> ( values search quot -- model )
    [ 2array <compose> ] dip
    '[ first2 _ curry filter ] <filter> ;

: <string-search> ( values search quot -- model )
    '[ swap @ [ >case-fold ] bi@ subseq? ] <search> ;
