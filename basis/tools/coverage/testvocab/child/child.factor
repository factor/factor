! Copyright (C) 2014 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: tools.coverage.testvocab.child

: foo ( -- ) ;
: child-halftested ( ? -- ) [ ] [ ] if ;
