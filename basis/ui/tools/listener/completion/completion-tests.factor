! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test ui.tools.listener.completion ;
IN: ui.tools.listener.completion.tests

[ t ] [ { "USING:" "A" "B" "C" } complete-USING:? ] unit-test

[ f ] [ { "USING:" "A" "B" "C" ";" } complete-USING:? ] unit-test

[ t ] [ { "X" ";" "USING:" "A" "B" "C" } complete-USING:? ] unit-test