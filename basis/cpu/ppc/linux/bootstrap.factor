! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser layouts system kernel sequences ;
IN: bootstrap.ppc

: c-area-size ( -- n ) 10 bootstrap-cells ;
: lr-save ( -- n ) bootstrap-cell ;

<< "vocab:cpu/ppc/bootstrap.factor" parse-file suffix! >>
call
