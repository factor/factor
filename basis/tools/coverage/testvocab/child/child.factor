! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: tools.coverage.testvocab.child

: foo ( -- ) ;
: child-halftested ( ? -- ) [ ] [ ] if ;
