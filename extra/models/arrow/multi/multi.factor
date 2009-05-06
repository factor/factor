! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: models.arrow models.product stack-checker accessors fry
generalizations kernel ;
IN: models.arrow.multi

: <n-arrow> ( quot int -- arrow )
    [ narray <product> ] [ '[ _ firstn @ ] <arrow> ] bi ; inline

: <2arrow> ( a b quot -- arrow ) 2 <n-arrow> ;
: <3arrow> ( a b c quot -- arrow ) 3 <n-arrow> ;