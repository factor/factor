! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser layouts system ;
IN: bootstrap.ppc

: reserved-area-size 6 bootstrap-cells ;
: lr-save 2 bootstrap-cells ;

"resource:core/cpu/ppc/bootstrap.factor" run-file
