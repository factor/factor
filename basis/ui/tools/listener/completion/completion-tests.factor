! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test ui.tools.listener.completion ;
IN: ui.tools.listener.completion.tests

[ f ] [ { "USE:" "A" "B" "C" } complete-vocab? ] unit-test

[ f ] [ { "USE:" "A" "B" } complete-vocab? ] unit-test

[ f ] [ { "USE:" "A" "" } complete-vocab? ] unit-test

[ t ] [ { "USE:" "A" } complete-vocab? ] unit-test

[ t ] [ { "USE:" } complete-vocab? ] unit-test

[ t ] [ { "UNUSE:" "A" } complete-vocab? ] unit-test

[ t ] [ { "QUALIFIED:" "A" } complete-vocab? ] unit-test

[ t ] [ { "QUALIFIED-WITH:" "A" } complete-vocab? ] unit-test

[ t ] [ { "USING:" "A" "B" "C" } complete-vocab-list? ] unit-test

[ f ] [ { "USING:" "A" "B" "C" ";" } complete-vocab-list? ] unit-test

[ t ] [ { "X" ";" "USING:" "A" "B" "C" } complete-vocab-list? ] unit-test
