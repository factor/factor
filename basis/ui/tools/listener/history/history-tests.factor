! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: documents namespaces tools.test io.styles
ui.tools.listener.history kernel ;
IN: ui.tools.listener.history.tests

[ ] [ <document> "d" set ] unit-test
[ ] [ "d" get <history> "h" set ] unit-test

[ ] [ "1" "d" get set-doc-string ] unit-test
[ T{ input f "1" } ] [ "h" get history-add ] unit-test

[ ] [ "2" "d" get set-doc-string ] unit-test
[ T{ input f "2" } ] [ "h" get history-add ] unit-test

[ ] [ "3" "d" get set-doc-string ] unit-test
[ T{ input f "3" } ] [ "h" get history-add ] unit-test

[ ] [ "" "d" get set-doc-string ] unit-test

[ ] [ "h" get history-recall-previous ] unit-test
[ "3" ] [ "d" get doc-string ] unit-test

[ ] [ "h" get history-recall-previous ] unit-test
[ "2" ] [ "d" get doc-string ] unit-test

[ ] [ "h" get history-recall-previous ] unit-test
[ "1" ] [ "d" get doc-string ] unit-test

[ ] [ "h" get history-recall-previous ] unit-test
[ "1" ] [ "d" get doc-string ] unit-test

[ ] [ "h" get history-recall-next ] unit-test
[ "2" ] [ "d" get doc-string ] unit-test

[ ] [ "22" "d" get set-doc-string ] unit-test

[ ] [ "h" get history-recall-next ] unit-test
[ "3" ] [ "d" get doc-string ] unit-test

[ ] [ "h" get history-recall-previous ] unit-test
[ "22" ] [ "d" get doc-string ] unit-test

[ ] [ "h" get history-recall-previous ] unit-test
[ "1" ] [ "d" get doc-string ] unit-test

[ ] [ "222" "d" get set-doc-string ] unit-test
[ T{ input f "222" } ] [ "h" get history-add ] unit-test

[ ] [ "h" get history-recall-previous ] unit-test
[ ] [ "h" get history-recall-previous ] unit-test
[ ] [ "h" get history-recall-previous ] unit-test

[ "22" ] [ "d" get doc-string ] unit-test
