! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser system kernel sequences ;
IN: bootstrap.ppc

: reserved-size ( -- n ) 24 ;
: lr-save ( -- n ) 8 ;

<< "vocab:cpu/ppc/bootstrap.factor" parse-file suffix! >>
call
