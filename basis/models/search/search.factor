! Copyright (C) 2008, 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: kernel models.arrow.smart sequences unicode ;
IN: models.search

: <search> ( values search quot -- model )
    '[ _ curry filter ] <smart-arrow> ; inline

: <string-search> ( values search quot -- model )
    '[ swap @ [ >case-fold ] bi@ subseq? ] <search> ; inline
