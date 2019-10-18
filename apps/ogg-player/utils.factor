! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel sequences quotations inference ;
IN: vorbis

: get-slots-quot ( seq -- quot )
    [ 1quotation [ keep ] curry ] map concat [ drop ] append ;

: get-slots ( tuple seq -- ) get-slots-quot call ;

\ get-slots 1 [ get-slots-quot ] define-transform 
