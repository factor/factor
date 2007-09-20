! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser layouts system ;
IN: bootstrap.ppc

: reserved-area-size 2 bootstrap-cells ;
: lr-save bootstrap-cell ;

"resource:core/cpu/ppc/bootstrap.factor" run-file
