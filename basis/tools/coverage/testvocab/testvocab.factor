! Copyright (C) 2014 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel math sequences ;
IN: tools.coverage.testvocab

<PRIVATE

: testifprivate ( ? -- ) [ ] [ ] if ;

PRIVATE>

: halftested ( ? -- ) [ ] [ ] if ;
: testif ( ? -- ) [ ] [ ] if ;
: testcond ( n -- n ) {
  { [ dup 0 = ] [ ] }
  { [ dup 1 = ] [ ] }
  [ ]
} cond ;

MACRO: mconcat ( seq -- quot ) concat ;
: testmacro ( a b -- )
    { [ 2dup ] [ <= [ ] [ ] if ] [ > [ ] [ ] if ] } mconcat ;

: testfry ( ? -- )
  '[ _ [ ] [ ] if ] call ;

: untested ( -- ) ;

SYMBOL: not-a-coverage-word
